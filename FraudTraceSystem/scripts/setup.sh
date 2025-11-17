#!/bin/bash

# Setup Script - Install dependencies and prepare environment

set -e

echo "=========================================="
echo "Fraud Traceability System - Setup Script"
echo "=========================================="

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check prerequisites
check_prerequisite() {
    if command -v $1 &> /dev/null; then
        local version=$($1 --version 2>&1 | head -n 1)
        echo -e "${GREEN}✓ $1: $version${NC}"
        return 0
    else
        echo -e "${RED}✗ $1: NOT FOUND${NC}"
        return 1
    fi
}

echo -e "${YELLOW}Checking prerequisites...${NC}"
check_prerequisite java || echo "  Install Java 17: https://adoptium.net/"
check_prerequisite python3 || echo "  Install Python 3.11+: https://www.python.org/"
check_prerequisite node || echo "  Install Node.js 18+: https://nodejs.org/"
check_prerequisite npm || echo "  Install npm (comes with Node.js)"

# Setup Python virtual environment
echo -e "\n${YELLOW}Setting up Python virtual environment...${NC}"
cd ai-risk-engine
if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo -e "${GREEN}Created virtual environment${NC}"
fi
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
echo -e "${GREEN}Python dependencies installed${NC}"
deactivate
cd ..

# Setup Node.js dependencies
echo -e "\n${YELLOW}Setting up Node.js dependencies...${NC}"

echo "Installing LEA Backend dependencies..."
cd lea-backend
npm install
cd ..

echo "Installing LEA Frontend dependencies..."
cd lea-frontend
npm install
cd ..

echo -e "${GREEN}Node.js dependencies installed${NC}"

# Setup Gradle wrapper (if needed)
echo -e "\n${YELLOW}Checking Gradle setup...${NC}"
if [ ! -f "cordapp/gradlew" ]; then
    echo "Gradle wrapper not found. Please ensure you have a Corda sample project with gradlew"
    echo "Or install Gradle: https://gradle.org/install/"
else
    echo -e "${GREEN}Gradle wrapper found${NC}"
fi

# Create necessary directories
echo -e "\n${YELLOW}Creating directories...${NC}"
mkdir -p logs
mkdir -p cordapp/build/nodes
echo -e "${GREEN}Directories created${NC}"

# Make scripts executable
chmod +x scripts/*.sh

echo -e "\n${GREEN}=========================================="
echo "Setup complete!"
echo "==========================================${NC}"
echo ""
echo "Next steps:"
echo "1. Configure Corda nodes (see examples in configs/)"
echo "2. Build Corda CorDapp: cd cordapp && ./gradlew deployNodes"
echo "3. Start services: ./scripts/start-all.sh"
echo ""
