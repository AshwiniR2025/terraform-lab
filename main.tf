terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # This moves the state file to S3
  backend "s3" {
    bucket = "terraform-state-backened-2026" # REPLACE THIS with the bucket name you just created
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}