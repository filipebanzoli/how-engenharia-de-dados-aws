# variable "aws_access_key_id" {
#   type        = string
#   description = "AWS Access Key"
# }

# variable "aws_access_secret_key" {
#   type        = string
#   description = "AWS Access Secret Key"
# }

# variable "aws_session_token" {
#   type        = string
#   description = "AWS Session Token"
# }

# variable "aws_region" {
#   type        = string
#   default     = "sa-east-1"
#   description = "Region"
# }

# variable "aws_bucket_name" {
#   type        = string  
#   description = "Bucket Name"
# }

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
}