provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "raw_data_bucket" {
  bucket = "${var.project_name}-raw-data"
  acl    = "private"
}

resource "aws_dynamodb_table" "data_table" {
  name           = "${var.project_name}-data-table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.project_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust.json
}

resource "aws_lambda_function" "data_processor" {
  function_name = "${var.project_name}-data-processor"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.9"
  handler       = "data_processor.lambda_handler"
  s3_bucket     = var.lambda_code_bucket
  s3_key        = var.lambda_code_key
  environment {
    variables = {
      API_URL      = var.api_url
      BUCKET_NAME  = aws_s3_bucket.raw_data_bucket.id
      DYNAMO_TABLE = aws_dynamodb_table.data_table.name
    }
  }
}

