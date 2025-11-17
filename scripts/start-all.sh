#!/bin/bash

# Start All Services Script
# This script helps start all services in the correct order

set -e

echo "=========================================="
echo "Fraud Traceability System - Startup Script"
echo "=========================================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}Error: $1 is not installed${NC}"
        exit 1
    fi
}

check_command java
check_command python3
check_command node
check_command npm

echo -e "${GREEN}All prerequisites found${NC}"

# Function to check if port is in use
check_port() {
    if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        echo -e "${YELLOW}Warning: Port $1 is already in use${NC}"
        return 1
    fi
    return 0
}

# Function to start service in background
start_service() {
    local name=$1
    local dir=$2
    local cmd=$3
    
    echo -e "${YELLOW}Starting $name...${NC}"
    cd "$dir"
    $cmd > "../logs/${name}.log" 2>&1 &
    echo $! > "../logs/${name}.pid"
    cd - > /dev/null
    sleep 2
    echo -e "${GREEN}$name started (PID: $(cat logs/${name}.pid))${NC}"
}

# Create logs directory
mkdir -p logs

# Check ports
echo -e "${YELLOW}Checking ports...${NC}"
check_port 5001 || echo "AI Risk Engine port 5001 in use"
check_port 8080 || echo "LEA Backend HTTP port 8080 in use"
check_port 8082 || echo "LEA Backend WebSocket port 8082 in use"
check_port 8081 || echo "Bank API port 8081 in use"
check_port 3000 || echo "LEA Frontend port 3000 in use"

# Start services
echo -e "\n${YELLOW}Starting services...${NC}"

# 1. AI Risk Engine
if [ ! -d "ai-risk-engine/venv" ]; then
    echo "Creating Python virtual environment..."
    cd ai-risk-engine
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    cd ..
fi

start_service "ai-risk-engine" "ai-risk-engine" "source venv/bin/activate && python app.py"

# 2. LEA Backend
if [ ! -d "lea-backend/node_modules" ]; then
    echo "Installing LEA Backend dependencies..."
    cd lea-backend
    npm install
    cd ..
fi

start_service "lea-backend" "lea-backend" "node server.js"

# 3. Bank API
start_service "bank-api" "bank-api" "./gradlew bootRun"

# 4. LEA Frontend
if [ ! -d "lea-frontend/node_modules" ]; then
    echo "Installing LEA Frontend dependencies..."
    cd lea-frontend
    npm install
    cd ..
fi

start_service "lea-frontend" "lea-frontend" "npm start"

echo -e "\n${GREEN}=========================================="
echo "All services started!"
echo "==========================================${NC}"
echo ""
echo "Services:"
echo "  - AI Risk Engine:    http://localhost:5001"
echo "  - LEA Backend HTTP:  http://localhost:8080"
echo "  - LEA Backend WS:    ws://localhost:8082"
echo "  - Bank API:          http://localhost:8081"
echo "  - LEA Frontend:      http://localhost:3000"
echo ""
echo "Logs are in the 'logs/' directory"
echo "To stop all services: ./scripts/stop-all.sh"
echo ""
