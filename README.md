# DevOps & Infrastructure as Code Demo

## 📋 Mục lục
- [Tổng quan](#tổng-quan)
- [CI/CD Pipeline](#cicd-pipeline)
- [Infrastructure as Code](#infrastructure-as-code)
- [Best Practices](#best-practices)
- [Hướng dẫn sử dụng](#hướng-dẫn-sử-dụng)

## 🎯 Tổng quan

Dự án demo này minh họa các best practices về:
- **CI/CD nâng cao**: Multi-environment deployment (dev/staging)
- **Infrastructure as Code**: Terraform để quản lý cloud resources
- **Version Control**: Cấu hình versioned và rollback an toàn

## 🚀 CI/CD Pipeline

### Môi trường
- **Development (dev)**: Tự động deploy khi push vào branch `develop`
- **Staging**: Tự động deploy khi push vào branch `staging` hoặc tạo release tag

### Tính năng
- ✅ Automated testing
- ✅ Multi-environment deployment
- ✅ Rollback mechanism
- ✅ Environment-specific configurations
- ✅ Deployment approval gates (cho staging)
- ✅ Automated notifications

### Pipeline Flow
```
Code Push → Build → Test → Deploy (Dev) → Test (E2E) → Deploy (Staging) → Production
                                    ↓
                              Rollback Option
```

## 🏗️ Infrastructure as Code

### Terraform
- Quản lý cloud resources (AWS S3 bucket demo)
- State management với remote backend
- Environment-specific configurations
- Resource versioning và tagging

### Cấu trúc
```
terraform/
├── environments/
│   ├── dev/
│   └── staging/
├── modules/
│   └── storage/
└── main.tf
```

## 📚 Best Practices

### 1. Configuration Management
- ✅ Tất cả cấu hình được version control
- ✅ Sử dụng environment variables cho sensitive data
- ✅ Configuration files cho từng môi trường

### 2. Deployment Strategy
- ✅ Blue-Green Deployment
- ✅ Canary Releases
- ✅ Feature Flags

### 3. Rollback Strategy
- ✅ Automated rollback on failure
- ✅ Manual rollback capability
- ✅ Keep last N deployments
- ✅ Database migration rollback plans

### 4. Security
- ✅ Secrets management (GitHub Secrets, AWS Secrets Manager)
- ✅ Least privilege access
- ✅ Infrastructure scanning (tfsec, checkov)
- ✅ Dependency vulnerability scanning

### 5. Monitoring & Observability
- ✅ Deployment tracking
- ✅ Health checks
- ✅ Logging và alerting
- ✅ Performance monitoring

## 🛠️ Hướng dẫn sử dụng

### Prerequisites
```bash
# Cài đặt Terraform
brew install terraform

# Cài đặt AWS CLI
brew install awscli

# Cài đặt kubectl (nếu dùng Kubernetes)
brew install kubectl
```

### Setup CI/CD

1. **Configure GitHub Secrets**
```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
SLACK_WEBHOOK_URL (optional)
```

2. **Enable GitHub Actions**
- Actions sẽ tự động chạy khi push code

### Setup Terraform

1. **Initialize Terraform**
```bash
cd terraform/environments/dev
terraform init
```

2. **Plan Infrastructure**
```bash
terraform plan
```

3. **Apply Infrastructure**
```bash
terraform apply
```

4. **Destroy Infrastructure (cleanup)**
```bash
terraform destroy
```

### Rollback Deployment

#### Option 1: Revert Git Commit
```bash
# Rollback về commit trước
git revert HEAD
git push origin develop

# Pipeline sẽ tự động deploy version cũ
```

#### Option 2: Re-deploy Previous Version
```bash
# Re-run workflow với tag cũ
gh workflow run deploy.yml --ref v1.2.3
```

#### Option 3: Manual Rollback (Terraform)
```bash
# Rollback về state trước
terraform state list
terraform state pull > backup.tfstate

# Apply state cũ
terraform apply -state=backup.tfstate
```

## 📁 Cấu trúc Project

```
.
├── .github/
│   └── workflows/
│       ├── ci-dev.yml           # CI/CD cho dev environment
│       ├── ci-staging.yml       # CI/CD cho staging environment
│       └── rollback.yml         # Rollback workflow
├── terraform/
│   ├── environments/
│   │   ├── dev/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── terraform.tfvars
│   │   └── staging/
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       └── terraform.tfvars
│   ├── modules/
│   │   └── storage/
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       └── outputs.tf
│   └── backend.tf
├── app/
│   ├── src/
│   └── tests/
├── docs/
│   ├── DEPLOYMENT.md
│   ├── ROLLBACK.md
│   └── BEST_PRACTICES.md
└── README.md
```

## 🔍 Monitoring Deployments

### View Pipeline Status
```bash
# GitHub CLI
gh run list --workflow=ci-dev.yml

# View specific run
gh run view <run-id>
```

### Check Terraform State
```bash
# List resources
terraform state list

# Show resource details
terraform state show <resource-name>
```

## 📖 Tài liệu bổ sung

- [DEPLOYMENT.md](./docs/DEPLOYMENT.md) - Chi tiết về deployment process
- [ROLLBACK.md](./docs/ROLLBACK.md) - Hướng dẫn rollback chi tiết
- [BEST_PRACTICES.md](./docs/BEST_PRACTICES.md) - DevOps best practices

## 🤝 Contributing

1. Fork the project
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 📝 License

MIT License

## 👥 Authors

- DevOps Team
