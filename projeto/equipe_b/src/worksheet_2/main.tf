terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
  default_tags {
    tags = {
      Owner = "equipe_b"
    }
  }
}

resource "aws_iam_user" "lb" {
  name = "my_iam_at_bucket"
  path = "/system/"
}

resource "aws_iam_access_key" "lb" {
  user = aws_iam_user.lb.name
}

data "aws_iam_policy_document" "lb_ro" {
  statement {
    effect    = "Allow"
    actions   = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:PutObjectAcl",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation"
    ]
      resources = [aws_s3_bucket.my_first_tf_s3.arn, "${aws_s3_bucket.my_first_tf_s3.arn}/*"]
      # resources = ["arn:aws:s3:::bucket-s3-test-abcd-mhe", "arn:aws:s3:::bucket-s3-test-abcd-mhe/*"]      
    }
}

resource "aws_iam_user_policy" "lb_ro" {
  name   = "s3_bucket_policy"
  user   = aws_iam_user.lb.name
  policy = data.aws_iam_policy_document.lb_ro.json
}

resource "aws_s3_bucket" "my_first_tf_s3" {
  bucket = "bucket-s3-test-abcd-mhe"
}

resource "aws_s3_bucket_public_access_block" "my_first_tf_s3_access_block" {
  bucket = aws_s3_bucket.my_first_tf_s3.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_secretsmanager_secret" "s3_credentials" {
  name = "s3_credentials"
}

resource "aws_secretsmanager_secret_version" "s3_credentials_version" {
  secret_id     = aws_secretsmanager_secret.s3_credentials.id
  secret_string = jsonencode({
    access_key = aws_iam_access_key.lb.id
    secret_key = aws_iam_access_key.lb.secret
  })
}


# terraform {
#   required_version = ">= 1.0"
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 5.0"
#     }
#   }
# }

# # Configure the AWS Provider
# provider "aws" {
#   region = "us-west-2"
#   default_tags {
#     tags = {
#       Owner = "equipe_b"
#     }
#   }
# }


# resource "aws_s3_bucket" "my_first_tf_s3" {
#   bucket = "my-tf-test-bucket-abcd"
# }

# resource "aws_s3_bucket_public_access_block" "my_first_tf_s3_access_block" {
#   bucket = aws_s3_bucket.my_first_tf_s3.id

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

# # ====== 

# # Aqui define o IAM
# resource "aws_iam_user" "lb" {
#   name = "my_iam_at_bucket"
#   path = "/system/"
# }

# # Chave de acesso para serviços externos
# resource "aws_iam_access_key" "lb" {
#   user = aws_iam_user.lb.name
# }

# # Define a política
# data "aws_iam_policy_document" "lb_ro" {
#   statement {
#     effect    = "Allow"
#     actions   = [
#       "s3:PutObject",
#       "s3:GetObject",
#       "s3:DeleteObject",
#       "s3:PutObjectAcl",
#       "s3:ListBucket",
#       "s3:ListBucketMultipartUploads",
#       "s3:AbortMultipartUpload",
#       "s3:GetBucketLocation"
#     ]
#     resources = [aws_s3_bucket.my_first_tf_s3.arn, "${aws_s3_bucket.my_first_tf_s3.arn}/*"]
#   }
# }

# # Cria a 'role', associa a política ao usuário 
# resource "aws_iam_user_policy" "lb_ro" {
#   name   = "s3_bucket_policy"
#   user   = aws_iam_user.lb.name
#   policy = data.aws_iam_policy_document.lb_ro.json
# }

# # destination airbyte