import boto3
import json
    
# Get the service resource
dynamodb = boto3.resource('dynamodb')

# Get the table name
visitors_table = dynamodb.Table('visitor_count')

def lambda_handler(event, context, visitors_table=visitors_table):
    
    response = visitors_table.get_item(Key={"visitorCount" : "user" })    
    visitorCount = response['Item']['visitor']
    
    response = visitors_table.update_item(
        Key={"visitorCount": "user"},
        UpdateExpression="set visitor = visitor + :n",
        ExpressionAttributeValues={
            ":n": 1,
        },
    )
    
    return {
        'body': visitorCount,
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Content-Type': 'application/json'
}