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
  }
}

# Configure the AWS Provider
# Credentials set in vars.tf file
provider "aws" {
  profile    = "default"
  region     = "us-east-1"
  access_key = var.aws_access_key_id
  secret_key = var.aws_access_secret_key
  token      = var.aws_session_token
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

# Bucket Prod security
resource "aws_s3_bucket_public_access_block" "data-lake-production" {
  bucket = aws_s3_bucket.data-lake-production.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket Dev security
resource "aws_s3_bucket_public_access_block" "data-lake-development" {
  bucket = aws_s3_bucket.data-lake-development.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#Create airbyte user
resource "aws_iam_user" "airbyte-user" {
  name = "airbyte_user_equipe_a"
}

resource "aws_iam_access_key" "airbyte-user-ak" {
  user = aws_iam_user.airbyte-user.name
}

output "aws_iam_smtp_password_v4" {
  value     = aws_iam_access_key.airbyte-user-ak.ses_smtp_password_v4
  sensitive = true
}

# Configure airbyte policy
resource "aws_iam_user_policy" "airbyte-policy" {
  name = "airbyte-policy-equipe-a"
  user = aws_iam_user.airbyte-user.name

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:PutObjectAcl",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.data-lake-production.bucket}/*",
          "arn:aws:s3:::${aws_s3_bucket.data-lake-production.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.data-lake-development.bucket}/*",
          "arn:aws:s3:::${aws_s3_bucket.data-lake-development.bucket}",
        ]
      },
    ]
  })
}

# Configure Crawler
data "aws_ecr_authorization_token" "token" {
}

provider "docker" {
  registry_auth {
    address  = "${local.aws_account_id}.dkr.ecr.us-east-2.amazonaws.com"
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}

module "docker_image" {
  source = "terraform-aws-modules/lambda/aws//modules/docker-build"

  create_ecr_repo = true
  ecr_repo        = "webcrawler_condor"
  image_tag       = "1.0"
  source_path     = "../crawler/"
  version         = "6.0.0"
}

resource "aws_iam_role" "webcrawler_condor_role" {
  name = "webcrawler_condor_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
  "arn:aws:iam::aws:policy/CloudWatchFullAccess"]
}

data "aws_vpc" "selected" {
  default = true
}

data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name  = "webcrawler_condor"
  create_package = false

  image_uri      = module.docker_image.image_uri
  package_type   = "Image"
  create_role    = false
  lambda_role    = aws_iam_role.webcrawler_condor_role.arn
  memory_size    = 3008
  timeout        = 60
  vpc_subnet_ids = data.aws_subnets.all.ids
  version        = "6.0.0"
}
