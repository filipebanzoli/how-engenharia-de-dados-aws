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
  # transactional_root_password      = random_password.postgres_transactional_root_password.result
  transactional_fake_data_user     = "scraping_data"
  # transactional_fake_data_password = random_password.postgres_transactional_fake_data_password.result
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
# 1. Arquitetura do DMS com RDS 
# 2. na pasta geral, importaria o contudo do modulo geral e executatr
# RDS, DMS, e 
# kinese data straming+ Fireboase + lambda + Firehore + s3

# Get current public IP address
data "http" "my_public_ip" {
  url = "http://ipv4.icanhazip.com"
}

data "aws_caller_identity" "current" {}

resource "aws_security_group" "transactional_database_sg" {
  name        = "transactional_database_sg"
  description = "Allow access by my Public IP Address and AWS Lambda"
}


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
  source_path     = "./sources/transactional_database/scraping_crawler/"
  # platform        = "linux/arm64"
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

resource "aws_vpc_security_group_egress_rule" "lambda_scraping_crawler_egress" {
  security_group_id = aws_security_group.scraping_crawler_sg.id
  description = "Access Transactional Postgres Database"
  ip_protocol = "-1"
  referenced_security_group_id = aws_security_group.transactional_database_sg.id
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
  vpc_subnet_ids         = data.aws_subnets.all.ids
  vpc_security_group_ids = [aws_security_group.scraping_crawler_sg.id]

}
