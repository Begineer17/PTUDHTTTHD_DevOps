# Variables for Storage Module

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "bucket_prefix" {
  description = "Prefix for bucket name"
  type        = string
}

variable "enable_versioning" {
  description = "Enable versioning for rollback capability"
  type        = bool
  default     = true
}

variable "enable_lifecycle" {
  description = "Enable lifecycle policies"
  type        = bool
  default     = true
}

variable "enable_cloudfront" {
  description = "Enable CloudFront distribution"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
