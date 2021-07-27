variable "region" {
  type        = string
  description = "AWS region where resources will be provisioned"
  default     = "eu-west-2"
}

variable "s3_bucket_name" {
  type        = string
  description = "S3 bucket to keep the terraform state file"
  default     = "asantra1-terraform-state"
}

variable "dynamodb_lock_table_name" {
  type        = string
  description = "DynamoDB lock table name"
  default     = "asantra1-running-locks"
}

