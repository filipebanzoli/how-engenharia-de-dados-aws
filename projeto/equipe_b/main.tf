terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


module "s3_bucket" {
  source                = "./sources/modules/worksheet"
  aws_access_key_id     = var.aws_access_key_id
  aws_session_token     = var.aws_session_token
  aws_access_secret_key = var.aws_access_secret_key
}

# Configure the AWS Provider 
provider "aws" {

  region = "us-east-1"
  default_tags {
    tags = {
      Owner = "my-bucket-equipe-b"
    }
  }
}

# module "transactional_data_ingestion" {
#   source                                      = "./sources/modules/database/data_ingestion_dms"
#   aws_db_instance_transactional_database      = module.transactional_database.aws_db_instance_transactional_database
#   aws_db_instance_transactional_address       = module.transactional_database.aws_db_instance_transactional_address
#   aws_db_instance_transactional_port          = module.transactional_database.aws_db_instance_transactional_port
#   aws_db_instance_transactional_root_user     = module.transactional_database.aws_db_instance_transactional_root_user
#   aws_db_instance_transactional_root_password = module.transactional_database.aws_db_instance_transactional_root_password
#   aws_s3_bucket_data_lake                     = module.worksheet.aws_s3_bucket_data_lake
#   aws_security_group_dms_sg                   = module.transactional_database.aws_security_group_dms_sg
# }