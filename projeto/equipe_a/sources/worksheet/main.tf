terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
# Credentials set in vars.tf file 
provider "aws" {
  profile = "default"
  region = "us-east-1"
  access_key = var.aws_access_key_id
  secret_key = var.aws_access_secret_key
  token = var.aws_session_token
  default_tags {
    tags = {
      Owner = "equipe_a"
    }
  }
}

# Congigure the Account data
data "aws_caller_identity" "current" {}

# Get the current AWS Account ID
locals {
  aws_account_id = data.aws_caller_identity.current.account_id
}

# Configure the AWS resource
resource "aws_s3_bucket" "data-lake-production" {
  bucket = "prod-datalake-how-equipe-a-${local.aws_account_id}"
  tags = {
    Grupo = "equipe_a"
  }
}

resource "aws_s3_bucket" "data-lake-development" {
  bucket = "dev-datalake-how-equipe-a-${local.aws_account_id}"
  tags = {
    Grupo = "equipe_a"
  }
}