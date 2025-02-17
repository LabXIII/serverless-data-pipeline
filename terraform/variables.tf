variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  default     = "serverless-data-pipeline"
}

variable "api_url" {
  description = "API URL for data source"
  default     = "https://api.example.com/data"
}

variable "lambda_code_bucket" {
  description = "S3 bucket for Lambda code"
  default     = "lambda-code-bucket"
}

variable "lambda_code_key" {
  description = "S3 key for Lambda code zip"
  default     = "function.zip"
}

