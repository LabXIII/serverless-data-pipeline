# Architecture Overview

## Data Flow

1. **Data Retrieval:** The Lambda function retrieves data from a public REST API, such as a weather or cryptocurrency price endpoint.
2. **Storage in S3:** The raw payload from the API is stored in an S3 bucket for archival and later processing.
3. **Data Processing:** The Lambda function extracts important fields from the raw data and writes them to a DynamoDB table for structured storage.

## API Gateway's Role

- If used, API Gateway acts as a trigger for the Lambda function, allowing external services or clients to initiate data processing.
- It can be configured to use either HTTP or REST APIs, depending on the requirements.

## IAM Roles and Security

- **Lambda Execution Role:** Grants the Lambda function permissions to access S3 and DynamoDB.
- **S3 Bucket Policy:** Ensures that only authorized entities can access the raw data stored in S3.
- **DynamoDB Table Policy:** Restricts access to the data table, allowing only specific operations from authorized roles.

## Environment Variables

- **API_URL:** The endpoint of the public REST API from which data is retrieved.
- **BUCKET_NAME:** The name of the S3 bucket where raw data is stored.
- **DYNAMO_TABLE:** The name of the DynamoDB table where structured data is stored.

This architecture ensures a scalable and secure serverless data pipeline, leveraging AWS services for data processing and storage.
