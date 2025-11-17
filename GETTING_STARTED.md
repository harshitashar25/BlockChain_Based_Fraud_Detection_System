# Getting Started Guide

Welcome to the Fraud Traceability System! This guide will help you get up and running quickly.

## Quick Start (5 Minutes)

### Step 1: Check Prerequisites

```bash
# Run the prerequisites check script
./scripts/check-prerequisites.sh

# Or use Make
make check
```

You need:
- ✅ Java 17+
- ✅ Python 3.11+
- ✅ Node.js 18+
- ✅ npm (comes with Node.js)

### Step 2: Setup Dependencies

```bash
# Run setup script
./scripts/setup.sh

# Or use Make
make setup
```

This will:
- Create Python virtual environment
- Install Python dependencies
- Install Node.js dependencies
- Create necessary directories

### Step 3: Build Corda CorDapp

```bash
cd cordapp
./gradlew clean build deployNodes
cd ..
```

**Note:** If you don't have a Corda sample project with `gradlew`, you'll need to:
1. Get a Corda sample project from R3
2. Copy the `gradlew` and `gradle/` directory to the `cordapp/` folder
3. Or install Gradle globally

### Step 4: Start Corda Nodes

```bash
cd cordapp/build/nodes
./runnodes.sh  # On Windows: runnodes.bat
```

Wait for all nodes to start. You should see:
- Notary node
- BankA node
- BankB node
- (Optional) LEA node

### Step 5: Start Services

**Option A: Using Scripts (Recommended)**

```bash
./scripts/start-all.sh
```

**Option B: Using Make**

```bash
make start
```

**Option C: Manual (for debugging)**

Terminal 1 - AI Risk Engine:
```bash
cd ai-risk-engine
source venv/bin/activate  # Windows: venv\Scripts\activate
python app.py
```

Terminal 2 - LEA Backend:
```bash
cd lea-backend
npm start
```

Terminal 3 - Bank API:
```bash
cd bank-api
./gradlew bootRun
```

Terminal 4 - LEA Frontend:
```bash
cd lea-frontend
npm start
```

### Step 6: Test the System

```bash
# Run integration tests
./scripts/test-system.sh

# Or manually test
curl -X POST http://localhost:8081/fraud/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "txId": "TXN001",
    "amount": 100000,
    "fromAccount": "ACC001",
    "toAccount": "ACC002",
    "timestamp": "2025-11-17T04:00:00Z"
  }'
```

Open `http://localhost:3000` in your browser to see the dashboard.

## Common Commands

### Using Make (Linux/macOS)

```bash
make help          # Show all commands
make setup         # Setup dependencies
make build-cordapp # Build Corda CorDapp
make start         # Start all services
make stop          # Stop all services
make test          # Run tests
make status        # Check service status
make clean         # Clean build artifacts
```

### Using Scripts

```bash
./scripts/check-prerequisites.sh  # Check prerequisites
./scripts/setup.sh                # Setup dependencies
./scripts/start-all.sh            # Start all services
./scripts/stop-all.sh             # Stop all services
./scripts/test-system.sh          # Run integration tests
```

### Using Docker Compose

```bash
docker-compose up -d              # Start services
docker-compose down               # Stop services
docker-compose logs -f           # View logs
docker-compose ps                # Check status
```

## Service URLs

Once started, services are available at:

- **AI Risk Engine**: http://localhost:5001
- **LEA Backend HTTP**: http://localhost:8080
- **LEA Backend WebSocket**: ws://localhost:8082
- **Bank API**: http://localhost:8081
- **LEA Frontend**: http://localhost:3000

## Troubleshooting

### Port Already in Use

```bash
# Find process using port
lsof -i :8081  # macOS/Linux
netstat -ano | findstr :8081  # Windows

# Kill process or change port in configuration
```

### Corda RPC Connection Failed

1. Check node is running: `ps aux | grep java`
2. Verify RPC port in `node.conf` matches `application.yml`
3. Check credentials match

### Services Not Starting

1. Check logs in `logs/` directory
2. Verify prerequisites: `./scripts/check-prerequisites.sh`
3. Check port availability
4. Review error messages

### Python Virtual Environment Issues

```bash
# Recreate virtual environment
cd ai-risk-engine
rm -rf venv
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### Node.js Dependency Issues

```bash
# Clear and reinstall
cd lea-backend
rm -rf node_modules package-lock.json
npm install

cd ../lea-frontend
rm -rf node_modules package-lock.json
npm install
```

## Next Steps

1. **Read Documentation**
   - [README.md](README.md) - Full documentation
   - [QUICKSTART.md](QUICKSTART.md) - Quick start guide
   - [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) - Integration details
   - [SECURITY.md](SECURITY.md) - Security guidelines
   - [DEPLOYMENT.md](DEPLOYMENT.md) - Deployment guide

2. **Explore the Code**
   - Corda states and contracts: `cordapp/contracts/src/main/kotlin/`
   - Corda flows: `cordapp/workflows/src/main/kotlin/`
   - Bank API: `bank-api/src/main/kotlin/`
   - AI Engine: `ai-risk-engine/app.py`
   - Frontend: `lea-frontend/src/`

3. **Customize**
   - Update node configurations: `configs/node.conf.example`
   - Modify AI risk model: `ai-risk-engine/app.py`
   - Customize dashboard: `lea-frontend/src/`

4. **Test**
   - Run unit tests: `make test`
   - Run integration tests: `make test-system`
   - Test individual services

5. **Deploy**
   - Review [DEPLOYMENT.md](DEPLOYMENT.md)
   - Set up production environment
   - Configure security (see [SECURITY.md](SECURITY.md))

## Getting Help

- Check logs: `logs/` directory
- Review documentation files
- Check service health endpoints
- Verify configuration files

## Development Tips

1. **Hot Reload**
   - Frontend: React hot reload enabled
   - Backend: Use `npm run dev` for nodemon
   - Bank API: Spring Boot DevTools (if added)

2. **Debugging**
   - Check service logs
   - Use browser DevTools for frontend
   - Enable debug logging in `application.yml`

3. **Testing**
   - Write unit tests for new features
   - Test contracts: `cd cordapp && ./gradlew test`
   - Test AI engine: `cd ai-risk-engine && python test_risk_engine.py`

4. **Code Quality**
   - Follow Kotlin/Python/JavaScript style guides
   - Add comments and documentation
   - Write tests for new code

## Architecture Overview

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│  Bank API   │────▶│ AI Risk      │     │   Corda     │
│ (Spring Boot)│     │ Engine       │     │  Blockchain │
└─────────────┘     └──────────────┘     └─────────────┘
       │                    │                     │
       │                    │                     │
       ▼                    ▼                     ▼
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│ LEA Backend │◀────│ LEA Frontend │     │   Nodes     │
│  (Node.js)  │     │   (React)    │     │  (BankA/B)  │
└─────────────┘     └──────────────┘     └─────────────┘
```

## Support

For issues or questions:
1. Check documentation
2. Review logs
3. Verify configuration
4. Test individual components

Happy coding! 🚀

