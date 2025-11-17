#!/bin/bash

# Prerequisites Check Script

echo "=========================================="
echo "Prerequisites Check"
echo "=========================================="

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

check_with_version() {
    local cmd=$1
    local min_version=$2
    local name=$3
    
    if command -v $cmd &> /dev/null; then
        local version=$($cmd --version 2>&1 | head -n 1)
        echo -e "${GREEN}✓ $name${NC}"
        echo -e "  Version: $version"
        return 0
    else
        echo -e "${RED}✗ $name: NOT FOUND${NC}"
        echo -e "  ${YELLOW}Install: $4${NC}"
        return 1
    fi
}

check_java() {
    if command -v java &> /dev/null; then
        local version=$(java -version 2>&1 | head -n 1)
        local version_num=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d'.' -f1)
        
        if [ "$version_num" -ge 17 ]; then
            echo -e "${GREEN}✓ Java${NC}"
            echo -e "  Version: $version"
            echo -e "  JAVA_HOME: ${JAVA_HOME:-not set}"
            return 0
        else
            echo -e "${RED}✗ Java: Version too old (found $version_num, need 17+)${NC}"
            echo -e "  ${YELLOW}Install Java 17: https://adoptium.net/${NC}"
            return 1
        fi
    else
        echo -e "${RED}✗ Java: NOT FOUND${NC}"
        echo -e "  ${YELLOW}Install Java 17: https://adoptium.net/${NC}"
        return 1
    fi
}

echo -e "\n${BLUE}Checking required tools...${NC}\n"

check_java
check_with_version "python3" "3.11" "Python 3" "https://www.python.org/downloads/"
check_with_version "node" "18" "Node.js" "https://nodejs.org/"
check_with_version "npm" "" "npm" "Comes with Node.js"
check_with_version "gradle" "7" "Gradle" "https://gradle.org/install/ (or use gradlew wrapper)"

echo -e "\n${BLUE}Checking optional tools...${NC}\n"

if command -v docker &> /dev/null; then
    echo -e "${GREEN}✓ Docker${NC}"
    docker --version | head -n 1 | sed 's/^/  /'
else
    echo -e "${YELLOW}○ Docker: Not installed (optional for containerization)${NC}"
fi

if command -v curl &> /dev/null; then
    echo -e "${GREEN}✓ curl${NC}"
else
    echo -e "${YELLOW}○ curl: Not installed (useful for testing)${NC}"
fi

echo -e "\n${BLUE}Checking environment variables...${NC}\n"

if [ -z "$JAVA_HOME" ]; then
    echo -e "${YELLOW}○ JAVA_HOME: Not set (recommended to set)${NC}"
else
    echo -e "${GREEN}✓ JAVA_HOME: $JAVA_HOME${NC}"
fi

echo -e "\n${BLUE}Checking ports availability...${NC}\n"

check_port() {
    local port=$1
    local service=$2
    
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        local pid=$(lsof -ti:$port)
        echo -e "${YELLOW}○ Port $port ($service): IN USE (PID: $pid)${NC}"
        return 1
    else
        echo -e "${GREEN}✓ Port $port ($service): Available${NC}"
        return 0
    fi
}

check_port 5001 "AI Risk Engine"
check_port 8080 "LEA Backend HTTP"
check_port 8082 "LEA Backend WebSocket"
check_port 8081 "Bank API"
check_port 3000 "LEA Frontend"

echo -e "\n${BLUE}Summary${NC}"
echo "=========================================="
echo "Run './scripts/setup.sh' to install dependencies"
echo "Run './scripts/start-all.sh' to start all services"
echo ""

