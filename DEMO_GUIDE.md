# Demo Guide - DevOps & Infrastructure as Code

## 🎯 Mục đích Demo

Demo này minh họa:
1. **CI/CD Pipeline** với 2 môi trường (dev & staging)
2. **Infrastructure as Code** với Terraform
3. **Best Practices** về deployment, rollback, và configuration management

---

## 📁 Cấu trúc Project

```
/Users/giahieunguyen/Desktop/PTUDHTTTHD_DevOps/
├── .github/workflows/          # CI/CD Pipelines
│   ├── ci-dev.yml             # Dev environment pipeline
│   ├── ci-staging.yml         # Staging environment pipeline  
│   └── rollback.yml           # Rollback workflow
│
├── terraform/                  # Infrastructure as Code
│   ├── backend.tf             # Remote state configuration
│   ├── environments/
│   │   ├── dev/               # Dev environment
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── terraform.tfvars
│   │   └── staging/           # Staging environment
│   │       ├── main.tf        # (includes blue-green setup)
│   │       ├── variables.tf
│   │       └── terraform.tfvars
│   └── modules/
│       └── storage/           # Reusable S3 module
│           ├── main.tf
│           ├── variables.tf
│           └── outputs.tf
│
├── app/                       # Sample application
│   ├── src/
│   │   └── index.js          # Express.js application
│   ├── tests/
│   │   └── app.test.js       # Unit tests
│   ├── package.json
│   └── .env.example
│
├── scripts/                   # Utility scripts
│   ├── terraform.sh          # Terraform helper
│   ├── health-check.sh       # Health check utility
│   └── deploy.sh             # Deployment script
│
└── docs/                      # Documentation
    ├── DEPLOYMENT.md         # Deployment guide
    ├── ROLLBACK.md           # Rollback procedures
    ├── BEST_PRACTICES.md     # DevOps best practices
    └── QUICK_START.md        # Quick start guide
```

---

## 🚀 DEMO 1: CI/CD Pipeline

### Scenario: Deploy to Development Environment

**Steps:**

1. **Tạo feature branch**
```bash
cd /Users/giahieunguyen/Desktop/PTUDHTTTHD_DevOps
git checkout -b feature/demo-cicd-5
```

2. **Make a simple change**
```bash
echo "# CI/CD Demo" >> app/src/demo.md
git add .
git commit -m "feat: add demo file"
```

3. **Push to main để trigger pipeline**
```bash
git checkout main
git merge feature/demo-cicd-5
git push origin main
```

4. **Monitor workflow**
```bash
gh run watch
# Or visit GitHub Actions UI
```

### What happens in the pipeline:

```
1. Build & Test ✓
   - Checkout code
   - Install dependencies
   - Run linting
   - Run unit tests
   - Build application
   - Upload artifacts

2. Security Scan ✓
   - Dependency audit
   - Trivy vulnerability scan

3. Deploy to Dev ✓
   - Configure AWS credentials
   - Download artifacts
   - Deploy to S3
   - Create deployment tag
   - Health check

4. Integration Tests ✓
   - Run E2E tests
   
5. Notification ✓
   - Send deployment status
```

### Pipeline Features Demo:

✅ **Automatic deployment** on push to `main`  
✅ **Multi-stage pipeline** (build → test → deploy)  
✅ **Artifact management** (build artifacts stored)  
✅ **Health checks** after deployment  
✅ **Automatic rollback** on failure  

---

## 🔵🟢 DEMO 2: Staging Deployment with Blue-Green

### Scenario: Deploy to Staging with Approval

**Steps:**

1. **Create release tag**
```bash
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

2. **Pipeline starts automatically**
- Build & comprehensive testing
- Security & compliance checks
- **Waits for manual approval** ⏸️

3. **Approve deployment**
- Go to GitHub Actions
- Review deployment request
- Click "Review deployments" → "Approve"

4. **Blue-Green deployment**
```
Current: Blue (v0.9.0) - 100% traffic
Deploy:  Green (v1.0.0) - 0% traffic initially

Steps:
1. Deploy to Green ✓
2. Health check on Green ✓
3. Smoke tests on Green ✓
4. Switch traffic: Blue → Green ✓
5. Keep Blue as standby for 24h ✓
```

### Key Features:

✅ **Manual approval gate** for production-like environments  
✅ **Blue-Green deployment** for zero-downtime  
✅ **Progressive validation** (health → smoke → full tests)  
✅ **Automatic backup** before deployment  
✅ **Instant rollback** capability (switch back to blue)  

---

## 🏗️ DEMO 3: Infrastructure as Code (Terraform)

### Scenario: Create S3 Bucket in Dev Environment

**Steps:**

1. **Review Terraform configuration**
```bash
cat terraform/environments/dev/main.tf
```

Shows:
- AWS provider configuration
- Storage module usage
- Versioning enabled (for rollback)
- Lifecycle policies
- Security settings

2. **Initialize Terraform**
```bash
cd terraform/environments/dev
terraform init
```

Output:
```
Initializing modules...
Initializing provider plugins...
- Finding hashicorp/PTUDHTTTHD_DevOpsws versions...
Terraform has been successfully initialized!
```

3. **Plan infrastructure changes**
```bash
terraform plan
```

Shows what will be created:
- S3 bucket with versioning
- Encryption enabled
- Lifecycle policies
- Logging bucket
- Access policies

4. **Apply changes** (Optional - costs money!)
```bash
terraform apply
```

Or use the helper script:
```bash
./scripts/terraform.sh dev plan
./scripts/terraform.sh dev apply
```

### Infrastructure Features Demo:

✅ **Modular structure** (reusable modules)  
✅ **Environment separation** (dev/staging/prod)  
✅ **Version control** for all infrastructure  
✅ **State management** (remote backend ready)  
✅ **Security by default** (encryption, private access)  
✅ **Lifecycle policies** (automatic cleanup)  
✅ **Resource tagging** (cost tracking, organization)  

---

## 🔄 DEMO 4: Rollback Procedure

### Scenario 1: Automatic Rollback

**Simulate a failing deployment:**

1. **Push code that fails tests**
```bash
git checkout main
echo "throw new Error('Fail');" >> app/src/index.js
git add .
git commit -m "test: trigger rollback"
git push origin main
```

2. **Pipeline detects failure**
- Post-deployment tests fail
- Automatic rollback triggered
- Previous version restored
- Notification sent

### Scenario 2: Manual Rollback

**Use the rollback workflow:**

```bash
gh workflow run rollback.yml \
  --field environment=staging \
  --field version=v1.0.0 \
  --field reason="Critical bug found in v1.0.1"
```

**Workflow steps:**
1. ✅ Validate version exists
2. ⏸️ Wait for approval
3. 📦 Backup current state
4. 🔄 Deploy previous version
5. 🧪 Run post-rollback tests
6. 📢 Notify team

### Rollback Features:

✅ **Multiple rollback methods** (auto, manual, blue-green)  
✅ **Version validation** before rollback  
✅ **Backup before rollback** (safety net)  
✅ **Approval required** for production  
✅ **Post-rollback validation**  
✅ **Incident reporting** automated  

---

## 📊 DEMO 5: Best Practices Implementation

### Configuration Management

**Environment-specific configs:**
```
dev: Fast iterations, verbose logging
staging: Production-like, moderate logging  
prod: Stable, error-only logging
```

**Secrets management:**
- GitHub Secrets for CI/CD
- Never commit secrets to git
- Environment variables for runtime

### Versioning Strategy

**Application:**
- Semantic versioning (v1.2.3)
- Git tags for releases
- Deployment tracking

**Infrastructure:**
- Terraform version pinning
- Provider version constraints
- Module versioning

### Monitoring & Observability

**Health checks:**
```bash
./scripts/health-check.sh http://localhost:3000
```

**Metrics tracked:**
- Request rate
- Error rate
- Response time
- Resource utilization

---

## ✅ What This Demo Accomplishes

### ✅ Yêu cầu 1: CI/CD với 2 môi trường
- **Development**: Automatic deployment on push to `main`
- **Staging**: Deployment with approval, blue-green strategy
- **Features**: Multi-stage pipeline, health checks, auto-rollback

### ✅ Yêu cầu 2: Terraform Infrastructure
- **S3 Bucket**: Simple cloud resource creation
- **Features**: Versioning, encryption, lifecycle, logging
- **Modular**: Reusable modules, environment separation
- **Best Practices**: State management, tagging, security

### ✅ Best Practices Implemented

**CI/CD:**
- ✅ Automated testing at multiple stages
- ✅ Security scanning (dependencies, vulnerabilities)
- ✅ Deployment approvals for critical environments
- ✅ Rollback mechanisms (automatic & manual)
- ✅ Health checks and validation

**Infrastructure:**
- ✅ Configuration versioned in Git
- ✅ Environment separation (dev/staging/prod)
- ✅ Reusable modules
- ✅ Resource tagging and organization
- ✅ Security by default
- ✅ State management ready

**Operational:**
- ✅ Comprehensive documentation
- ✅ Rollback procedures documented
- ✅ Helper scripts for common tasks
- ✅ Monitoring and health checks
- ✅ Incident response preparation

---

## 🎓 Learning Points

### CI/CD
1. **Pipeline as Code**: Workflows defined in YAML
2. **Multi-environment**: Different strategies per environment
3. **Approval Gates**: Human oversight for critical deployments
4. **Rollback Strategy**: Multiple methods for different scenarios

### Infrastructure as Code
1. **Declarative**: Describe desired state, Terraform handles the rest
2. **Modular**: Reusable components across environments
3. **Version Control**: Infrastructure changes tracked like code
4. **State Management**: Terraform tracks current infrastructure state

### DevOps Best Practices
1. **Automation**: Reduce manual steps, increase reliability
2. **Safety**: Backups, approvals, validation before changes
3. **Observability**: Monitor, alert, and respond to issues
4. **Documentation**: Clear guides for team operations

---

## 🚦 Next Steps

### For Learning:
1. Review each workflow file to understand pipeline structure
2. Examine Terraform modules to see IaC patterns
3. Read best practices documentation for deeper understanding
4. Try modifying and testing the pipelines locally

### For Production Use:
1. Configure AWS credentials properly
2. Set up GitHub Secrets
3. Enable remote Terraform backend (S3 + DynamoDB)
4. Add monitoring and alerting
5. Implement proper secret management
6. Set up staging environment matching production
7. Add more comprehensive tests

### Advanced Topics:
1. Implement Canary deployments
2. Add database migration handling
3. Implement feature flags
4. Add performance testing
5. Implement chaos engineering
6. Multi-region deployment

---

## 📚 References

- **Documentation**: See `/docs` folder
- **Workflows**: See `/.github/workflows`
- **Terraform**: See `/terraform`
- **Application**: See `/PTUDHTTTHD_DevOpspp`

## 🙋 Questions?

Review the comprehensive documentation in the `/docs` folder:
- `QUICK_START.md` - Get started quickly
- `DEPLOYMENT.md` - Detailed deployment procedures
- `ROLLBACK.md` - Rollback strategies and procedures
- `BEST_PRACTICES.md` - DevOps best practices guide

---

**Created by**: DevOps Team  
**Date**: 2024  
**Purpose**: Educational demo for DevOps & IaC concepts
