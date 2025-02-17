import json
import boto3
import requests
import os
from datetime import datetime

s3_client = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')

def lambda_handler(event, context):
    # 1. Fetch data from external API
    api_url = os.getenv('API_URL')
    response = requests.get(api_url)
    data = response.json()

    # 2. Write raw data to S3
    bucket_name = os.getenv('BUCKET_NAME')
    file_name = f"raw-data-{datetime.now().isoformat()}.json"
    s3_client.put_object(
        Bucket=bucket_name,
        Key=file_name,
        Body=json.dumps(data)
    )

    # 3. Parse data and insert into DynamoDB
    table_name = os.getenv('DYNAMO_TABLE')
    table = dynamodb.Table(table_name)

    # Example: if data is a single record
    table.put_item(Item={
        "id": str(datetime.now().timestamp()),
        "value": data.get('importantValue', 'N/A'),
        "timestamp": str(datetime.now())
    })

    return {
        "statusCode": 200,
        "body": "Data processed and stored successfully."
    }

