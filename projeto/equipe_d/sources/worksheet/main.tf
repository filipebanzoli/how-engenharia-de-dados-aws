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
  region = "sa-east-1"
  default_tags {
    tags = {
      Owner = "equipe_d"
    }
  }
}

# Criação do Bucket S3
resource "aws_s3_bucket" "example" { 
  bucket = "my-bucket-equipe-d" 
}