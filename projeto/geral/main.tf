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

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Owner = "geral"
    }
  }
}

locals {
  my_public_ip                     = sensitive(chomp(data.http.my_public_ip.response_body))
  transactional_root_user          = jsondecode(data.aws_secretsmanager_secret_version.postgres_transactional_root_version.secret_string)["username"]
  transactional_root_password      = jsondecode(data.aws_secretsmanager_secret_version.postgres_transactional_root_version.secret_string)["password"]
  transactional_fake_data_user     = jsondecode(data.aws_secretsmanager_secret_version.postgres_transactional_fake_data_version.secret_string)["username"]
  transactional_fake_data_password = jsondecode(data.aws_secretsmanager_secret_version.postgres_transactional_fake_data_version.secret_string)["password"]
  aws_account_id                   = data.aws_caller_identity.current.account_id
}

# Get current public IP address
data "http" "my_public_ip" {
  url = "http://ipv4.icanhazip.com"
}
data "aws_caller_identity" "current" {}

resource "aws_security_group" "my_ip" {
  name        = "my_ip"
  description = "Allow access by my Public IP Address"

  ingress {
    description = "Access Postgres from my public IP"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["${local.my_public_ip}/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_secretsmanager_secret" "postgres_transactional_root" {
  name                    = "postgres_transactional_root"
  description             = "Postgres RDS Transactional Database Root Role"
  recovery_window_in_days = 0
}

resource "random_password" "postgres_transactional_root_password" {
  length           = 16
  special          = true
  override_special = "!$-+<>:"
}

resource "aws_secretsmanager_secret_version" "postgres_transactional_root_version" {
  secret_id     = aws_secretsmanager_secret.postgres_transactional_root.id
  secret_string = "{\"username\":\"postgres\", \"password\":\"${random_password.postgres_transactional_root_password.result}\"}"
}

data "aws_secretsmanager_secret_version" "postgres_transactional_root_version" {
  secret_id  = aws_secretsmanager_secret.postgres_transactional_root.id
  depends_on = [aws_secretsmanager_secret_version.postgres_transactional_root_version]
}

resource "aws_secretsmanager_secret" "postgres_transactional_fake_data" {
  name                    = "postgres_transactional_fake_data"
  description             = "Postgres RDS Transactional Database Fake Data Role"
  recovery_window_in_days = 0
}

resource "random_password" "postgres_transactional_fake_data_password" {
  length           = 16
  special          = true
  override_special = "!$-+<>:"
}

resource "aws_secretsmanager_secret_version" "postgres_transactional_fake_data_version" {
  secret_id     = aws_secretsmanager_secret.postgres_transactional_fake_data.id
  secret_string = "{\"username\":\"fake_data_app\", \"password\":\"${random_password.postgres_transactional_fake_data_password.result}\"}"
}

data "aws_secretsmanager_secret_version" "postgres_transactional_fake_data_version" {
  secret_id  = aws_secretsmanager_secret.postgres_transactional_fake_data.id
  depends_on = [aws_secretsmanager_secret_version.postgres_transactional_fake_data_version]
}

resource "aws_db_instance" "transactional" {
  allocated_storage       = 20
  db_name                 = "transactional"
  identifier              = "transactional"
  multi_az                = false
  engine                  = "postgres"
  instance_class          = "db.t3.micro"
  username                = local.transactional_root_user
  password                = local.transactional_root_password
  storage_type            = "gp2"
  backup_retention_period = 0
  publicly_accessible     = true
  skip_final_snapshot     = true
  vpc_security_group_ids  = [aws_security_group.my_ip.id]

  provisioner "local-exec" {
    command = "psql -h ${self.address} -p ${self.port} -U ${local.transactional_root_user} -d transactional -f ./sources/transactional_database/prepare_database/terraform_prepare_database.sql -v user=${local.transactional_fake_data_user} password='${local.transactional_fake_data_password}'"
    environment = {
      PGPASSWORD = local.transactional_root_password
    }
  }
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
  ecr_repo        = "insert_fake_data"
  image_tag       = "1.0"
  source_path     = "./sources/transactional_database/insert_fake_data/"
  platform        = "linux/arm64"
}


resource "aws_iam_role" "read_fake_data_app_secret_key" {
  name = "read_fake_data_app_secret_key_role"

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
    name = "fake_data_app_secret_policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["secretsmanager:GetSecretValue"]
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

  function_name  = "insert_fake_data"
  create_package = false

  image_uri     = module.docker_image.image_uri
  package_type  = "Image"
  create_role   = false
  lambda_role   = aws_iam_role.read_fake_data_app_secret_key.arn
  architectures = ["arm64"]
  memory_size   = 3008
  timeout       = 30
  environment_variables = {
    postgres_app_user_kms_key = aws_secretsmanager_secret.postgres_transactional_fake_data.name
    postgres_host             = aws_db_instance.transactional.address
    postgres_database         = "transactional"
    postgres_port             = 5432
  }
  vpc_subnet_ids         = data.aws_subnets.all.ids
  vpc_security_group_ids = [aws_security_group.my_ip.id]
  depends_on             = [aws_db_instance.transactional]
}
