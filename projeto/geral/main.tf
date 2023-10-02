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

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Owner = "geral"
    }
  }
}

module "transactional_database" {
  source = "./sources/transactional_database"
}

module "worksheet" {
  source = "./sources/worksheet"
}
