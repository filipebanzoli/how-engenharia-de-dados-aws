terraform {
  required_version = ">= 1.0"
  required_providers {
    airbyte = {
      source  = "airbytehq/airbyte"
      version = "0.3.4"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region = data.aws_region.current.name
  google_service_account = "${path.module}/how-edu-e4127a9bda61-google-service-account.json"
  google_sheets_url = var.google_sheets_url
}

resource "aws_iam_user" "airbyte_user" {
  name = "airbyte_user"
}

resource "aws_iam_access_key" "s3" {
  user    = aws_iam_user.airbyte_user.name
  # pgp_key = "keybase:some_person_that_exists"
}

resource "aws_secretsmanager_secret" "secret_aws_s3_airbyte" {
  name = "secrets_aws_s3_airbyte"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "secret_aws_s3_airbyte" {
  secret_id     = "${aws_secretsmanager_secret.secret_aws_s3_airbyte.id}"
  secret_string = jsonencode({"AccessKey" = aws_iam_access_key.s3.id, "SecretAccessKey" = aws_iam_access_key.s3.secret})
}


resource "aws_iam_user_policy" "permission_airbyte_s3" {
  name = "auth-airbyte-access-s3"
  user = aws_iam_user.airbyte_user.name

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
  Version = "2012-10-17"
  Statement = [
    {
      Action = [
        "s3:*"
      ]
      Effect = "Allow"
      Resource = [
        "arn:aws:s3:::${var.aws_s3_bucket_data_lake_production}/*",
        "arn:aws:s3:::${var.aws_s3_bucket_data_lake_production}",
      ]
    },
  ]
  })
}

# configurando o source
resource "airbyte_source_google_sheets" "my_source_googlesheets" {
  configuration = {
    credentials = {
        source_google_sheets_authentication_service_account_key_authentication = {
        auth_type     = "Service"
        service_account_info = "${local.google_service_account}"
      }
    }
    source_type      = "google-sheets"
    spreadsheet_id   = "${local.google_sheets_url}"
  }
  name         = "Origem dos dados"
  workspace_id = "9b450e8f-60ab-4013-bf9a-d29b3b05c9b6"
}

# configurando o destination
resource "airbyte_destination_s3" "my_destination_s3" {
  configuration = {
    access_key_id     = jsondecode(aws_secretsmanager_secret_version.secret_aws_s3_airbyte.secret_string)["AccessKey"]
    destination_type  = "s3"
    format = {
      destination_s3_output_format_parquet_columnar_storage ={
        format_type = "Parquet"
        }
    }
    s3_bucket_name    = "bucket-tf-${local.aws_account_id}-equipe-d"
    s3_bucket_path    = "data"
    s3_bucket_region  = "${local.aws_region}"
    secret_access_key = jsondecode(aws_secretsmanager_secret_version.secret_aws_s3_airbyte.secret_string)["SecretAccessKey"]
  }
  name         = "Destinos"
  workspace_id = "9b450e8f-60ab-4013-bf9a-d29b3b05c9b6"
}
# creating a connection between source and destination
resource "airbyte_connection" "my_connection_source_destination" {
  name                 = "GSheets > S3"
  source_id            = "48352dea-8831-4fdc-a0f3-1b1d44f58a3b"
  destination_id       = "18599f67-f066-4152-bd51-99fe5b0bac70"
  status               = "active"
  configurations       = {
     streams = [
      {
        name = "ecommerce_dataset_kaggle"
      }
    ]
  }  
  schedule = {
    schedule_type = "manual"
  }
}