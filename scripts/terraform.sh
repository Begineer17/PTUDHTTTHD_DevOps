#!/bin/bash

# Terraform Helper Script
# Quick commands for managing infrastructure

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

# Parse arguments
ENVIRONMENT=${1:-dev}
ACTION=${2:-plan}

if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    print_error "Invalid environment: $ENVIRONMENT"
    echo "Usage: $0 <dev|staging|prod> <plan|apply|destroy|show>"
    exit 1
fi

TERRAFORM_DIR="$PROJECT_ROOT/terraform/environments/$ENVIRONMENT"

if [ ! -d "$TERRAFORM_DIR" ]; then
    print_error "Terraform directory not found: $TERRAFORM_DIR"
    exit 1
fi

cd "$TERRAFORM_DIR"

print_info "Environment: $ENVIRONMENT"
print_info "Action: $ACTION"
print_info "Directory: $TERRAFORM_DIR"
echo ""

case $ACTION in
    init)
        print_info "Initializing Terraform..."
        terraform init
        print_success "Terraform initialized"
        ;;
    
    plan)
        print_info "Running terraform plan..."
        terraform plan -out=tfplan
        print_success "Plan completed. Review output above."
        ;;
    
    apply)
        print_info "Applying terraform changes..."
        if [ -f "tfplan" ]; then
            terraform apply tfplan
            rm -f tfplan
        else
            terraform apply
        fi
        print_success "Infrastructure deployed successfully!"
        ;;
    
    destroy)
        print_error "⚠️  WARNING: This will destroy all resources in $ENVIRONMENT!"
        read -p "Are you sure? (type 'yes' to confirm): " confirm
        if [ "$confirm" == "yes" ]; then
            terraform destroy
            print_success "Resources destroyed"
        else
            print_info "Destroy cancelled"
        fi
        ;;
    
    show)
        print_info "Showing current state..."
        terraform show
        ;;
    
    output)
        print_info "Showing outputs..."
        terraform output
        ;;
    
    *)
        print_error "Unknown action: $ACTION"
        echo "Available actions: init, plan, apply, destroy, show, output"
        exit 1
        ;;
esac

print_success "Done!"
