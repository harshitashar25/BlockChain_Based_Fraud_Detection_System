# Makefile for Fraud Traceability System
# Provides convenient commands for common tasks

.PHONY: help setup check build test start stop clean

help: ## Show this help message
	@echo "Fraud Traceability System - Makefile Commands"
	@echo "=============================================="
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

setup: ## Run setup script to install dependencies
	@./scripts/setup.sh

check: ## Check prerequisites
	@./scripts/check-prerequisites.sh

build-cordapp: ## Build Corda CorDapp
	@cd cordapp && ./gradlew clean build

deploy-nodes: ## Deploy Corda nodes
	@cd cordapp && ./gradlew deployNodes

build-all: build-cordapp ## Build all components
	@cd bank-api && ./gradlew build
	@echo "Build complete"

test: ## Run all tests
	@cd cordapp && ./gradlew test
	@cd ai-risk-engine && python test_risk_engine.py

start: ## Start all services
	@./scripts/start-all.sh

stop: ## Stop all services
	@./scripts/stop-all.sh

test-system: ## Run integration tests
	@./scripts/test-system.sh

clean: ## Clean build artifacts
	@cd cordapp && ./gradlew clean
	@cd bank-api && ./gradlew clean
	@rm -rf logs
	@find . -type d -name "node_modules" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name ".gradle" -exec rm -rf {} + 2>/dev/null || true

docker-build: ## Build Docker images
	@docker-compose build

docker-up: ## Start services with Docker Compose
	@docker-compose up -d

docker-down: ## Stop Docker Compose services
	@docker-compose down

docker-logs: ## View Docker Compose logs
	@docker-compose logs -f

install-python-deps: ## Install Python dependencies
	@cd ai-risk-engine && python3 -m venv venv && source venv/bin/activate && pip install -r requirements.txt

install-node-deps: ## Install Node.js dependencies
	@cd lea-backend && npm install
	@cd lea-frontend && npm install

status: ## Check service status
	@echo "Checking service status..."
	@curl -s http://localhost:5001/health > /dev/null && echo "✓ AI Risk Engine" || echo "✗ AI Risk Engine"
	@curl -s http://localhost:8080/health > /dev/null && echo "✓ LEA Backend" || echo "✗ LEA Backend"
	@curl -s http://localhost:8081/actuator/health > /dev/null && echo "✓ Bank API" || echo "✗ Bank API"
	@curl -s http://localhost:3000 > /dev/null && echo "✓ LEA Frontend" || echo "✗ LEA Frontend"

.DEFAULT_GOAL := help

