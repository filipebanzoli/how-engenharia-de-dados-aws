
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
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
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
  transactional_root_password      = random_password.postgres_transactional_root_password.result
  transactional_fake_data_user     = "fake_data_app"
  transactional_fake_data_password = random_password.postgres_transactional_fake_data_password.result
  module_path                      = abspath(path.module)
  aws_account_id                   = data.aws_caller_identity.current.account_id
}


# Get current public IP address
data "http" "my_public_ip" {
  url = "http://ipv4.icanhazip.com"
}

data "aws_caller_identity" "current" {}

resource "aws_security_group" "transactional_database_sg" {
  name        = "transactional_database_sg"
  description = "Allow access by my Public IP Address and AWS Lambda"
}

resource "aws_vpc_security_group_ingress_rule" "my_public_ip" {
  security_group_id = aws_security_group.transactional_database_sg.id
  description       = "Access Postgres from my public IP"
  from_port         = 5432
  to_port           = 5432
  ip_protocol       = "tcp"
  cidr_ipv4         = "${local.my_public_ip}/32"
}

resource "aws_vpc_security_group_ingress_rule" "lambda_insert_fake_data" {
  security_group_id            = aws_security_group.transactional_database_sg.id
  description                  = "Access Postgres from Lambda Insert Fake Data"
  ip_protocol                  = "-1"
  referenced_security_group_id = aws_security_group.insert_fake_data_sg.id
}

resource "random_password" "postgres_transactional_root_password" {
  length           = 16
  special          = true
  override_special = "!$-+<>:"
}

resource "random_password" "postgres_transactional_fake_data_password" {
  length           = 16
  special          = true
  override_special = "!$-+<>:"
}

resource "aws_db_parameter_group" "transactional" {
  name        = "transactional-database"
  family      = "postgres15"
  description = "Transactional Database Replication Parameter Group"

  parameter {
    name         = "rds.logical_replication"
    value        = "1"
    apply_method = "pending-reboot"
  }
  parameter {
    name         = "shared_preload_libraries"
    value        = "1"
    apply_method = "pg_stat_statements,pglogical"
  }
}

resource "aws_db_instance" "transactional" {
  #tfsec:aws-rds-encrypt-instance-storage-data
  # Não estamos criptografando storage por questões de custo
  # mas em produção isso deveria ser feito.
  allocated_storage       = 20
  db_name                 = local.transactional_database
  identifier              = "transactional"
  multi_az                = false
  engine                  = "postgres"
  engine_version          = "15.3"
  parameter_group_name    = aws_db_parameter_group.transactional.id
  instance_class          = "db.t3.micro"
  username                = local.transactional_root_user
  password                = local.transactional_root_password
  storage_type            = "gp2"
  backup_retention_period = 0
  publicly_accessible     = true #tfsec:ignore:aws-rds-no-public-db-access
  # Posteriormente foi colocado um security group
  # para permitir acesso apenas do meu IP público.
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.transactional_database_sg.id]
}


resource "null_resource" "transactional_database_setup" {
  # runs after database and security group providing external access is created
  depends_on = [aws_db_instance.transactional]
  provisioner "local-exec" {
    command = "psql -h ${aws_db_instance.transactional.address} -p ${aws_db_instance.transactional.port} -U ${local.transactional_root_user} -d transactional -f ./sources/transactional_database/prepare_database/terraform_prepare_database.sql -v user=${local.transactional_fake_data_user} -v password='${local.transactional_fake_data_password}'"
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
  source  = "terraform-aws-modules/lambda/aws//modules/docker-build"
  version = "~> 6.0.0"

  create_ecr_repo = true
  ecr_repo        = "insert_fake_data"
  image_tag       = "1.0"
  source_path     = "${local.module_path}/insert_fake_data/"
  platform        = "linux/arm64"
}


resource "aws_iam_role" "execute_fake_data_app_lambda" {
  name = "execute_fake_data_app_lambda_role"

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

resource "aws_security_group" "insert_fake_data_sg" {
  name        = "insert_fake_data_sg"
  description = "Allow Access to Transactional Database"
  timeouts {
    delete = "2m"
  }
}


resource "aws_vpc_security_group_egress_rule" "lambda_insert_fake_data_egress" {
  security_group_id            = aws_security_group.insert_fake_data_sg.id
  description                  = "Access Transactional Postgres Database"
  ip_protocol                  = "-1"
  referenced_security_group_id = aws_security_group.transactional_database_sg.id
}

module "lambda_function" {
  source     = "terraform-aws-modules/lambda/aws"
  version    = "~> 6.0.0"
  depends_on = [null_resource.transactional_database_setup]

  function_name  = "insert_fake_data"
  create_package = false

  image_uri     = module.docker_image.image_uri
  package_type  = "Image"
  create_role   = false
  lambda_role   = aws_iam_role.execute_fake_data_app_lambda.arn
  architectures = ["arm64"]
  memory_size   = 256
  timeout       = 60
  environment_variables = {
    postgres_app_username = local.transactional_fake_data_user
    postgres_app_password = local.transactional_fake_data_password
    postgres_host         = aws_db_instance.transactional.address
    postgres_database     = local.transactional_database
    postgres_port         = aws_db_instance.transactional.port
  }

  vpc_subnet_ids         = data.aws_subnets.all.ids
  vpc_security_group_ids = [aws_security_group.insert_fake_data_sg.id]
}
