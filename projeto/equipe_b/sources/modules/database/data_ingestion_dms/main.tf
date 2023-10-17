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
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}

# When importing this module, don't forget to configure
# in your main.tf the desired region and your teams's
# tag. For example:
#
# provider "aws" {
#   region = "us-east-1"
#   default_tags {
#     tags = {
#       Owner = "equipe_b"
#     }
#   }
# }

locals {
  transactional_replication_user     = "replication_app"
  transactional_replication_password = random_password.postgres_transactional_replication_password.result
}


variable "aws_db_instance_transactional_database" {
  type        = string
  description = "Transactional RDS Database Database Name"
}

variable "aws_db_instance_transactional_address" {
  type        = string
  description = "Transactional RDS Database Address"
}

variable "aws_db_instance_transactional_port" {
  type        = string
  description = "Transactional RDS Database Port"
}

variable "aws_db_instance_transactional_root_user" {
  type        = string
  description = "Transactional RDS Database User"
}

variable "aws_db_instance_transactional_root_password" {
  type        = string
  description = "Transactional RDS Database Password"
}

variable "aws_s3_bucket_data_lake" {
  type        = string
  description = "Data Lake S3 Bucket Name"
}

variable "aws_security_group_dms_sg" {
  type        = string
  description = "AWS Security Group DMS"
}

data "aws_vpc" "default" {
  default = true
}

resource "random_password" "postgres_transactional_replication_password" {
  length           = 16
  special          = true
  override_special = "!$-<>:"
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

# Database Migration Service requires the below IAM Roles to be created before
# replication instances can be created. See the DMS Documentation for
# additional information: https://docs.aws.amazon.com/dms/latest/userguide/security-iam.html#CHAP_Security.APIRole
#  * dms-vpc-role
#  * dms-cloudwatch-logs-role
#  * dms-access-for-endpoint

data "aws_iam_policy_document" "dms_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["dms.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "dms-access-for-endpoint" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-access-for-endpoint"
}

resource "aws_iam_role_policy_attachment" "dms-access-for-endpoint-AmazonDMSRedshiftS3Role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSRedshiftS3Role"
  role       = aws_iam_role.dms-access-for-endpoint.name
}

resource "aws_iam_role" "dms-cloudwatch-logs-role" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-cloudwatch-logs-role"
}

resource "aws_iam_role_policy_attachment" "dms-cloudwatch-logs-role-AmazonDMSCloudWatchLogsRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"
  role       = aws_iam_role.dms-cloudwatch-logs-role.name
}

resource "aws_iam_role" "dms-vpc-role" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-vpc-role"
}

resource "aws_iam_role_policy_attachment" "dms-vpc-role-AmazonDMSVPCManagementRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
  role       = aws_iam_role.dms-vpc-role.name
}

resource "time_sleep" "wait_20_seconds" {
  # sleeping due to the fact that it needs
  # some time after the creation of the roles
  # for the dms replication instance to be
  # ready for use.
  create_duration = "20s"
}


# Create a new replication instance
resource "aws_dms_replication_instance" "dms_default_instance" {
  allocated_storage           = 5
  engine_version              = "3.5.1"
  multi_az                    = false
  replication_instance_class  = "dms.t2.micro"
  replication_instance_id     = "dms-default-instance"
  allow_major_version_upgrade = true

  vpc_security_group_ids = [
    var.aws_security_group_dms_sg
  ]

  depends_on = [
    aws_iam_role_policy_attachment.dms-access-for-endpoint-AmazonDMSRedshiftS3Role,
    aws_iam_role_policy_attachment.dms-cloudwatch-logs-role-AmazonDMSCloudWatchLogsRole,
    aws_iam_role_policy_attachment.dms-vpc-role-AmazonDMSVPCManagementRole,
    time_sleep.wait_20_seconds
  ]
}


resource "aws_dms_endpoint" "rds_transactional" {
  endpoint_id                 = "rds-transactional"
  endpoint_type               = "source"
  engine_name                 = "postgres"
  extra_connection_attributes = "PluginName=PGLOGICAL"
  server_name                 = var.aws_db_instance_transactional_address
  database_name               = var.aws_db_instance_transactional_database
  port                        = var.aws_db_instance_transactional_port
  username                    = local.transactional_replication_user
  password                    = local.transactional_replication_password
}

resource "aws_iam_role" "s3_dms_target_role" {
  name = "s3_dms_target_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "dms.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "allow_s3_access"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = ["s3:PutObject",
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:DeleteObject",
          "s3:PutObjectTagging"]
          Resource = ["arn:aws:s3:::${var.aws_s3_bucket_data_lake}",
          "arn:aws:s3:::${var.aws_s3_bucket_data_lake}/*"]
        }
      ]
    })
  }
}

resource "aws_dms_s3_endpoint" "s3_datalake_transactional" {
  endpoint_id             = "s3-datalake"
  endpoint_type           = "target"
  data_format             = "csv"
  bucket_folder           = "bronze"
  bucket_name             = var.aws_s3_bucket_data_lake
  compression_type        = "GZIP"
  csv_delimiter           = ","
  csv_row_delimiter       = "\n"
  rfc_4180                = true
  service_access_role_arn = aws_iam_role.s3_dms_target_role.arn
}

resource "aws_dms_replication_task" "transactional_database_to_datalake" {
  migration_type           = "full-load-and-cdc"
  replication_instance_arn = aws_dms_replication_instance.dms_default_instance.replication_instance_arn
  replication_task_id      = "transactional-database-to-datalake"
  replication_task_settings = jsonencode({
    Logging : {
      EnableLogging : true
      LogComponents : [
        {
          Id : "TRANSFORMATION"
          Severity : "LOGGER_SEVERITY_DEBUG"
        },
        {
          Id : "SOURCE_UNLOAD"
          Severity : "LOGGER_SEVERITY_DEFAULT"
        },
        {
          Id : "IO"
          Severity : "LOGGER_SEVERITY_DEFAULT"
        },
        {
          Id : "TARGET_LOAD"
          Severity : "LOGGER_SEVERITY_INFO"
        },
        {
          Id : "PERFORMANCE"
          Severity : "LOGGER_SEVERITY_DEFAULT"
        },
        {
          Id : "SOURCE_CAPTURE"
          Severity : "LOGGER_SEVERITY_DEFAULT"
        },
        {
          Id : "SORTER"
          Severity : "LOGGER_SEVERITY_DEFAULT"
        },
        {
          Id : "REST_SERVER"
          Severity : "LOGGER_SEVERITY_DEFAULT"
        },
        {
          Id : "VALIDATOR_EXT"
          Severity : "LOGGER_SEVERITY_DEFAULT"
        },
        {
          Id : "TARGET_APPLY"
          Severity : "LOGGER_SEVERITY_DEFAULT"
        },
        {
          Id : "TASK_MANAGER"
          Severity : "LOGGER_SEVERITY_DEBUG"
        },
        {
          Id : "TABLES_MANAGER"
          Severity : "LOGGER_SEVERITY_DEFAULT"
        },
        {
          Id : "METADATA_MANAGER"
          Severity : "LOGGER_SEVERITY_DEFAULT"
        },
        {
          Id : "FILE_FACTORY"
          Severity : "LOGGER_SEVERITY_DEFAULT"
        },
        {
          Id : "COMMON"
          Severity : "LOGGER_SEVERITY_DEFAULT"
        },
        {
          Id : "ADDONS"
          Severity : "LOGGER_SEVERITY_DEFAULT"
        },
        {
          Id : "DATA_STRUCTURE"
          Severity : "LOGGER_SEVERITY_DEFAULT"
        },
        {
          Id : "COMMUNICATION"
          Severity : "LOGGER_SEVERITY_DEFAULT"
        },
        {
          Id : "FILE_TRANSFER"
          Severity : "LOGGER_SEVERITY_DEFAULT"
        }
      ]
    },
  })
  source_endpoint_arn = aws_dms_endpoint.rds_transactional.endpoint_arn
  table_mappings = jsonencode({
    "rules" = [{
      "rule-name" = "1"
      "rule-type" = "selection"
      "rule-id"   = "1"
      "object-locator" = {
        "schema-name" = "transactional"
        "table-name"  = "%"
      }
      "rule-action" = "include"
    }] }
  )
  target_endpoint_arn = aws_dms_s3_endpoint.s3_datalake_transactional.endpoint_arn

  ## For time saving purposes, and in order to not store
  ## the complete replication task settings here
  ## I end up ignoring this argument changes
  ## For more info consult here:
  ## https://github.com/hashicorp/terraform-provider-aws/issues/1513
  lifecycle {
    ignore_changes = [replication_task_settings]
  }
}

resource "aws_vpc_endpoint" "private_s3" {
  vpc_id            = data.aws_vpc.default.id
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"

  tags = {
    Name = "s3-endpoint"
  }
}

data "aws_route_tables" "rts" {
  vpc_id = data.aws_vpc.default.id
  filter {
    name   = "association.main"
    values = [true]
  }
}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  vpc_endpoint_id = aws_vpc_endpoint.private_s3.id
  route_table_id  = element(data.aws_route_tables.rts.ids, 1)
}

resource "aws_vpc_security_group_egress_rule" "dms_egress_to_s3" {
  security_group_id = var.aws_security_group_dms_sg
  description       = "Access to S3 from VPN"
  ip_protocol       = "TCP"
  from_port         = 443
  to_port           = 443
  prefix_list_id    = aws_vpc_endpoint.private_s3.prefix_list_id
}
