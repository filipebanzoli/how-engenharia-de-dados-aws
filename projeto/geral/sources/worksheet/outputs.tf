
output "aws_s3_bucket_data_lake" {
  description = "Data Lake S3 Bucket Name"
  value       = aws_s3_bucket.data_lake.id
}
