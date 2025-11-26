# Terraform Backend Configuration
# Lưu trữ state file remotely để team collaboration và state locking

terraform {
  # Minimum Terraform version required
  required_version = ">= 1.0"

  # Required providers
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote backend configuration (S3 + DynamoDB for state locking)
  # Uncomment và configure khi triển khai thực tế
  /*
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
    
    # Enable versioning for state file
    versioning     = true
  }
  */
}
