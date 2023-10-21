variable "aws_s3_bucket_data_lake_production" {
  type        = string  
  description = "Bucket Name"
}

variable "google_service_account" {
  type        = string  
  description = "Google Service Account Path"
}

variable "google_sheets_url" {
  type        = string  
  description = "URL Google Sheets Dataset"
}

variable "airbyte_api_key" {
  type        = string  
  description = "Airbyte API KEY"
  default = "value"
}