# Terraform Variables Values for DEV Environment
# File này chứa giá trị cụ thể cho từng biến

aws_region    = "us-east-1"
environment   = "dev"
project_name  = "my-app"
bucket_prefix = "my-app-dev"

tags = {
  Team        = "DevOps"
  Owner       = "Platform Team"
  CostCenter  = "Engineering"
  Application = "Web Application"
}
