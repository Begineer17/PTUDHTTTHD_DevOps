# Rollback Guide

## 📋 Mục lục
- [Tổng quan](#tổng-quan)
- [Khi nào cần Rollback](#khi-nào-cần-rollback)
- [Các phương pháp Rollback](#các-phương-pháp-rollback)
- [Rollback Procedures](#rollback-procedures)
- [Testing Rollback](#testing-rollback)

## 🎯 Tổng quan

Rollback là quá trình khôi phục hệ thống về version ổn định trước đó khi phát hiện vấn đề sau deployment.

**Mục tiêu:**
- Minimize downtime
- Restore service quickly
- Preserve data integrity
- Document incident

## ⚠️ Khi nào cần Rollback

### Automatic Rollback Triggers
Hệ thống tự động rollback khi:
- ❌ Health check failed > 3 lần
- ❌ Error rate > 5%
- ❌ Response time > 200% baseline
- ❌ Post-deployment tests failed
- ❌ Critical resources unavailable

### Manual Rollback Triggers
Cân nhắc rollback khi:
- 🐛 Critical bug discovered
- 📉 Performance degradation
- 💾 Data corruption detected
- 🔒 Security vulnerability found
- 👥 Major user complaints
- 💰 Business metrics affected

## 🔄 Các phương pháp Rollback

### 1. Automated Rollback (Preferred)
Được trigger tự động bởi CI/CD pipeline.

**Advantages:**
- ✅ Fastest response time
- ✅ No human error
- ✅ Consistent process
- ✅ Well-tested

**Disadvantages:**
- ⚠️ May rollback false positives
- ⚠️ Requires good monitoring

### 2. Manual Rollback
Được thực hiện thủ công qua GitHub Actions workflow.

**Advantages:**
- ✅ Full control
- ✅ Can investigate first
- ✅ Selective rollback

**Disadvantages:**
- ⚠️ Slower response
- ⚠️ Human error possible
- ⚠️ Requires on-call engineer

### 3. Blue-Green Switch
Chuyển traffic về blue environment.

**Advantages:**
- ✅ Instant rollback
- ✅ Zero downtime
- ✅ Green environment still available for debug

**Disadvantages:**
- ⚠️ Requires blue environment maintenance
- ⚠️ Database changes may be challenging

## 📖 Rollback Procedures

### Method 1: Automatic Rollback (CI/CD)

Được trigger tự động khi post-deployment tests fail.

```yaml
# Tự động trong pipeline
rollback-on-failure:
  if: failure()
  steps:
    - Get previous stable version
    - Restore from backup
    - Deploy previous version
    - Verify deployment
    - Notify team
```

**No action required** - pipeline handles everything!

### Method 2: Manual Rollback via GitHub Actions

#### Step 1: Trigger Rollback Workflow
```bash
# Via GitHub CLI
gh workflow run rollback.yml \
  --field environment=staging \
  --field version=v1.2.3 \
  --field reason="Critical bug in payment processing"

# Via GitHub UI
# Actions → Rollback → Run workflow
# Fill in: environment, version, reason
```

#### Step 2: Approve Rollback
```
1. Navigate to Actions tab
2. Find "Rollback" workflow run
3. Review rollback details
4. Click "Review deployments"
5. Select "Approve and deploy"
```

#### Step 3: Monitor Rollback
```bash
# Watch progress
gh run watch

# Check status
gh run view --log

# Verify health
curl https://staging.example.com/health
```

### Method 3: Blue-Green Traffic Switch

#### Quick Rollback
```bash
# Switch traffic back to blue
aws elbv2 modify-listener \
  --listener-arn $LISTENER_ARN \
  --default-actions Type=forward,TargetGroupArn=$BLUE_TG_ARN

# Verify
curl https://staging.example.com/version
# Should show old version
```

#### Full Rollback
```bash
# 1. Switch traffic to blue
./scripts/switch-to-blue.sh

# 2. Verify blue environment
curl https://blue.staging.example.com/health

# 3. Update DNS/Load Balancer
aws route53 change-resource-record-sets \
  --hosted-zone-id $ZONE_ID \
  --change-batch file://blue-dns-update.json

# 4. Monitor for 15 minutes
watch -n 30 './scripts/check-metrics.sh'
```

### Method 4: Git Revert and Redeploy

#### For Development
```bash
# 1. Revert the problematic commit
git revert HEAD
git push origin develop

# 2. Pipeline auto-deploys reverted version
# 3. Monitor deployment
gh run watch
```

#### For Staging/Production
```bash
# 1. Find the commit to revert
git log --oneline -10

# 2. Revert the commit
git revert <commit-hash>
git push origin staging

# 3. Or cherry-pick a good commit
git cherry-pick <good-commit-hash>
git push origin staging

# 4. Wait for approval and deployment
```

### Method 5: Infrastructure Rollback (Terraform)

#### Rollback Terraform Changes
```bash
cd terraform/environments/staging

# 1. Check current state
terraform state list

# 2. View state history
terraform state pull > current.tfstate
git log terraform.tfstate

# 3. Rollback to previous state
git checkout HEAD~1 -- terraform.tfstate
terraform apply

# 4. Or use specific version
git checkout <commit-hash> -- terraform.tfstate
terraform apply

# 5. Verify
terraform show
```

#### Restore from State Backup
```bash
# 1. List available backups
aws s3 ls s3://my-terraform-state-bucket/backups/

# 2. Download backup
aws s3 cp s3://my-terraform-state-bucket/backups/terraform.tfstate.backup-20231115 \
  ./terraform.tfstate

# 3. Apply backup state
terraform apply -state=./terraform.tfstate
```

## 🧪 Testing Rollback

### Pre-Production Testing

#### Test Automatic Rollback
```bash
# 1. Deploy intentionally failing version
# 2. Observe automatic rollback
# 3. Verify service restored

# Simulate in dev
git checkout develop
echo "throw new Error('Test rollback')" >> app/src/test-endpoint.js
git commit -m "Test: Trigger automatic rollback"
git push origin develop

# Watch pipeline rollback automatically
gh run watch
```

#### Test Manual Rollback
```bash
# 1. Trigger manual rollback workflow
gh workflow run rollback.yml \
  --field environment=dev \
  --field version=dev-123 \
  --field reason="Rollback test"

# 2. Approve and monitor
gh run watch

# 3. Verify restoration
curl https://dev.example.com/health
```

#### Test Blue-Green Switch
```bash
# 1. Deploy to green
./scripts/deploy-to-green.sh

# 2. Switch traffic to green
./scripts/switch-to-green.sh

# 3. Immediately switch back to blue (rollback test)
./scripts/switch-to-blue.sh

# 4. Measure rollback time
# Target: < 30 seconds
```

### Rollback Time Objectives

| Environment | RTO (Recovery Time Objective) | RPO (Recovery Point Objective) |
|-------------|-------------------------------|--------------------------------|
| Development | 5 minutes                     | 1 hour                        |
| Staging     | 2 minutes                     | 15 minutes                    |
| Production  | 1 minute                      | 5 minutes                     |

## 📋 Rollback Checklist

### Before Rollback
- [ ] Identify the issue clearly
- [ ] Determine affected version
- [ ] Find last known good version
- [ ] Notify stakeholders
- [ ] Create incident ticket
- [ ] Take database backup (if needed)
- [ ] Document current state

### During Rollback
- [ ] Execute rollback procedure
- [ ] Monitor rollback progress
- [ ] Verify health checks passing
- [ ] Check error rates
- [ ] Test critical paths
- [ ] Monitor user impact
- [ ] Keep stakeholders updated

### After Rollback
- [ ] Verify service fully restored
- [ ] Monitor for 30+ minutes
- [ ] Check all integrations
- [ ] Review logs for anomalies
- [ ] Document rollback process
- [ ] Create post-mortem
- [ ] Fix root cause
- [ ] Update runbooks

## 🔍 Post-Rollback Analysis

### Immediate Actions
```bash
# 1. Verify service health
./scripts/health-check.sh

# 2. Check metrics
aws cloudwatch get-metric-statistics \
  --namespace CustomApp \
  --metric-name ErrorRate \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S)

# 3. Review logs
kubectl logs -f deployment/app --tail=100

# 4. Test key features
npm run test:smoke
```

### Root Cause Analysis
```markdown
## Incident Report Template

### Summary
- **Date**: 2024-01-15
- **Duration**: 15 minutes
- **Impact**: 5% error rate on checkout
- **Rollback Time**: 3 minutes

### Timeline
- 14:00: Deployment started
- 14:10: Error rate spike detected
- 14:12: Rollback initiated
- 14:15: Service restored

### Root Cause
- Bug in payment processing logic
- Missing validation in new code
- Insufficient testing coverage

### Action Items
1. Add integration test for payment flow
2. Update deployment checklist
3. Enhance monitoring alerts
4. Review code review process

### Lessons Learned
- Need better staging environment parity
- Should test with production-like data
- Rollback procedure worked well
```

## 🚨 Emergency Rollback

### Critical Production Issue

#### Immediate Actions (< 5 minutes)
```bash
# 1. Alert team
./scripts/page-oncall.sh "CRITICAL: Production rollback needed"

# 2. Execute fastest rollback method
# Option A: Blue-Green switch
./scripts/emergency-switch-to-blue.sh

# Option B: Manual workflow
gh workflow run rollback.yml \
  --field environment=production \
  --field version=<last-stable> \
  --field reason="EMERGENCY: [brief description]"

# 3. Monitor recovery
watch -n 5 'curl -s https://api.example.com/health | jq'
```

#### Communication
```markdown
**Status Update Template**

🚨 INCIDENT DETECTED
- Time: 14:00 UTC
- Impact: Payment processing affected
- Action: Initiating emergency rollback

⏳ ROLLBACK IN PROGRESS
- Time: 14:02 UTC
- Status: Rolling back to v1.2.3
- ETA: 2 minutes

✅ INCIDENT RESOLVED
- Time: 14:05 UTC
- Status: Services restored
- Next: Post-mortem scheduled
```

## 📚 References

- [Incident Response Playbook](./INCIDENT_RESPONSE.md)
- [Monitoring Guide](./MONITORING.md)
- [Deployment Guide](./DEPLOYMENT.md)
- [Post-Mortem Template](./templates/post-mortem.md)

## 🆘 Emergency Contacts

```yaml
On-Call Engineers:
  - Primary: oncall@example.com
  - Secondary: backup@example.com

Escalation:
  - Team Lead: lead@example.com
  - Engineering Manager: manager@example.com

External:
  - Cloud Provider Support: +1-xxx-xxx-xxxx
  - Database Support: support@db-provider.com
```
