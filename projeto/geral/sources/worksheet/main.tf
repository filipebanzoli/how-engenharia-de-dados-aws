

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# When importing this module, don't forget to configure
# in your main.tf the desired region and your teams's
# tag. For example:
#
# provider "aws" {
#   region = "us-east-1"
#   default_tags {
#     tags = {
#       Owner = "equipe_a"
#     }
#   }
# }

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "data_lake" {
  bucket        = "data-lake-how-${local.aws_account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


