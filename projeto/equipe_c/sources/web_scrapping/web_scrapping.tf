terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.1.0"
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


# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
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



resource "aws_iam_role" "scrapping_secret_key" {
  name = "scrapping_secret_key_role"

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

  inline_policy {
    name = "scrapping_secret_policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["secretsmanager:GetSecretValue",
                      ""]
          Effect   = "Allow"
          Resource = aws_secretsmanager_secret.postgres_transactional_fake_data.arn
        },
      ]
    })
  }
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

  function_name  = "writer_brass"
  create_package = false

  image_uri     = module.docker_image.image_uri
  package_type  = "Image"
  create_role   = false
  lambda_role   = aws_iam_role.scrapping_secret_key.arn
  architectures = ["arm64"]
  memory_size   = 3008
  timeout       = 30

  vpc_subnet_ids         = data.aws_subnets.all.ids
  vpc_security_group_ids = [aws_security_group.my_ip.id]
}