import json
import boto3
import os
from moto import mock_s3, mock_dynamodb2


def test_lambda_handler():
    # Set up environment variables
    os.environ['API_URL'] = 'https://api.example.com/data'
    os.environ['BUCKET_NAME'] = 'test-bucket'
    os.environ['DYNAMO_TABLE'] = 'test-table'

    # Mock S3 and DynamoDB
    with mock_s3(), mock_dynamodb2():
        # Create S3 bucket
        s3 = boto3.client('s3')
        s3.create_bucket(Bucket='test-bucket')

        # Create DynamoDB table
        dynamodb = boto3.resource('dynamodb')
        table = dynamodb.create_table(
            TableName='test-table',
            KeySchema=[{'AttributeName': 'id', 'KeyType': 'HASH'}],
            AttributeDefinitions=[{'AttributeName': 'id', 'AttributeType': 'S'}],
            ProvisionedThroughput={'ReadCapacityUnits': 1, 'WriteCapacityUnits': 1}
        )
        table.wait_until_exists()

        # Mock the Lambda event
        event = {}
        context = {}

        # Call the lambda handler
        from lambdas.data_processor import lambda_handler
        response = lambda_handler(event, context)

        # Check the response
        assert response['statusCode'] == 200
        assert response['body'] == 'Data processed and stored successfully.'

        # Check if data is written to S3
        s3_objects = s3.list_objects_v2(Bucket='test-bucket')
        assert 'Contents' in s3_objects
        assert len(s3_objects['Contents']) > 0

        # Check if data is written to DynamoDB
        items = table.scan()['Items']
        assert len(items) > 0


if __name__ == '__main__':
    test_lambda_handler()
