provider "aws" {
  access_key                  = "test123"
  secret_key                  = "testabc"
  region                      = "us-east-1"
  # s3_force_path_style         = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    apigateway     = "http://localhost:4566"
    cloudformation = "http://localhost:4566"
    cloudwatch     = "http://localhost:4566"
    dynamodb       = "http://localhost:4566"
    ec2            = "http://localhost:4566"
    es             = "http://localhost:4566"
    elasticache    = "http://localhost:4566"
    firehose       = "http://localhost:4566"
    iam            = "http://localhost:4566"
    kinesis        = "http://localhost:4566"
    lambda         = "http://localhost:4566"
    rds            = "http://localhost:4566"
    redshift       = "http://localhost:4566"
    route53        = "http://localhost:4566"
    s3             = "http://localhost:4566"
    secretsmanager = "http://localhost:4566"
    ses            = "http://localhost:4566"
    sns            = "http://localhost:4566"
    sqs            = "http://localhost:4566"
    ssm            = "http://localhost:4566"
    stepfunctions  = "http://localhost:4566"
    sts            = "http://localhost:4566"
  }
}

# Cria o bucket S3
resource "aws_s3_bucket" "data-lake" {
  bucket = "data-lake"
}

# Configura os acessos publcios ao bucket S3 criado
resource "aws_s3_bucket_public_access_block" "data_lake" {
  bucket = aws_s3_bucket.data-lake.id

  block_public_acls       = true 
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# cria o usuario para acessar o S3
resource "aws_iam_user" "user1" {
  name = "user1"
  path = "/system/"
}

# cria uma access key, que permite o usuario faca requests para o S3
resource "aws_iam_access_key" "user1" {
  user    = aws_iam_user.user1.name
}

# cria um policy atrelada ao usuario com permissao de acesso ao S3
resource "aws_iam_user_policy" "user1" {
  name = "user1-policy-s3"
  user = aws_iam_user.user1.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
