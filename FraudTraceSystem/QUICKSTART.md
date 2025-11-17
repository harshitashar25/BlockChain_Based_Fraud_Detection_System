# Quick Start Guide

Get the Fraud Traceability System up and running in 5 minutes.

## Prerequisites Check

```bash
# Java 17
java -version  # Should show version 17.x

# Python 3.11+
python --version

# Node.js 18+
node --version

# Gradle (or use gradlew wrapper)
gradle --version
```

## Step-by-Step Setup

### 1. Build Corda CorDapp

```bash
cd FraudTraceSystem/cordapp
./gradlew clean build
./gradlew deployNodes
```

### 2. Start Corda Nodes

```bash
cd build/nodes
./runnodes.sh  # On Windows: runnodes.bat
```

Wait for all nodes to start (check terminal output for "started successfully").

### 3. Start AI Risk Engine

```bash
cd FraudTraceSystem/ai-risk-engine
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
python app.py
```

### 4. Start LEA Backend

```bash
cd FraudTraceSystem/lea-backend
npm install
npm start
```

### 5. Start Bank API

```bash
cd FraudTraceSystem/bank-api
./gradlew bootRun
```

**Important**: Before starting, ensure:
- Corda node is running
- Update `src/main/resources/application.yml` with correct RPC port (10006 for BankA)

### 6. Start LEA Frontend

```bash
cd FraudTraceSystem/lea-frontend
npm install
npm start
```

Dashboard opens automatically at `http://localhost:3000`

## Test the System

### Send a Test Transaction

```bash
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

### Expected Result

1. AI Risk Engine calculates risk score
2. If risk >= 0.7, Bank API creates Corda alert
3. Alert is sent to LEA Backend
4. LEA Frontend displays alert in real-time

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
2. Verify RPC port in `node.conf`
3. Check `application.yml` matches node configuration

### WebSocket Not Connecting

1. Verify LEA Backend is running: `curl http://localhost:8080/health`
2. Check browser console for errors
3. Verify WebSocket URL in frontend code

## Next Steps

- Read [README.md](README.md) for detailed documentation
- Read [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) for integration details
- Read [SECURITY.md](SECURITY.md) for security best practices

## Common Commands

```bash
# Rebuild Corda CorDapp
cd cordapp && ./gradlew clean build deployNodes

# Check service health
curl http://localhost:5001/health  # AI Engine
curl http://localhost:8080/health  # LEA Backend
curl http://localhost:8081/actuator/health  # Bank API

# View Corda node logs
tail -f cordapp/build/nodes/BankA/logs/node.log
```

## Docker Alternative

If you prefer Docker:

```bash
# Build and start services (except Corda nodes)
docker-compose up --build

# Note: Corda nodes must run on host machine
```

## Getting Help

- Check logs in each service directory
- Review error messages in browser console (for frontend)
- Verify all prerequisites are installed
- Ensure ports are not blocked by firewall

