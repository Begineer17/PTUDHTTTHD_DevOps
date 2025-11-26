#!/bin/bash

# Health Check Script
# Verify application health after deployment

set -e

# Configuration
URL=${1:-http://localhost:3000}
MAX_RETRIES=${2:-10}
RETRY_INTERVAL=${3:-5}

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🔍 Starting health check...${NC}"
echo "URL: $URL"
echo "Max retries: $MAX_RETRIES"
echo "Retry interval: ${RETRY_INTERVAL}s"
echo ""

# Function to check health
check_health() {
    local url=$1
    local response=$(curl -s -o /dev/null -w "%{http_code}" "$url/health" 2>/dev/null || echo "000")
    echo $response
}

# Retry loop
attempt=1
while [ $attempt -le $MAX_RETRIES ]; do
    echo -e "${YELLOW}Attempt $attempt/$MAX_RETRIES...${NC}"
    
    status_code=$(check_health "$URL")
    
    if [ "$status_code" = "200" ]; then
        echo -e "${GREEN}✅ Health check passed!${NC}"
        
        # Get detailed health info
        health_info=$(curl -s "$URL/health")
        echo ""
        echo "Health Information:"
        echo "$health_info" | jq '.' 2>/dev/null || echo "$health_info"
        
        exit 0
    else
        echo -e "${RED}❌ Health check failed (HTTP $status_code)${NC}"
        
        if [ $attempt -lt $MAX_RETRIES ]; then
            echo "Waiting ${RETRY_INTERVAL}s before retry..."
            sleep $RETRY_INTERVAL
        fi
    fi
    
    ((attempt++))
done

echo -e "${RED}❌ Health check failed after $MAX_RETRIES attempts${NC}"
exit 1
