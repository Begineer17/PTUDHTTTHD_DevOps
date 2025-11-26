# Terraform Configuration for DEV Environment
# Tạo S3 bucket để lưu trữ static assets

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure AWS Provider
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = var.project_name
      CreatedAt   = timestamp()
    }
  }
}

# Import Storage Module
module "storage" {
  source = "../../modules/storage"

  environment   = var.environment
  project_name  = var.project_name
  bucket_prefix = var.bucket_prefix
  
  # Enable versioning for rollback capability
  enable_versioning = true
  
  # Enable lifecycle policies
  enable_lifecycle = true
  
  # Tags
  tags = var.tags
}

# Data source để lấy thông tin account
data "aws_caller_identity" "current" {}

# Output để sử dụng trong CI/CD
output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = module.storage.bucket_name
}

output "bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = module.storage.bucket_arn
}

output "bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = module.storage.bucket_domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID (if enabled)"
  value       = module.storage.cloudfront_distribution_id
}

output "deployment_info" {
  description = "Deployment information"
  value = {
    environment  = var.environment
    region       = var.aws_region
    account_id   = data.aws_caller_identity.current.account_id
    deployed_at  = timestamp()
  }
}
