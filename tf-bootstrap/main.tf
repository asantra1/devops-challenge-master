
terraform {
  required_version = ">=0.15"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
provider "aws" {
  region = "eu-west-2"
}
resource "aws_s3_bucket" "terraform_state" {
  bucket = "asantra1-terraform-state"

  # Enable versioning so we can see the full revision history of our # state files
  versioning {
    enabled = true
  }

  # Enable server-side encryption by default

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "asantra1-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}