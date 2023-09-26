terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
  shared_config_files      = ["C:/Users/natri/.aws/config"]
  shared_credentials_files = ["C:/Users/natri/.aws/credentials"]
  profile = "AdministratorAccess-900614915756"
}


# Cria o bucket S3
resource "aws_s3_bucket" "data-lake" {
  bucket = "data-lake-900614915756"
}

# Configura os acessos publcios ao bucket S3 criado
resource "aws_s3_bucket_public_access_block" "data_lake" {
  bucket = aws_s3_bucket.data-lake.id

  block_public_acls       = true 
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# cria o usuario para acessar o S3
resource "aws_iam_user" "user1" {
  name = "user1"
  path = "/system/"
}

# cria uma access key, que permite o usuario faca requests para o S3
resource "aws_iam_access_key" "user1" {
  user    = aws_iam_user.user1.name
}

# cria um policy atrelada ao usuario com permissao de acesso ao S3
resource "aws_iam_user_policy" "user1" {
  name = "user1-policy-s3"
  user = aws_iam_user.user1.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
