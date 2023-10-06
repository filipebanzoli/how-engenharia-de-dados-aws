provider "aws" {
  region = "us-east-1" # Change to your desired region
}
# Configura a conta
data "aws_caller_identity" "current" {}

# Busca a conta  AWS Account ID
locals {
  aws_account_id = data.aws_caller_identity.current.account_id
}
resource "aws_s3_bucket" "MyBucket" {
  bucket = "${data.aws_caller_identity.current.account_id}-team-c"
}

resource "random_password" "postgres_transactional_root_password" {
  length           = 16
  special          = true
  override_special = "!$-+<>:"
}

resource "aws_db_instance" "MyDBInstance" {
  db_name              = "transactional"
  identifier           = "transactional"
  allocated_storage    = 20
  instance_class       = "db.t3.micro"
  engine               = "postgres"
  engine_version       = "14.7"
  multi_az             = false
  parameter_group_name = aws_db_parameter_group.MyDBParameterGroup.name
  username      = "postgres"
  password      = random_password.postgres_transactional_root_password.result
  storage_type            = "gp2"
  backup_retention_period = 0
  publicly_accessible     = true
  skip_final_snapshot     = true
}
resource "aws_db_parameter_group" "MyDBParameterGroup" {
  family      = "postgres14"
  description = "My DB parameter group"

  parameter {
    name  = "rds.logical_replication"
    value = "1"
    apply_method = "pending-reboot" # Adicionado apply_method
  }

  parameter {
    name  = "shared_preload_libraries"
    value = "pg_stat_statements,pglogical"
    apply_method = "pending-reboot" # Adicionado apply_method
  }
}


resource "aws_dms_replication_instance" "MyDMSReplicationInstance" {
  replication_instance_id = "MyDMSReplicationInstance"
  replication_instance_class = "dms.t2.micro"
  allocated_storage         = 20
  auto_minor_version_upgrade = true
  multi_az                   = false
}

resource "aws_dms_endpoint" "MyDMSSourceEndpoint" {
  endpoint_id   = "MyDMSSourceEndpoint"
  endpoint_type         = "source"
  engine_name           = "postgres"
  extra_connection_attributes = "PluginName=PGLOGICAL;"
  server_name           = aws_db_instance.MyDBInstance.endpoint
  port                  = aws_db_instance.MyDBInstance.port
  database_name         = "postgres"
  username              = "postgres"
  password      = random_password.postgres_transactional_root_password.result
}

resource "aws_iam_role" "MyDMSTargetRole" {
  name = "MyDMSTargetRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "dms.amazonaws.com",
        },
      },
    ],
  })
}

resource "aws_iam_policy" "DMSAccessToS3" {
  name        = "DMSAccessToS3"
  description = "DMS access to S3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject",
        ],
        Resource = [
          aws_s3_bucket.MyBucket.arn,
          "${aws_s3_bucket.MyBucket.arn}/*",
        ],
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "DMSAccessToS3" {
  policy_arn = aws_iam_policy.DMSAccessToS3.arn
  role       = aws_iam_role.MyDMSTargetRole.name
}

resource "aws_dms_endpoint" "MyDMSTargetEndpoint" {
  endpoint_id = "MyDMSTargetEndpoint"
  endpoint_type       = "target"
  engine_name         = "s3"

  s3_settings {
    bucket_name          = aws_s3_bucket.MyBucket.id
    bucket_folder        = "dms"
    compression_type     = "GZIP" # Alterado de "gzip" para "GZIP"
    csv_delimiter        = ","
    csv_row_delimiter    = "\n"
    service_access_role_arn = aws_iam_role.MyDMSTargetRole.arn
  }
}

resource "aws_cloudwatch_log_group" "MyLogGroup" {
  name = "encontro-7-dms-task"
}
output "replication_instance_arn" {
  value = aws_dms_replication_instance.MyDMSReplicationInstance.replication_instance_arn
}
output "source_endpoint_arn" {
  value = aws_dms_endpoint.MyDMSSourceEndpoint.endpoint_arn
}

output "target_endpoint_arn" {
  value = aws_dms_endpoint.MyDMSTargetEndpoint.endpoint_arn
}

resource "aws_dms_replication_task" "MyDMSTask" {
  replication_task_id      = "my-replication-task-id" # Adicione um ID para a tarefa de replicação aqui
  replication_instance_arn = aws_dms_replication_instance.MyDMSReplicationInstance.replication_instance_arn
  migration_type           = "cdc"
  table_mappings           = jsonencode({
    rules = [
      {
        rule-name    = "1",
        rule-action  = "include",
        rule-type    = "selection",
        object-locator = {
          schema-name = "how",
          table-name  = "%",
        },
      },
    ],
  })
  source_endpoint_arn      = aws_dms_endpoint.MyDMSSourceEndpoint.endpoint_arn
  target_endpoint_arn      = aws_dms_endpoint.MyDMSTargetEndpoint.endpoint_arn
  replication_task_settings = jsonencode({
    Logging = {
      EnableLogging   = true,
      EnableLogContext = false,
      LogComponents   = [
        {
          Id       = "FILE_FACTORY",
          Severity = "LOGGER_SEVERITY_DEFAULT",
        },
        {
          Id       = "METADATA_MANAGER",
          Severity = "LOGGER_SEVERITY_DEFAULT",
        },
        {
          Id       = "SORTER",
          Severity = "LOGGER_SEVERITY_DEFAULT",
        },
        {
          Id       = "SOURCE_CAPTURE",
          Severity = "LOGGER_SEVERITY_DEFAULT",
        },
        {
          Id       = "SOURCE_UNLOAD",
          Severity = "LOGGER_SEVERITY_DEFAULT",
        },
        {
          Id       = "TABLES_MANAGER",
          Severity = "LOGGER_SEVERITY_DEFAULT",
        },
        {
          Id       = "TARGET_APPLY",
          Severity = "LOGGER_SEVERITY_DEFAULT",
        },
        {
          Id       = "TARGET_LOAD",
          Severity = "LOGGER_SEVERITY_INFO",
        },
        {
          Id       = "TASK_MANAGER",
          Severity = "LOGGER_SEVERITY_DEBUG",
        },
        {
          Id       = "TRANSFORMATION",
          Severity = "LOGGER_SEVERITY_DEBUG",
        },
      ],
    },
  })
}