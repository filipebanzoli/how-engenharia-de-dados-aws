terraform {

  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    airbyte = {
      source  = "airbytehq/airbyte"
      version = "0.3.4"
    }
  }
}

provider "aws" {
  profile = "default"
}

data "aws_caller_identity" "current" {}


locals {
  aws_account_id = data.aws_caller_identity.current.account_id
}

# # Configure the AWS resource
resource "aws_s3_bucket" "data_lake_production" {
  bucket = "bucket-tf-${local.aws_account_id}-equipe-d"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "data_lake_production" {
  
  bucket = "bucket-tf-${local.aws_account_id}-equipe-d"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}