
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.1"
    }
  }
}


resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/enrich_data"
  retention_in_days = 14
}


locals {
  module_path = abspath(path.module)
  # aws_account_id                  = data.aws_caller_identity.current.account_id
}

data "archive_file" "enrich_data_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/enrich_data"
  output_path = "${path.module}/enrich_data.zip"
}



# Crie a função Lambda
resource "aws_lambda_function" "enrich_data" {
  function_name = "enrich_data"
  filename      = "${path.module}/enrich_data.zip"
  role          = aws_iam_role.lambda.arn
  handler       = "lambda_function.handler"
  runtime       = "python3.11"
  timeout       = 10
  memory_size   = 128
}



# Crie uma permissão para a Lambda acessar o Firehose
resource "aws_lambda_permission" "firehose_permission" {
  statement_id  = "AllowExecutionFromKinesis"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.enrich_data.arn
  principal     = "firehose.amazonaws.com"
}
