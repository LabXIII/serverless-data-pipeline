# serverless-data-pipeline
## Project Overview

This project aims to create a scalable, serverless data pipeline that ingests data from an external source, processes it using AWS Lambda, stores raw data in S3 for archival, and writes structured results into DynamoDB for query and retrieval.

## Objectives

- Orchestrate multiple AWS services (API Gateway, Lambda, S3, DynamoDB, IAM)
- Design Infrastructure as Code (IaC) with Terraform
- Set up a CI/CD pipeline for seamless updates and improvements

## Usage Instructions

1. Clone the repository.
2. Navigate to the `terraform/` directory and initialize Terraform.
3. Apply the Terraform configuration to provision the AWS infrastructure.
4. Deploy the Lambda function using the CI/CD pipeline.
5. Monitor the pipeline's performance and make adjustments as needed.

## References

- [AWS Lambda Documentation](https://docs.aws.amazon.com/lambda/)
- [Terraform Documentation](https://www.terraform.io/docs/index.html)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
