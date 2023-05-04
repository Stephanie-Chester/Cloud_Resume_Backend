import unittest
from unittest.mock import Mock
from LambdaFunction import lambda_handler

class TestLambda(unittest.TestCase):
    def test_lambda_handler(self):
        # Create a mock DynamoDB table
        table_mock = Mock()
        # Set up the expected behavior of the mock table
        table_mock.get_item.return_value = {'Item': {'visitorCount': 'user', 'visitor': 5}}
        # Call the Lambda function with the mock table
        result = lambda_handler(event={}, context={}, visitors_table=table_mock)
        # Check that the result is as expected
        self.assertEqual(result, {
            'body': 5,
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Content-Type': 'application/json'
        })
