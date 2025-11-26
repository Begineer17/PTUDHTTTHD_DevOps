# Storage Module - S3 Bucket with Versioning and Lifecycle
# Module tái sử dụng để tạo S3 bucket với các best practices

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 Bucket for static assets
resource "aws_s3_bucket" "main" {
  bucket = "${var.bucket_prefix}-${random_string.bucket_suffix.result}"

  tags = merge(var.tags, {
    Name        = "${var.bucket_prefix}-bucket"
    Environment = var.environment
  })

  lifecycle {
    prevent_destroy = false  # Set to true in production
  }
}

# Enable versioning for rollback capability
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

# Enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access (best practice)
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle policy để tự động xóa old versions
resource "aws_s3_bucket_lifecycle_configuration" "main" {
  count  = var.enable_lifecycle ? 1 : 0
  bucket = aws_s3_bucket.main.id

  rule {
    id     = "cleanup-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }
  }

  rule {
    id     = "delete-old-backups"
    status = "Enabled"

    filter {
      prefix = "backups/"
    }

    expiration {
      days = 30
    }
  }

  rule {
    id     = "transition-to-glacier"
    status = "Enabled"

    filter {
      prefix = "archives/"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}

# CORS configuration for web hosting
resource "aws_s3_bucket_cors_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# CloudFront Origin Access Identity (optional)
resource "aws_cloudfront_origin_access_identity" "main" {
  count   = var.enable_cloudfront ? 1 : 0
  comment = "OAI for ${var.bucket_prefix}"
}

# CloudFront Distribution (optional, for staging/prod)
resource "aws_cloudfront_distribution" "main" {
  count   = var.enable_cloudfront ? 1 : 0
  enabled = true
  comment = "${var.project_name} - ${var.environment}"

  origin {
    domain_name = aws_s3_bucket.main.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.main.id}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.main[0].cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${aws_s3_bucket.main.id}"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-cdn"
    Environment = var.environment
  })
}

# Bucket policy to allow CloudFront access
resource "aws_s3_bucket_policy" "cloudfront_access" {
  count  = var.enable_cloudfront ? 1 : 0
  bucket = aws_s3_bucket.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontAccess"
        Effect = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.main[0].iam_arn
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.main.arn}/*"
      }
    ]
  })
}

# Logging bucket (best practice)
resource "aws_s3_bucket" "logs" {
  bucket = "${var.bucket_prefix}-logs-${random_string.bucket_suffix.result}"

  tags = merge(var.tags, {
    Name        = "${var.bucket_prefix}-logs"
    Environment = var.environment
    Purpose     = "Logging"
  })
}

resource "aws_s3_bucket_acl" "logs" {
  bucket = aws_s3_bucket.logs.id
  acl    = "log-delivery-write"
}

# Enable logging for main bucket
resource "aws_s3_bucket_logging" "main" {
  bucket = aws_s3_bucket.main.id

  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "access-logs/"
}
