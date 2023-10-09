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

module "transactional_database" {
  source = "../geral/sources/transactional_database"
}

module "worksheet" {
  source = "./sources/worksheet"
}

module "transactional_data_ingestion" {
  source                                      = "../geral/data_ingestion/dms"
  aws_db_instance_transactional_database      = module.transactional_database.aws_db_instance_transactional_database
  aws_db_instance_transactional_address       = module.transactional_database.aws_db_instance_transactional_address
  aws_db_instance_transactional_port          = module.transactional_database.aws_db_instance_transactional_port
  aws_db_instance_transactional_root_user     = module.transactional_database.aws_db_instance_transactional_root_user
  aws_db_instance_transactional_root_password = module.transactional_database.aws_db_instance_transactional_root_password
  aws_s3_bucket_data_lake                     = module.worksheet.aws_s3_bucket_data_lake
  aws_security_group_dms_sg                   = module.transactional_database.aws_security_group_dms_sg
}
