#!/bin/bash

# Corda Setup Helper Script

echo "=========================================="
echo "Corda CorDapp Setup Helper"
echo "=========================================="

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check for credentials
check_credentials() {
    local has_creds=false
    
    # Check gradle.properties
    if [ -f ~/.gradle/gradle.properties ]; then
        if grep -q "cordaArtifactoryUsername" ~/.gradle/gradle.properties && \
           grep -q "cordaArtifactoryPassword" ~/.gradle/gradle.properties; then
            has_creds=true
        fi
    fi
    
    # Check environment variables
    if [ ! -z "$CORDA_ARTIFACTORY_USERNAME" ] && [ ! -z "$CORDA_ARTIFACTORY_PASSWORD" ]; then
        has_creds=true
    fi
    
    if [ "$has_creds" = true ]; then
        echo -e "${GREEN}✅ Corda credentials found${NC}"
        return 0
    else
        echo -e "${RED}❌ No Corda credentials found${NC}"
        return 1
    fi
}

# Setup credentials interactively
setup_credentials() {
    echo -e "\n${YELLOW}Setting up Corda Artifactory credentials...${NC}"
    echo ""
    echo "If you don't have credentials yet:"
    echo "1. Visit: https://www.corda.net/get-corda/"
    echo "2. Sign up for Corda Open Source"
    echo "3. Check your email for Artifactory credentials"
    echo ""
    
    read -p "Do you have R3 Artifactory credentials? (y/n): " has_creds
    
    if [ "$has_creds" != "y" ]; then
        echo ""
        echo "Please get credentials from: https://www.corda.net/get-corda/"
        echo "Then run this script again."
        exit 1
    fi
    
    read -p "Enter Artifactory Username: " username
    read -sp "Enter Artifactory Password: " password
    echo ""
    
    # Create gradle.properties if it doesn't exist
    mkdir -p ~/.gradle
    touch ~/.gradle/gradle.properties
    
    # Add credentials
    if ! grep -q "cordaArtifactoryUsername" ~/.gradle/gradle.properties; then
        echo "" >> ~/.gradle/gradle.properties
        echo "# Corda Artifactory Credentials" >> ~/.gradle/gradle.properties
        echo "cordaArtifactoryUsername=$username" >> ~/.gradle/gradle.properties
        echo "cordaArtifactoryPassword=$password" >> ~/.gradle/gradle.properties
        echo -e "${GREEN}✅ Credentials added to ~/.gradle/gradle.properties${NC}"
    else
        echo -e "${YELLOW}⚠️  Credentials already exist in ~/.gradle/gradle.properties${NC}"
        read -p "Overwrite? (y/n): " overwrite
        if [ "$overwrite" = "y" ]; then
            sed -i '' "s/cordaArtifactoryUsername=.*/cordaArtifactoryUsername=$username/" ~/.gradle/gradle.properties
            sed -i '' "s/cordaArtifactoryPassword=.*/cordaArtifactoryPassword=$password/" ~/.gradle/gradle.properties
            echo -e "${GREEN}✅ Credentials updated${NC}"
        fi
    fi
}

# Generate Gradle wrapper
generate_wrapper() {
    echo -e "\n${YELLOW}Generating Gradle wrapper...${NC}"
    
    if command -v gradle &> /dev/null; then
        gradle wrapper --gradle-version 7.6
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Gradle wrapper generated${NC}"
            return 0
        else
            echo -e "${RED}❌ Failed to generate wrapper${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ Gradle not found. Install with: brew install gradle${NC}"
        return 1
    fi
}

# Build the project
build_project() {
    echo -e "\n${YELLOW}Building Corda CorDapp...${NC}"
    
    if [ -f "./gradlew" ]; then
        ./gradlew clean build
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Build successful${NC}"
            return 0
        else
            echo -e "${RED}❌ Build failed${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ gradlew not found. Run: gradle wrapper --gradle-version 7.6${NC}"
        return 1
    fi
}

# Deploy nodes
deploy_nodes() {
    echo -e "\n${YELLOW}Deploying Corda nodes...${NC}"
    
    if [ -f "./gradlew" ]; then
        ./gradlew deployNodes
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Nodes deployed successfully${NC}"
            echo -e "${GREEN}   Nodes created in: build/nodes/${NC}"
            return 0
        else
            echo -e "${RED}❌ Node deployment failed${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ gradlew not found${NC}"
        return 1
    fi
}

# Main flow
main() {
    cd "$(dirname "$0")"
    
    # Check prerequisites
    if ! command -v java &> /dev/null; then
        echo -e "${RED}❌ Java not found. Install Java 17+${NC}"
        exit 1
    fi
    
    java_version=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
    if [ "$java_version" -lt 17 ]; then
        echo -e "${RED}❌ Java 17+ required. Found: Java $java_version${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Java $java_version found${NC}"
    
    # Check credentials
    if ! check_credentials; then
        setup_credentials
    fi
    
    # Generate wrapper if needed
    if [ ! -f "./gradlew" ]; then
        generate_wrapper
    else
        echo -e "${GREEN}✅ Gradle wrapper exists${NC}"
    fi
    
    # Build
    read -p "Build the project now? (y/n): " build_now
    if [ "$build_now" = "y" ]; then
        build_project
        
        if [ $? -eq 0 ]; then
            # Deploy nodes
            read -p "Deploy nodes now? (y/n): " deploy_now
            if [ "$deploy_now" = "y" ]; then
                deploy_nodes
                
                if [ $? -eq 0 ]; then
                    echo ""
                    echo -e "${GREEN}=========================================="
                    echo "Setup Complete!"
                    echo "==========================================${NC}"
                    echo ""
                    echo "Next steps:"
                    echo "1. Start nodes: cd build/nodes && ./runnodes.sh"
                    echo "2. Wait for nodes to start"
                    echo "3. Start Bank API: cd ../../bank-api && ./gradlew bootRun"
                    echo ""
                fi
            fi
        fi
    fi
}

main "$@"

