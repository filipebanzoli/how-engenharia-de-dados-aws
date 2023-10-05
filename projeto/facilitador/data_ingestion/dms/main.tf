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

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Owner = "facilitador"
    }
  }
}

locals {
  transactional_replication_user   = "replication_app"
  transactional_replication_password   = random_password.postgres_transactional_replication_password.result
}


variable "aws_db_instance_transactional_address" {
  type       = string
  description = "Transactional RDS Database Address"
}

variable "aws_db_instance_transactional_port" {
  type       = string
  description = "Transactional RDS Database Port"
}

variable "aws_db_instance_transactional_root_user" {
  type       = string
  description = "Transactional RDS Database User"
}

variable "aws_db_instance_transactional_root_password" {
  type       = string
  description = "Transactional RDS Database Password"
}


resource "random_password" "postgres_transactional_replication_password" {
  length           = 16
  special          = true
  override_special = "!$-+<>:"
}

resource "null_resource" "transactional_replication_setup" {
  # runs after database and security group providing external access is created
  provisioner "local-exec" {
    command = "psql -h ${var.aws_db_instance_transactional_address} -p ${var.aws_db_instance_transactional_port} -U ${var.aws_db_instance_transactional_root_user} -d transactional -f ${path.module}/configure_replication.sql -v user=${local.transactional_replication_user} -v password='${local.transactional_replication_password}'"
    environment = {
      PGPASSWORD = var.aws_db_instance_transactional_root_password
    }
  }
}

