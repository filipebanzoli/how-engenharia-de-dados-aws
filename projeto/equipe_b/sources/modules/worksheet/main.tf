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
  profile    = "default"
  region     = "us-east-1"
  access_key = var.aws_access_key_id
  secret_key = var.aws_access_secret_key
  token      = var.aws_session_token
  default_tags {
    tags = {
      Owner = "my-bucket-equipe-b"
    }
  }
}

# Configure the AWS resource
resource "aws_s3_bucket" "data-lake-production" {
  bucket = "my-bucket-equipe-b"
  tags = {
    Grupo = "my-bucket-equipe-b"
  }
}
