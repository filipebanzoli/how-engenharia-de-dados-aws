
variable "aws_lambda_enrich_arn" {
  type        = string
  description = "Lambda firehose arn configuration"
}

resource "aws_kinesis_stream" "enriched_stream" {
  name        = "enriched-stream"
  shard_count = 1
}

resource "aws_cloudwatch_log_group" "kinesis_firehose_stream_logging_group" {
  name = "/aws/kinesisfirehose/enriched-firehose"
}

resource "aws_cloudwatch_log_stream" "kinesis_firehose_stream_logging_stream" {
  log_group_name = aws_cloudwatch_log_group.kinesis_firehose_stream_logging_group.name
  name           = "S3Delivery"
}

# Crie um Firehose Delivery Stream
resource "aws_kinesis_firehose_delivery_stream" "enriched_firehose" {
  name        = "enriched-firehose"
  destination = "extended_s3"
  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.enriched_stream.arn
    role_arn           = aws_iam_role.firehose_role.arn
  }
  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = aws_s3_bucket.enrich_data_bucket.arn
    dynamic_partitioning_configuration {
      enabled = "false"
    }
    prefix              = "data/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
    error_output_prefix = "errors/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/!{firehose:error-output-type}/"
    buffering_size      = 1
    buffering_interval  = 60
    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.kinesis_firehose_stream_logging_group.name
      log_stream_name = aws_cloudwatch_log_stream.kinesis_firehose_stream_logging_stream.name
    }
    processing_configuration {
      enabled = "true"

      processors {
        type = "Lambda"

        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${var.aws_lambda_enrich_arn}:$LATEST"
        }
      }
    }
  }
}

# data "aws_kinesis_stream_consumer" "enriched-consumer" {
#   name       = "enriched-consumer"
#   arn = aws_kinesis_firehose_delivery_stream.enriched_firehose.arn
#   stream_arn = aws_kinesis_stream.enriched_stream.arn
# }

resource "aws_s3_bucket" "enrich_data_bucket" {
  bucket = "enrich-data-666198551639"
}

data "aws_iam_policy_document" "firehose_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "firehose_role" {
  name               = "firehose_role"
  assume_role_policy = data.aws_iam_policy_document.firehose_assume_role.json
}

resource "aws_iam_role" "kinesis_role" {
  name = "kinesis_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "dms.amazonaws.com"
        }
      }
    ]
  })
}

data "aws_iam_policy_document" "kinesis_consumer_role" {
  statement {
    effect = "Allow"

    actions = [
      "kinesis:*"
    ]

    resources = [
      aws_kinesis_stream.enriched_stream.arn
    ]
  }
}

resource "aws_iam_policy" "kinesis_consumer_role_policy" {
  name   = "kinesis_consumer_role_policy"
  policy = data.aws_iam_policy_document.kinesis_consumer_role.json
}

resource "aws_iam_role_policy_attachment" "kinesis_consumer_role_policy-attach" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.kinesis_consumer_role_policy.arn
}

data "aws_iam_policy_document" "kinesis_firehose_access_lambda" {
  statement {
    effect = "Allow"

    actions = [
      "lambda:InvokeFunction",
      "lambda:GetFunctionConfiguration",
    ]

    resources = [
      var.aws_lambda_enrich_arn,
      "${var.aws_lambda_enrich_arn}:*"
    ]
  }
}

resource "aws_iam_policy" "kinesis_firehose_lambda" {
  name   = "kinesis_firehose_lambda"
  policy = data.aws_iam_policy_document.kinesis_firehose_access_lambda.json
}

resource "aws_iam_role_policy_attachment" "kinesis_firehose_lambda-attach" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.kinesis_firehose_lambda.arn
}

data "aws_iam_policy_document" "kinesis_firehose_access_bucket_assume_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.enrich_data_bucket.arn,
      "${aws_s3_bucket.enrich_data_bucket.arn}/*",
    ]
  }
}

resource "aws_iam_policy" "kinesis_firehose_access_bucket_assume_policy_s3" {
  name   = "kinesis_firehose_access_bucket_assume_policy_s3"
  policy = data.aws_iam_policy_document.kinesis_firehose_access_bucket_assume_policy.json
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.kinesis_firehose_access_bucket_assume_policy_s3.arn
}

resource "aws_iam_policy_attachment" "kinesis_attachment" {
  name       = "kinesis_attachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonKinesisFullAccess"
  roles      = [aws_iam_role.kinesis_role.name]
}

resource "aws_dms_endpoint" "transactional_database_to_kinesis" {
  endpoint_id   = "kinesis-target"
  endpoint_type = "target"
  engine_name   = "kinesis"
  kinesis_settings {
    message_format          = "json"
    service_access_role_arn = aws_iam_role.kinesis_role.arn
    stream_arn              = aws_kinesis_stream.enriched_stream.arn
  }
}

resource "aws_dms_replication_task" "transactional_database_to_kinesis" {
  migration_type           = "cdc"
  replication_instance_arn = aws_dms_replication_instance.dms_default_instance.replication_instance_arn
  replication_task_id      = "transactional-database-to-kinesis"
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
  target_endpoint_arn = aws_dms_endpoint.transactional_database_to_kinesis.endpoint_arn
  ## For time saving purposes, and in order to not store
  ## the complete replication task settings here
  ## I end up ignoring this argument changes
  ## For more info consult here:
  ## https://github.com/hashicorp/terraform-provider-aws/issues/1513
  lifecycle {
    ignore_changes = [replication_task_settings]
  }
}
