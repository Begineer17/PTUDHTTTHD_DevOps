# Variables for STAGING Environment

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "my-app"
}

variable "bucket_prefix" {
  description = "Prefix for S3 bucket name"
  type        = string
  default     = "my-app-staging"
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default = {
    Team        = "DevOps"
    Owner       = "Platform Team"
    CostCenter  = "Engineering"
  }
}
