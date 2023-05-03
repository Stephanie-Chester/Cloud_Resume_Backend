import unittest
from unittest.mock import Mock, patch
import json
import boto3

# Import the Lambda function
from LambdaFunction import lambda_handler

class TestLambdaFunction(unittest.TestCase):

    def test_lambda_handler(self):
        # Mock the DynamoDB table
        mock_table = Mock()
        mock_table.get_item.return_value = {
            'Item': {
                'visitor': 10
            }
        }
        mock_table.update_item.return_value = None
        
        # Patch the DynamoDB resource to return the mock table
        with patch.object(boto3, 'resource') as mock_dynamodb:
            mock_dynamodb.return_value.Table.return_value = mock_table
            
            # Call the Lambda function with a test event
            event = {}
            context = {}
            response = lambda_handler(event, context)
            
            # Check that the response is as expected
            expected_response = {
                'statusCode': 200,
                'body': json.dumps({'visitorCount': 11})
            }
            self.assertEqual(response, expected_response)
            
            # Check that the DynamoDB table was called correctly
            mock_table.get_item.assert_called_with(Key={'visitorCount': 'user'})
            mock_table.update_item.assert_called_with(
                Key={'visitorCount': 'user'},
                UpdateExpression='set visitor = visitor + :n',
                ExpressionAttributeValues={':n': 1},
            )


