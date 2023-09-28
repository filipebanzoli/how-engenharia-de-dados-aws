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

# Configure the AWS Provider
# provider "aws" {
#   region = "us-east-1"

# }

# # #S3
# resource "aws_s3_bucket" "example" {
#   bucket = "my-bucket-equipe-d"
#   tags = {
#     "key" = "equipe-d"
#   }
# }


provider "aws" {
  profile    = "default"
  region     = "us-east-1"
  access_key = var.aws_access_key_id
  secret_key = var.aws_access_secret_key
  token      = var.aws_session_token
  default_tags {
    tags = {
      Owner = "my-bucket-equipe-d"
    }
  }
}

# Configure the AWS resource
resource "aws_s3_bucket" "data-lake-production" {
  bucket = "my-bucket-equipe-d"
  tags = {
    Grupo = "my-bucket-equipe-d"
  }
}




#Airbyte

# provider "airbyte" {
#   // If running on Airbyte Cloud,
#   // generate & save your API key from https://portal.airbyte.com
#   bearer_auth = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjE2OGFhZjMxLTdhMWUtNDQyNi1iZTRlLWVlNDY4YzUyMzIxZCIsInR5cCI6IkpXVCJ9.eyJhdWQiOlsiY2xhazFzdTU5MDAwMDNiNmNqNW1tcWc4dSJdLCJjdXN0b21lcl9pZCI6ImExMTAyYzcxLTA2YzgtNDc2NS04NmI1LTU1Y2EwNGYwMWEwNCIsImVtYWlsIjoibG9ycmFucGltZW50YUBnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6ImZhbHNlIiwiZXhwIjoyNTM0MDIyMTQ0MDAsImlhdCI6MTY5NTg1MzI2NywiaXNzIjoiaHR0cHM6Ly9hcHAuc3BlYWtlYXN5YXBpLmRldi92MS9hdXRoL29hdXRoL2NsYWsxc3U1OTAwMDAzYjZjajVtbXFnOHUiLCJqdGkiOiIxNjhhYWYzMS03YTFlLTQ0MjYtYmU0ZS1lZTQ2OGM1MjMyMWQiLCJraWQiOiIxNjhhYWYzMS03YTFlLTQ0MjYtYmU0ZS1lZTQ2OGM1MjMyMWQiLCJuYmYiOjE2OTU4NTMyMDcsInNwZWFrZWFzeV9jdXN0b21lcl9pZCI6Ikg4ekFOY0xsTlJNMnBPR3RKSnFTaEVQWlNYSTIiLCJzcGVha2Vhc3lfd29ya3NwYWNlX2lkIjoiY2xhazFzdTU5MDAwMDNiNmNqNW1tcWc4dSIsInN1YiI6Ikg4ekFOY0xsTlJNMnBPR3RKSnFTaEVQWlNYSTIiLCJ1c2VyX2lkIjoiSDh6QU5jTGxOUk0ycE9HdEpKcVNoRVBaU1hJMiJ9.MYmnlo9y9EMe4HffOnXHZBM6Srf6MmtHHExOY4aaygQOmV_jQKMfe5kUmrrmhCP4afGMlyhoUymn43lCD4clqn5M4yyZStCHI1bFz0ZdWzN2y0KWneFEer2tDIiXq4oGYbojkwzj6yVD08e9JDLHwc7uKdBkqCd4MPJiAqPcpTJ3HadWP3PrACO20IJ05mV2sYtTbdkRSfYTRGgmZfT_o4kJeWyQNQikfq4elEQ95IkNqBAOGBxbGU0UUFQxIhUbbvkM6yiAeBbEuKm3ZXNqzZVqALvlKVrslkLTOC9zxdgeY2bvAIf42ybKJLQcoZRRhxLd0hmNBdlmnRQ8m-glmw"

#   // If running locally (Airbyte OSS) with docker-compose using the airbyte-proxy,
#   // include the actual password/username you've set up (or use the defaults below)
#   password = "password"
#   username = "username"

#   // if running locally (Airbyte OSS), include the server url to the airbyte-api-server
#   #server_url = "http://localhost:8006/v1/" // (and UI is at http://airbyte.company.com:8000)
# }

# resource "airbyte_destination_s3" "my_destination_s3" {
#   configuration = {
#     access_key_id     = var.aws_access_key_id
#     destination_type  = "s3"
#     file_name_pattern = "{timestamp}"
#     format = {
#       destination_s3_output_format_avro_apache_avro = {
#         compression_codec = {
#           destination_s3_output_format_avro_apache_avro_compression_codec_bzip2 = {
#             codec = "bzip2"
#           }
#         }
#         format_type = "Avro"
#       }
#     }
#     s3_bucket_name    = "my-bucket-equipe-d"
#     s3_bucket_path    = "my-bucket-equipe-d"
#     s3_bucket_region  = "us-west-1"
#    # s3_path_format    = "${NAMESPACE}/${STREAM_NAME}/${YEAR}_${MONTH}_${DAY}_${EPOCH}_"
#     secret_access_key = var.aws_access_secret_key
#   }
#   name         = "Joyce O'Kon"
#   workspace_id = "9da660ff-57bf-4aad-8f9e-fc1b4512c103"
# }
