import boto3
from unittest.mock import MagicMock
import LambdaFunction # import your lambda function code here

def test_lambda_handler():
    # Set up a mock DynamoDB client
    dynamodb = boto3.client('dynamodb', region_name='us-east-1')
    LambdaFunction.dynamodb = MagicMock(return_value=dynamodb)

    # Call the lambda function
    response = LambdaFunction.lambda_handler(event=None, context=None)

    # Check the response
    assert response == {"statusCode": 200, "body": "Success"}

    # Check that the DynamoDB table was accessed correctly
    dynamodb.put_item.assert_called_once_with(
        TableName='visitor_count',
        Item={
            'visitorCount': {'N': '1'}
        }
    )