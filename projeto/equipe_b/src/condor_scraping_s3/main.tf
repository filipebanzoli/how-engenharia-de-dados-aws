terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.1"
    }
  }
}

locals {
  my_public_ip                     = sensitive(chomp(data.http.my_public_ip.response_body))
  transactional_database           = "transactional"
  transactional_root_user          = "postgres"
  transactional_fake_data_user     = "scraping_data"
  module_path                      = abspath(path.module)
  aws_account_id                   = data.aws_caller_identity.current.account_id
}



# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
  default_tags {
    tags = {
      Owner = "geral"
    }
  }
}

# Get current public IP address
data "http" "my_public_ip" {
  url = "http://ipv4.icanhazip.com"
}

data "aws_caller_identity" "current" {}


data "aws_ecr_authorization_token" "token" {
}

provider "docker" {
  registry_auth {
    address  = "${local.aws_account_id}.dkr.ecr.us-west-2.amazonaws.com"
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}

// modulo nativo da 'aws'
module "docker_image" {
  source = "terraform-aws-modules/lambda/aws//modules/docker-build"

  create_ecr_repo = true
  ecr_repo        = "scraping_crawler"
  image_tag       = "1.0"
  source_path     = "./"
  # source_path     = "./sources/transactional_database/scraping_crawler/"
  platform        = "linux/x86_64"
}


resource "aws_iam_role" "read_scraping_data_secret_key" {
  name = "read_scraping_data_secret_key_role"

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
  "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"]
}

# Define a política
data "aws_iam_policy_document" "lb_ro" {
  statement {
    effect    = "Allow"
    actions   = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:PutObjectAcl",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation"
    ]
    resources = [aws_s3_bucket.scraping_data_bucket.arn, "${aws_s3_bucket.scraping_data_bucket.arn}/*"]
  }
}


# Cria a política de fato
resource "aws_iam_policy" "lb_ro_policy" {
  name        = "lb_ro_policy"
  description = "A test policy"
  policy      = data.aws_iam_policy_document.lb_ro.json
}

# Associa a política a uma role
resource "aws_iam_role_policy_attachment" "lb_ro_policy_attach" {
  role       = aws_iam_role.read_scraping_data_secret_key.name
  policy_arn = aws_iam_policy.lb_ro_policy.arn
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

resource "aws_security_group" "scraping_crawler_sg" {
  name        = "scraping_crawler_sg"
  description = "Allow Access to Transactional Database"
}


module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name  = "scraping_crawler"
  create_package = false

  image_uri     = module.docker_image.image_uri
  package_type  = "Image"
  create_role   = false
  lambda_role   = aws_iam_role.read_scraping_data_secret_key.arn
  architectures = ["x86_64"]
  memory_size   = 256
  timeout       = 60

}

resource "aws_s3_bucket" "scraping_data_bucket" {
  bucket = "bucket-to-save-the-data"
  force_destroy = true 
}

resource "aws_s3_bucket_public_access_block" "my_first_tf_s3_access_block" {
  bucket = aws_s3_bucket.scraping_data_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
