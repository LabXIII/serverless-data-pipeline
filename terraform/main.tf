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

resource "aws_cloudwatch_dashboard" "serverless_dashboard" {
  dashboard_name = "${var.project_name}_dashboard"
  dashboard_body = <<EOF
  {
    "widgets": [
      {
        "type": "metric",
        "x": 0,
        "y": 0,
        "width": 6,
        "height": 6,
        "properties": {
          "metrics": [
            [ "AWS/Lambda", "Invocations", "FunctionName", "${aws_lambda_function.data_processor.function_name}" ],
            [ ".", "Errors", ".", "." ],
            [ ".", "Duration", ".", ".", { "stat": "Average" } ]
          ],
          "period": 300,
          "stat": "Sum",
          "region": "${var.aws_region}",
          "title": "Lambda Metrics"
        }
      },
      {
        "type": "metric",
        "x": 6,
        "y": 0,
        "width": 6,
        "height": 6,
        "properties": {
          "metrics": [
            [ "AWS/DynamoDB", "ConsumedReadCapacityUnits", "TableName", "${aws_dynamodb_table.data_table.name}" ],
            [ ".", "ConsumedWriteCapacityUnits", ".", "." ]
          ],
          "period": 300,
          "stat": "Sum",
          "region": "${var.aws_region}",
          "title": "DynamoDB Metrics"
        }
      },
      {
        "type": "metric",
        "x": 12,
        "y": 0,
        "width": 6,
        "height": 6,
        "properties": {
          "metrics": [
            [ "AWS/S3", "NumberOfObjects", "BucketName", "${aws_s3_bucket.raw_data_bucket.bucket}" ],
            [ ".", "BucketSizeBytes", ".", ".", { "stat": "Average" } ]
          ],
          "period": 300,
          "stat": "Sum",
          "region": "${var.aws_region}",
          "title": "S3 Metrics"
        }
      }
    ]
  }
  EOF
}

resource "aws_cloudwatch_metric_alarm" "lambda_error_alarm" {
  alarm_name          = "${var.project_name}_lambda_errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm if Lambda function has errors"
  dimensions = {
    FunctionName = aws_lambda_function.data_processor.function_name
  }
  alarm_actions = [aws_sns_topic.alerts.arn]  # Assuming you've set up an SNS topic for alerts
}

# AWS KMS Key for data encryption
resource "aws_kms_key" "data_key" {
  description             = "KMS key for encrypting data in S3 and DynamoDB"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Name        = "${var.project_name}-data-key"
    Environment = terraform.workspace
  }
}
