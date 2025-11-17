# 🎯 Action Plan - Next Steps

## ✅ What's Already Done

- ✅ Complete project structure created
- ✅ All source code implemented (States, Contracts, Flows)
- ✅ All microservices created (Bank API, AI Engine, LEA Backend/Frontend)
- ✅ Docker configuration
- ✅ Helper scripts
- ✅ Comprehensive documentation

## 🚀 Immediate Next Steps (In Order)

### 1. Check Prerequisites (2 minutes)

```bash
cd /Users/harshita_shar25/Documents/corda/FraudTraceSystem
./scripts/check-prerequisites.sh
```

**Required:**
- Java 17+ ✅
- Python 3.11+ ✅
- Node.js 18+ ✅
- Gradle (or gradlew wrapper) ⚠️

### 2. Setup Dependencies (5 minutes)

```bash
./scripts/setup.sh
```

This installs:
- Python dependencies
- Node.js dependencies
- Creates necessary directories

### 3. Get Gradle Wrapper ⚠️ **CRITICAL**

The Corda CorDapp needs Gradle wrapper files. Choose one:

#### Option A: Copy from Corda Sample (Easiest)
```bash
# If you have a Corda sample project:
cp /path/to/corda-sample/gradlew cordapp/
cp /path/to/corda-sample/gradlew.bat cordapp/
cp -r /path/to/corda-sample/gradle cordapp/
```

#### Option B: Generate Wrapper
```bash
cd cordapp
# Install Gradle first: brew install gradle (macOS) or download from gradle.org
gradle wrapper --gradle-version 7.6
```

#### Option C: Use System Gradle
```bash
# If Gradle is installed globally
cd cordapp
gradle clean build deployNodes
```

### 4. Build Corda CorDapp (5-10 minutes)

```bash
cd cordapp
./gradlew clean build
```

**If successful:** You'll see build artifacts in `build/libs/`

**If it fails:** 
- Check Java version: `java -version` (must be 17)
- Check Gradle wrapper exists
- Review error messages

### 5. Deploy Corda Nodes (5-10 minutes)

```bash
cd cordapp
./gradlew deployNodes
```

**What happens:**
- Creates 4 nodes in `build/nodes/`:
  - Notary (port 10000)
  - BankA (RPC port 10006) ✅
  - BankB (RPC port 10009) ✅
  - LEA (RPC port 10012)

**Expected output:**
```
> Task :deployNodes
Building nodes...
Nodes built successfully!
```

### 6. Start Corda Nodes (2 minutes)

```bash
cd cordapp/build/nodes
./runnodes.sh  # macOS/Linux
# OR
runnodes.bat   # Windows
```

**What you'll see:**
- 4 terminal windows open (one per node)
- Nodes start up
- Wait for "started successfully" messages

**⚠️ Keep these terminals open!** Nodes must stay running.

### 7. Verify Node Configuration

Check that `bank-api/src/main/resources/application.yml` matches:

```yaml
corda:
  rpc:
    host: localhost
    port: 10006  # BankA RPC port
    username: user1
    password: test
```

This should already match! ✅

### 8. Start All Services (2 minutes)

```bash
# From project root
./scripts/start-all.sh
```

**Or start manually in separate terminals:**

**Terminal 1 - AI Risk Engine:**
```bash
cd ai-risk-engine
source venv/bin/activate
python app.py
```

**Terminal 2 - LEA Backend:**
```bash
cd lea-backend
npm start
```

**Terminal 3 - Bank API:**
```bash
cd bank-api
./gradlew bootRun
```

**Terminal 4 - LEA Frontend:**
```bash
cd lea-frontend
npm start
```

### 9. Test the System (2 minutes)

```bash
# Run integration tests
./scripts/test-system.sh

# Or test manually
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

**Expected response:**
```json
{
  "status": "alert_created",
  "riskScore": 0.85,
  "result": "..."
}
```

### 10. Open Dashboard

Open browser: **http://localhost:3000**

You should see:
- ✅ Connection status: "CONNECTED"
- ✅ Alert list (will populate when you send transactions)
- ✅ Transaction trace visualization area

## 🎯 Quick Start Commands

```bash
# 1. Check prerequisites
./scripts/check-prerequisites.sh

# 2. Setup dependencies
./scripts/setup.sh

# 3. Build Corda (after getting gradlew)
cd cordapp && ./gradlew clean build deployNodes

# 4. Start nodes (keep running)
cd build/nodes && ./runnodes.sh

# 5. Start services (in new terminal)
cd ../.. && ./scripts/start-all.sh

# 6. Test
./scripts/test-system.sh
```

## ⚠️ Common Issues & Quick Fixes

### Issue: "gradlew: command not found"

**Fix:** Get Gradle wrapper (see Step 3 above)

### Issue: "Java version error"

**Fix:**
```bash
# Check version
java -version  # Must be 17+

# Set JAVA_HOME if needed
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
```

### Issue: "Port already in use"

**Fix:**
```bash
# Find process
lsof -i :8081

# Kill process or change port in config
```

### Issue: "RPC connection failed"

**Fix:**
1. Ensure Corda node is running
2. Check port matches: `application.yml` vs node config
3. Verify credentials match

### Issue: "Python dependencies fail"

**Fix:**
```bash
cd ai-risk-engine
rm -rf venv
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## 📋 Pre-Flight Checklist

Before starting, ensure:

- [ ] Java 17+ installed (`java -version`)
- [ ] Python 3.11+ installed (`python3 --version`)
- [ ] Node.js 18+ installed (`node --version`)
- [ ] Ports available (5001, 8080, 8081, 8082, 3000)
- [ ] Gradle wrapper OR Gradle installed
- [ ] Read [GETTING_STARTED.md](GETTING_STARTED.md)

## 🎓 What to Do After It Works

1. **Explore the Code**
   - Read Corda states/contracts in `cordapp/contracts/`
   - Study flows in `cordapp/workflows/`
   - Review API endpoints in `bank-api/`

2. **Customize**
   - Modify AI risk model: `ai-risk-engine/app.py`
   - Enhance dashboard: `lea-frontend/src/`
   - Add new states/contracts

3. **Extend**
   - Add database (PostgreSQL)
   - Implement authentication
   - Add monitoring
   - Create more tests

4. **Deploy**
   - Review [DEPLOYMENT.md](DEPLOYMENT.md)
   - Set up production environment
   - Configure security ([SECURITY.md](SECURITY.md))

## 📞 Need Help?

1. Check logs: `logs/` directory
2. Review [README.md](README.md) troubleshooting
3. Check service health endpoints
4. Verify configurations match

## ✅ Success Indicators

You'll know it's working when:

- ✅ All services start without errors
- ✅ Health endpoints return 200 OK
- ✅ Test transaction creates alert
- ✅ Alert appears in dashboard
- ✅ WebSocket shows "CONNECTED"

---

## 🚀 Ready? Start Here:

```bash
cd /Users/harshita_shar25/Documents/corda/FraudTraceSystem
./scripts/check-prerequisites.sh
```

**Most Critical Step:** Get Gradle wrapper (Step 3) before building Corda!

Good luck! 🎉

