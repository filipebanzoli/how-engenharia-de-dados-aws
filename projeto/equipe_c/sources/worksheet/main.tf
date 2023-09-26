terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Owner = "equipe_c"
    }
  }
}


# Configura a conta
data "aws_caller_identity" "current" {}

# Busca a conta  AWS Account ID
locals {
  aws_account_id = data.aws_caller_identity.current.account_id
}

# Resource Datalake
resource "aws_s3_bucket" "datalake" {
  bucket = "prd-datalake-team-c-${local.aws_account_id}"

  tags = {
    Environment = "Dev"
  }
}

# Bucket Block
resource "aws_s3_bucket_public_access_block" "block_datalake" {
  bucket = aws_s3_bucket.datalake.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Usuário airbyte acessos
resource "aws_iam_user" "airbyte-stream" {
  name = "user_airbyte"
}

resource "aws_iam_access_key" "ak_airbyte_user" {
  user = aws_iam_user.airbyte-stream.name
}

resource "aws_iam_user_policy" "airbyte_policy" {
  name   = "airbyte_policy"
  user   = aws_iam_user.airbyte-stream.name
  policy = file("${path.module}/policy-airbyte-user.json")
}