# Terraform Configuration for STAGING Environment
# Tạo S3 bucket và CloudFront distribution

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
  
  # Enable CloudFront for staging
  enable_cloudfront = true
  
  # Tags
  tags = var.tags
}

# Blue-Green Deployment - Create additional bucket for green environment
module "storage_green" {
  source = "../../modules/storage"

  environment   = "${var.environment}-green"
  project_name  = var.project_name
  bucket_prefix = "${var.bucket_prefix}-green"
  
  enable_versioning = true
  enable_lifecycle  = true
  
  tags = merge(var.tags, {
    DeploymentType = "Green"
  })
}

# Data source để lấy thông tin account
data "aws_caller_identity" "current" {}

# Output cho blue environment
output "bucket_name" {
  description = "Name of the blue S3 bucket"
  value       = module.storage.bucket_name
}

output "bucket_arn" {
  description = "ARN of the blue S3 bucket"
  value       = module.storage.bucket_arn
}

# Output cho green environment
output "green_bucket_name" {
  description = "Name of the green S3 bucket"
  value       = module.storage_green.bucket_name
}

output "green_bucket_arn" {
  description = "ARN of the green S3 bucket"
  value       = module.storage_green.bucket_arn
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.storage.cloudfront_distribution_id
}

output "deployment_info" {
  description = "Deployment information"
  value = {
    environment      = var.environment
    region           = var.aws_region
    account_id       = data.aws_caller_identity.current.account_id
    blue_bucket      = module.storage.bucket_name
    green_bucket     = module.storage_green.bucket_name
    deployment_type  = "blue-green"
    deployed_at      = timestamp()
  }
}
