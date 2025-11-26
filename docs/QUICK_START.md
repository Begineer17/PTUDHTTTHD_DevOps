# Quick Start Guide

## 🚀 Hướng dẫn nhanh

### 1. Setup môi trường

```bash
# Clone repository
git clone <repo-url>
cd A

# Install dependencies
cd app
npm install
```

### 2. Chạy ứng dụng local

```bash
cd app
cp .env.example .env
npm run dev

# Application sẽ chạy tại http://localhost:3000
```

### 3. Test ứng dụng

```bash
# Run tests
npm test

# Run with coverage
npm test -- --coverage

# Health check
curl http://localhost:3000/health
```

### 4. Setup Terraform

```bash
# Install Terraform (macOS)
brew install terraform

# Initialize Terraform
cd terraform/environments/dev
terraform init

# See what will be created
terraform plan

# Create infrastructure (chỉ khi ready)
terraform apply
```

### 5. Test CI/CD Workflow

```bash
# Create feature branch
git checkout -b feature/test-cicd

# Make changes
echo "Test" >> README.md

# Commit and push
git add .
git commit -m "test: CI/CD workflow"
git push origin feature/test-cicd

# Merge to develop to trigger dev deployment
git checkout develop
git merge feature/test-cicd
git push origin develop

# View workflow
gh run watch
```

## 📚 Tài liệu chi tiết

- [README.md](../README.md) - Tổng quan dự án
- [DEPLOYMENT.md](./DEPLOYMENT.md) - Hướng dẫn deployment
- [ROLLBACK.md](./ROLLBACK.md) - Hướng dẫn rollback
- [BEST_PRACTICES.md](./BEST_PRACTICES.md) - Best practices

## 🛠️ Scripts hữu ích

```bash
# Terraform operations
./scripts/terraform.sh dev plan
./scripts/terraform.sh dev apply
./scripts/terraform.sh dev destroy

# Health check
./scripts/health-check.sh http://localhost:3000

# Deployment
./scripts/deploy.sh dev v1.0.0
```

## 🔍 Troubleshooting

### Port đã được sử dụng
```bash
# Find process using port 3000
lsof -i :3000

# Kill process
kill -9 <PID>
```

### Terraform state locked
```bash
# Force unlock (cẩn thận!)
terraform force-unlock <LOCK_ID>
```

### GitHub Actions không chạy
```bash
# Check workflow files
gh workflow list

# View specific workflow
gh workflow view ci-dev.yml

# Enable workflow
gh workflow enable ci-dev.yml
```

## 💡 Tips

1. **Làm việc với branches**: Luôn tạo feature branch mới
2. **Test local trước**: Chạy tests và build local trước khi push
3. **Monitor deployments**: Theo dõi GitHub Actions sau mỗi push
4. **Backup trước khi thay đổi infrastructure**: Luôn backup state files
5. **Document changes**: Viết commit messages rõ ràng

## 🆘 Cần giúp đỡ?

- Check documentation trong `/docs`
- Review workflow files trong `/.github/workflows`
- Xem Terraform configurations trong `/terraform`
