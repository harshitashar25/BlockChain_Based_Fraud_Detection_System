#!/bin/bash

# Stop All Services Script

set -e

echo "=========================================="
echo "Stopping Fraud Traceability System Services"
echo "=========================================="

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

stop_service() {
    local name=$1
    local pid_file="logs/${name}.pid"
    
    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if ps -p $pid > /dev/null 2>&1; then
            echo -e "${YELLOW}Stopping $name (PID: $pid)...${NC}"
            kill $pid 2>/dev/null || true
            rm "$pid_file"
            echo -e "${GREEN}$name stopped${NC}"
        else
            echo -e "${YELLOW}$name was not running${NC}"
            rm "$pid_file"
        fi
    else
        echo -e "${YELLOW}$name PID file not found${NC}"
    fi
}

# Stop services in reverse order
stop_service "lea-frontend"
stop_service "bank-api"
stop_service "lea-backend"
stop_service "ai-risk-engine"

# Also kill any processes on the ports (fallback)
echo -e "\n${YELLOW}Checking for processes on service ports...${NC}"

for port in 3000 8081 8082 8080 5001; do
    pid=$(lsof -ti:$port 2>/dev/null || true)
    if [ ! -z "$pid" ]; then
        echo -e "${YELLOW}Killing process on port $port (PID: $pid)${NC}"
        kill $pid 2>/dev/null || true
    fi
done

echo -e "\n${GREEN}All services stopped${NC}"
