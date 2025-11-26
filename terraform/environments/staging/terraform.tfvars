# Terraform Variables Values for STAGING Environment

aws_region    = "us-east-1"
environment   = "staging"
project_name  = "my-app"
bucket_prefix = "my-app-staging"

tags = {
  Team        = "DevOps"
  Owner       = "Platform Team"
  CostCenter  = "Engineering"
  Application = "Web Application"
  Compliance  = "Required"
}
