terraform {

  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
     airbyte = {
      source  = "airbytehq/airbyte"
      version = "0.3.4"
    }
  }
}
  
provider "aws" {
  profile = "default"
}


locals {
  airbyte_api_key = var.airbyte_api_key
  google_service_account = file(var.google_service_account)
  google_sheets_url = var.google_sheets_url
}


provider "airbyte" {
  // If running on Airbyte Cloud, 
  // generate & save your API key from https://portal.airbyte.com
  bearer_auth = "${local.airbyte_api_key}"
  
  // If running locally (Airbyte OSS) with docker-compose using the airbyte-proxy, 
  // include the actual password/username you've set up (or use the defaults below)
  # password = ""
  # username = ""
  
  // if running locally (Airbyte OSS), include the server url to the airbyte-api-server
  # server_url = "http://localhost:8006/v1/" // (and UI is at http://airbyte.company.com:8000)
}

module "worksheet" {
  source = "./sources/worksheet"
  airbyte_api_key = "${local.airbyte_api_key}"
  google_service_account = "${local.google_service_account}"
  google_sheets_url = "${local.google_sheets_url}"

}

module "etl_airbyte" {
  source = "./sources/etl_airbyte"
  airbyte_api_key = "${local.airbyte_api_key}"
  google_service_account = "${local.google_service_account}"
  google_sheets_url = "${local.google_sheets_url}"
  aws_s3_bucket_data_lake_production = module.worksheet.aws_s3_bucket_data_lake_production
}
