#!/bin/bash

# System Integration Test Script

set -e

echo "=========================================="
echo "Fraud Traceability System - Integration Test"
echo "=========================================="

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

BASE_URL="http://localhost"

test_endpoint() {
    local name=$1
    local url=$2
    local expected_status=${3:-200}
    
    echo -e "${YELLOW}Testing $name...${NC}"
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url" || echo "000")
    
    if [ "$response" = "$expected_status" ]; then
        echo -e "${GREEN}✓ $name: OK (HTTP $response)${NC}"
        return 0
    else
        echo -e "${RED}✗ $name: FAILED (HTTP $response, expected $expected_status)${NC}"
        return 1
    fi
}

test_post() {
    local name=$1
    local url=$2
    local data=$3
    
    echo -e "${YELLOW}Testing $name...${NC}"
    response=$(curl -s -X POST "$url" \
        -H "Content-Type: application/json" \
        -d "$data" \
        -w "\n%{http_code}" || echo "ERROR\n000")
    
    http_code=$(echo "$response" | tail -n 1)
    body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" = "200" ] || [ "$http_code" = "201" ]; then
        echo -e "${GREEN}✓ $name: OK (HTTP $http_code)${NC}"
        echo "  Response: $body" | head -c 100
        echo ""
        return 0
    else
        echo -e "${RED}✗ $name: FAILED (HTTP $http_code)${NC}"
        return 1
    fi
}

# Wait for service to be ready
wait_for_service() {
    local name=$1
    local url=$2
    local max_attempts=30
    local attempt=0
    
    echo -e "${YELLOW}Waiting for $name to be ready...${NC}"
    while [ $attempt -lt $max_attempts ]; do
        if curl -s "$url" > /dev/null 2>&1; then
            echo -e "${GREEN}✓ $name is ready${NC}"
            return 0
        fi
        attempt=$((attempt + 1))
        sleep 1
    done
    
    echo -e "${RED}✗ $name did not become ready${NC}"
    return 1
}

# Test services
echo -e "\n${YELLOW}Testing service health endpoints...${NC}"

test_endpoint "AI Risk Engine Health" "$BASE_URL:5001/health"
test_endpoint "LEA Backend Health" "$BASE_URL:8080/health"

# Test AI Risk Engine
echo -e "\n${YELLOW}Testing AI Risk Engine...${NC}"
test_post "AI Risk Score (Low Amount)" \
    "$BASE_URL:5001/risk-score" \
    '{"txId":"TEST001","amount":1000,"fromAccount":"ACC001","toAccount":"ACC002","timestamp":"2025-11-17T04:00:00Z"}'

test_post "AI Risk Score (High Amount)" \
    "$BASE_URL:5001/risk-score" \
    '{"txId":"TEST002","amount":200000,"fromAccount":"ACC001","toAccount":"ACC002","timestamp":"2025-11-17T04:00:00Z"}'

# Test Bank API
echo -e "\n${YELLOW}Testing Bank API...${NC}"
test_post "Bank API - Low Risk Transaction" \
    "$BASE_URL:8081/fraud/analyze" \
    '{"txId":"TXN001","amount":1000,"fromAccount":"ACC001","toAccount":"ACC002","timestamp":"2025-11-17T04:00:00Z"}'

test_post "Bank API - High Risk Transaction" \
    "$BASE_URL:8081/fraud/analyze" \
    '{"txId":"TXN002","amount":200000,"fromAccount":"ACC001","toAccount":"ACC002","timestamp":"2025-11-17T04:00:00Z"}'

# Test LEA Backend
echo -e "\n${YELLOW}Testing LEA Backend...${NC}"
test_post "LEA Backend - Send Alert" \
    "$BASE_URL:8080/notify" \
    '{"txId":"ALERT001","amount":50000,"riskScore":0.85,"timestamp":"2025-11-17T04:00:00Z"}'

test_endpoint "LEA Backend - Get Alerts" "$BASE_URL:8080/alerts"

echo -e "\n${GREEN}=========================================="
echo "Integration tests complete!"
echo "==========================================${NC}"
echo ""
echo "Note: Some tests may fail if services are not running."
echo "Start services with: ./scripts/start-all.sh"
echo ""
