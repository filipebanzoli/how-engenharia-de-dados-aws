terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
data "aws_caller_identity" "current" {}

locals {
  aws_account_id                   = data.aws_caller_identity.current.account_id
}
resource "aws_s3_bucket" "datalake_bucket" {
  bucket = "raw-datalake-takedata"

}
data "aws_ecr_authorization_token" "token" {
}

provider "docker" {
  registry_auth {
    address  = "${local.aws_account_id}.dkr.ecr.us-east-1.amazonaws.com"
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}
module "docker_image" {
  source = "terraform-aws-modules/lambda/aws//modules/docker-build"

  create_ecr_repo = true
  ecr_repo        = "web_scrapping"
  image_tag       = "1.0"
  source_path     = "./web_scrapping"
  platform        = "linux/arm64"
}
resource "aws_iam_role" "aws_role_lambda" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com",
        },
      },
    ]
  })
}

resource "aws_iam_user" "lambda_user" {
  name = "lambda_user"
  path = "/system/"
}

resource "aws_iam_access_key" "lambda_access_key" {
  user = aws_iam_user.lambda_user.name
}

output "secret_access_key" {
  value = aws_iam_access_key.lambda_access_key.secret
  sensitive = true
}
resource "aws_iam_policy" "lambda_s3_access" {
  name        = "LambdaS3Access"
  description = "Policy for allowing Lambda to access S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:AbortMultipartUpload",
          "s3:CreateBucket"
        ],
        Resource = [
          "${aws_s3_bucket.datalake_bucket.arn}",
          "${aws_s3_bucket.datalake_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_access_attachment" {
  role       = aws_iam_role.aws_role_lambda.name
  policy_arn = aws_iam_policy.lambda_s3_access.arn
}

module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "web_scrapping"
  create_package = false

  image_uri     = module.docker_image.image_uri
  package_type = "Image"
  create_role = false
  lambda_role = aws_iam_role.aws_role_lambda.arn
  architectures = ["x86_64"]
  memory_size   = 3008
  timeout       = 30
}