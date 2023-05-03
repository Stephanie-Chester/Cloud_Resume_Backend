import unittest
from unittest.mock import MagicMock
from LambdaFunction import handler # replace with the name of your Lambda function's handler

class TestMyLambdaFunction(unittest.TestCase):
    def test_handler(self):
        # create a mock DynamoDB table
        dynamodb_mock = MagicMock()
        table_mock = MagicMock()
        dynamodb_mock.Table.return_value = table_mock

        # call the Lambda function handler with the mock event and context
        event = {"partition_key": "12345"}
        context = MagicMock()
        handler(event, context, dynamodb=dynamodb_mock)

        # assert that the expected DynamoDB methods were called with the expected arguments
        dynamodb_mock.Table.assert_called_once_with("visitor_count")
        table_mock.update_item.assert_called_once_with(
            Key={"visitorCount": "user"},
            UpdateExpression="ADD visits :incr",
            ExpressionAttributeValues={":incr": 1},
        )

