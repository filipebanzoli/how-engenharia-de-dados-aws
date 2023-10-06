locals {
  aws_account_id = data.aws_caller_identity.current.account_id
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "data_lake" {
  bucket        = "data-lake-how-${local.aws_account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_user" "s3_destination_airbyte" {
  name = "s3_destination_airbyte"
}

resource "aws_iam_access_key" "s3_destination_airbyte" {
  user = aws_iam_user.s3_destination_airbyte.name
}

data "aws_iam_policy_document" "s3_destination_airbyte" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:PutObjectAcl",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation"
    ]
    resources = [aws_s3_bucket.data_lake.arn, "${aws_s3_bucket.data_lake.arn}/bronze/*"]
  }
}

resource "aws_iam_user_policy" "s3_destination_airbyte" {
  name   = "allow_s3_access"
  user   = aws_iam_user.s3_destination_airbyte.name
  policy = data.aws_iam_policy_document.s3_destination_airbyte.json
}

output "rendered" {
  value = {
    airbyte_destination_s3_access_key_id     = aws_iam_access_key.s3_destination_airbyte.id
    airbyte_destination_s3_secret_access_key = aws_iam_access_key.s3_destination_airbyte.secret
  }
  sensitive = true
}
