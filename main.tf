terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# IAM role for Lambda execution
resource "aws_iam_role" "lambda_role" {
  name = "otlp-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


# Lambda function
resource "aws_lambda_function" "otlp_lambda" {
  filename         = "lambda-package.zip"
  function_name    = "otlp-lambda-example"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  timeout          = 30
  memory_size      = 256
  source_code_hash = filebase64sha256("lambda-package.zip")

  layers = [
    "arn:aws:lambda:${var.aws_region}:184161586896:layer:opentelemetry-nodejs-0_16_0:1",
    "arn:aws:lambda:${var.aws_region}:184161586896:layer:opentelemetry-collector-amd64-0_17_0:1"
  ]


  environment {
    variables = {
      GRAFANA_OTLP_ENDPOINT              = var.grafana_otlp_endpoint
      GRAFANA_OTLP_AUTH                  = base64encode("${var.grafana_otlp_username}:${var.grafana_otlp_password}")
      AWS_LAMBDA_EXEC_WRAPPER            = "/opt/otel-handler"
      OPENTELEMETRY_COLLECTOR_CONFIG_URI = "/var/task/collector.yaml"
      FLUSH_METRICS                      = var.flush_metrics
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic
  ]
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.otlp_lambda.function_name}"
  retention_in_days = 7
}

# Output the Lambda function ARN
output "lambda_function_arn" {
  value = aws_lambda_function.otlp_lambda.arn
}

# Output the Lambda function name
output "lambda_function_name" {
  value = aws_lambda_function.otlp_lambda.function_name
}
