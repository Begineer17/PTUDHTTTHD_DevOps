# DevOps Best Practices

## 📋 Mục lục
- [CI/CD Best Practices](#cicd-best-practices)
- [Infrastructure as Code](#infrastructure-as-code)
- [Security](#security)
- [Monitoring & Observability](#monitoring--observability)
- [Configuration Management](#configuration-management)

## 🚀 CI/CD Best Practices

### 1. Pipeline Design

#### Keep Pipelines Fast
```yaml
✅ DO:
- Run tests in parallel
- Use caching for dependencies
- Only build what changed
- Use pipeline artifacts
- Optimize Docker layer caching

❌ DON'T:
- Run all tests sequentially
- Rebuild everything every time
- Download dependencies repeatedly
- Skip caching strategies
```

**Example:**
```yaml
# Good - Parallel execution
jobs:
  unit-tests:
    runs-on: ubuntu-latest
  integration-tests:
    runs-on: ubuntu-latest
  lint:
    runs-on: ubuntu-latest
```

#### Fail Fast
```yaml
✅ DO:
- Run cheap checks first (lint, type check)
- Fail on first error in critical jobs
- Use appropriate timeouts

❌ DON'T:
- Run expensive tests first
- Continue after critical failures
- Let jobs run indefinitely
```

### 2. Branch Strategy

#### GitFlow for Multi-Environment
```
main (production)
  ↑
staging (pre-production)
  ↑
develop (integration)
  ↑
feature/* (development)
```

**Rules:**
- `feature/*` → `develop`: Frequent merges
- `develop` → `staging`: Weekly/bi-weekly
- `staging` → `main`: After thorough testing
- Hotfix branches for emergency fixes

#### Environment Protection
```yaml
Development:
  - No approval required
  - Auto-deploy on merge
  - Can be unstable

Staging:
  - Requires approval
  - Full test suite
  - Production-like data

Production:
  - Multiple approvals
  - Change management
  - Scheduled deployments
```

### 3. Testing Strategy

#### Test Pyramid
```
        /\
       /UI\       (10% - E2E Tests)
      /────\
     /Integ\      (20% - Integration Tests)
    /──────\
   /  Unit  \     (70% - Unit Tests)
  /──────────\
```

**Coverage Goals:**
- Unit tests: 80%+
- Integration tests: 60%+
- E2E tests: Critical paths only

#### Test Stages
```yaml
1. Pre-commit:
   - Linting
   - Type checking
   - Quick unit tests

2. Pull Request:
   - Full unit test suite
   - Integration tests
   - Security scanning

3. Pre-deployment:
   - E2E tests
   - Performance tests
   - Smoke tests

4. Post-deployment:
   - Health checks
   - Integration verification
   - Monitoring validation
```

### 4. Deployment Strategies

#### Progressive Delivery
```yaml
Canary Release:
  Step 1: 5% traffic  → Monitor 15 min
  Step 2: 25% traffic → Monitor 30 min
  Step 3: 50% traffic → Monitor 30 min
  Step 4: 100% traffic

Blue-Green:
  Step 1: Deploy to Green
  Step 2: Test Green thoroughly
  Step 3: Switch traffic to Green
  Step 4: Keep Blue for 24-48h
  Step 5: Decommission Blue
```

#### Feature Flags
```javascript
// Good - Gradual rollout
if (featureFlag.isEnabled('new-checkout', user.id)) {
  return newCheckoutFlow();
} else {
  return oldCheckoutFlow();
}

// Rollout strategy
- Day 1: 5% users
- Day 3: 25% users
- Day 7: 100% users
```

## 🏗️ Infrastructure as Code

### 1. Terraform Best Practices

#### Module Structure
```
terraform/
├── modules/
│   ├── storage/      # Reusable components
│   ├── compute/
│   └── networking/
├── environments/
│   ├── dev/          # Environment-specific
│   ├── staging/
│   └── prod/
└── backend.tf        # State management
```

#### State Management
```hcl
✅ DO:
terraform {
  backend "s3" {
    bucket         = "terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

❌ DON'T:
- Store state locally
- Commit state to git
- Share state files manually
```

#### Variable Management
```hcl
# Good - Use variables
variable "environment" {
  type        = string
  description = "Environment name"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Must be dev, staging, or prod"
  }
}

# Bad - Hardcoded values
resource "aws_s3_bucket" "app" {
  bucket = "my-app-production-bucket"  # ❌
}

# Good - Dynamic naming
resource "aws_s3_bucket" "app" {
  bucket = "${var.project}-${var.environment}-bucket"  # ✅
}
```

#### Resource Tagging
```hcl
# Consistent tagging strategy
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    CostCenter  = var.cost_center
    Owner       = var.owner
    CreatedAt   = timestamp()
  }
}

resource "aws_s3_bucket" "app" {
  bucket = var.bucket_name
  tags   = merge(local.common_tags, var.additional_tags)
}
```

### 2. Infrastructure Versioning

#### Version Everything
```hcl
terraform {
  required_version = "~> 1.6"  # ✅ Pin versions

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"        # ✅ Pin provider versions
    }
  }
}
```

#### Module Versioning
```hcl
module "storage" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.0"  # ✅ Use specific version

  # Configuration...
}
```

### 3. Security in IaC

#### Secrets Management
```hcl
❌ DON'T:
variable "db_password" {
  default = "super-secret-123"  # Never do this!
}

✅ DO:
variable "db_password" {
  type      = string
  sensitive = true
  # Pass via environment variable or secret manager
}

# Use AWS Secrets Manager
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "prod/db/password"
}
```

#### Least Privilege
```hcl
# Good - Minimal permissions
resource "aws_iam_policy" "app" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:PutObject"
      ]
      Resource = "${aws_s3_bucket.app.arn}/*"
    }]
  })
}
```

## 🔒 Security

### 1. Secrets Management

#### Never Commit Secrets
```bash
# .gitignore
*.env
*.secret
*.key
*.pem
terraform.tfvars
secrets.yml
```

#### Use Secret Managers
```yaml
✅ Use:
- GitHub Secrets for CI/CD
- AWS Secrets Manager for AWS resources
- HashiCorp Vault for multi-cloud
- Azure Key Vault for Azure

❌ Don't:
- Environment variables in code
- Config files in repository
- Hardcoded credentials
```

#### Rotate Secrets Regularly
```yaml
Schedule:
  - API keys: Every 90 days
  - Database passwords: Every 90 days
  - SSL certificates: Before expiration
  - SSH keys: Every 6 months
```

### 2. Dependency Security

#### Automated Scanning
```yaml
# GitHub Actions
- name: Run dependency audit
  run: npm audit --audit-level=high

- name: Run Trivy scan
  uses: aquasecurity/trivy-action@master
  with:
    scan-type: 'fs'
    severity: 'CRITICAL,HIGH'
```

#### Keep Dependencies Updated
```json
// package.json - Use ranges wisely
{
  "dependencies": {
    "express": "^4.18.0",     // ✅ Allow patch updates
    "lodash": "~4.17.21"      // ✅ Allow patch updates only
  },
  "devDependencies": {
    "jest": "^29.0.0"         // ✅ OK for dev dependencies
  }
}
```

### 3. Infrastructure Security

#### Network Segmentation
```hcl
# Good - Isolated subnets
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  
  tags = {
    Name = "private-subnet"
    Tier = "application"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  
  tags = {
    Name = "public-subnet"
    Tier = "dmz"
  }
}
```

#### Security Groups
```hcl
# Restrictive security groups
resource "aws_security_group" "app" {
  name        = "app-sg"
  description = "Allow HTTPS from ALB only"
  
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]  # ✅ Specific source
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Review periodically
  }
}
```

## 📊 Monitoring & Observability

### 1. The Three Pillars

#### Logs
```yaml
What to Log:
  ✅ Application errors
  ✅ Request/response (sanitized)
  ✅ Business events
  ✅ Performance metrics
  ✅ Security events

What NOT to Log:
  ❌ Passwords
  ❌ Credit card numbers
  ❌ Personal data (PII)
  ❌ Session tokens
```

#### Metrics
```yaml
Application Metrics:
  - Request rate (req/s)
  - Error rate (%)
  - Response time (p50, p95, p99)
  - Throughput

Infrastructure Metrics:
  - CPU utilization
  - Memory usage
  - Disk I/O
  - Network traffic

Business Metrics:
  - Active users
  - Conversion rate
  - Revenue
  - Feature usage
```

#### Traces
```javascript
// Distributed tracing
const span = tracer.startSpan('processPayment');
span.setTag('user_id', userId);
span.setTag('amount', amount);

try {
  const result = await paymentService.process(userId, amount);
  span.setTag('status', 'success');
  return result;
} catch (error) {
  span.setTag('error', true);
  span.log({ event: 'error', message: error.message });
  throw error;
} finally {
  span.finish();
}
```

### 2. Alerting Strategy

#### Alert Levels
```yaml
Critical (Page immediately):
  - Service down
  - Error rate > 10%
  - Response time > 5s
  - Payment processing failed

Warning (Notify, investigate):
  - Error rate > 5%
  - Response time > 2s
  - Disk usage > 80%
  - Memory > 85%

Info (Track, review later):
  - Deployment completed
  - Configuration changed
  - Unusual traffic pattern
```

#### Reduce Alert Fatigue
```yaml
✅ DO:
- Set appropriate thresholds
- Use time windows (5 min average)
- Implement alert grouping
- Have clear runbooks
- Regular alert review

❌ DON'T:
- Alert on every blip
- Ignore "flappy" alerts
- Set and forget thresholds
- Alert without actionable info
```

## ⚙️ Configuration Management

### 1. Environment Variables

#### Structure
```bash
# .env.example (commit this)
NODE_ENV=development
PORT=3000
DATABASE_URL=postgresql://user:pass@localhost:5432/db
REDIS_URL=redis://localhost:6379
LOG_LEVEL=info

# .env (DON'T commit - use for local dev)
DATABASE_URL=postgresql://user:secret@localhost:5432/myapp
```

#### Loading Strategy
```javascript
// config.js
require('dotenv').config();

module.exports = {
  env: process.env.NODE_ENV || 'development',
  port: parseInt(process.env.PORT, 10) || 3000,
  database: {
    url: process.env.DATABASE_URL,
    pool: {
      min: parseInt(process.env.DB_POOL_MIN, 10) || 2,
      max: parseInt(process.env.DB_POOL_MAX, 10) || 10
    }
  },
  // Validate required vars
  validate() {
    const required = ['DATABASE_URL', 'REDIS_URL'];
    const missing = required.filter(key => !process.env[key]);
    if (missing.length > 0) {
      throw new Error(`Missing required env vars: ${missing.join(', ')}`);
    }
  }
};
```

### 2. Feature Flags

#### Implementation
```javascript
// feature-flags.js
class FeatureFlags {
  constructor() {
    this.flags = {
      'new-checkout': {
        enabled: true,
        rollout: 0.1,  // 10% of users
      },
      'ai-recommendations': {
        enabled: false,
      },
      'beta-features': {
        enabled: true,
        allowlist: ['user-123', 'user-456']
      }
    };
  }

  isEnabled(feature, userId) {
    const flag = this.flags[feature];
    if (!flag || !flag.enabled) return false;
    
    // Check allowlist
    if (flag.allowlist) {
      return flag.allowlist.includes(userId);
    }
    
    // Percentage rollout
    if (flag.rollout) {
      const hash = this.hashUserId(userId);
      return hash < flag.rollout;
    }
    
    return true;
  }
}
```

### 3. Configuration Versioning

#### Track Configuration Changes
```yaml
# config/v1.0.0.yml
version: 1.0.0
database:
  pool_size: 10
  timeout: 5000

# config/v1.1.0.yml
version: 1.1.0
database:
  pool_size: 20     # Changed
  timeout: 5000
changes:
  - "Increased database pool size for better performance"
```

## 📚 Additional Resources

- [The Twelve-Factor App](https://12factor.net/)
- [DevOps Handbook](https://itrevolution.com/book/the-devops-handbook/)
- [Site Reliability Engineering (SRE)](https://sre.google/books/)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
