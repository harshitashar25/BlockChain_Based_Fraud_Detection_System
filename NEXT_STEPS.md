# Next Steps - Action Plan

This document outlines the immediate next steps to get your Fraud Traceability System running.

## 🎯 Immediate Actions (Do These First)

### Step 1: Verify Prerequisites ✅

```bash
cd /Users/harshita_shar25/Documents/corda/FraudTraceSystem
./scripts/check-prerequisites.sh
```

**What to check:**
- ✅ Java 17+ installed
- ✅ Python 3.11+ installed  
- ✅ Node.js 18+ installed
- ✅ Ports 5001, 8080, 8081, 8082, 3000 available

**If missing:** Install prerequisites before proceeding.

### Step 2: Setup Dependencies ✅

```bash
./scripts/setup.sh
```

**This will:**
- Create Python virtual environment
- Install Python dependencies
- Install Node.js dependencies
- Create necessary directories

### Step 3: Get Corda Gradle Wrapper ⚠️

**IMPORTANT:** The Corda CorDapp needs Gradle wrapper files. You have two options:

#### Option A: Use Existing Corda Sample (Recommended)
```bash
# If you have a Corda sample project (like from R3 tutorials):
# Copy gradlew, gradlew.bat, and gradle/ directory to cordapp/
cp /path/to/corda-sample/gradlew cordapp/
cp /path/to/corda-sample/gradlew.bat cordapp/
cp -r /path/to/corda-sample/gradle cordapp/
```

#### Option B: Generate Gradle Wrapper
```bash
cd cordapp
# Install Gradle first: https://gradle.org/install/
gradle wrapper --gradle-version 7.6
```

#### Option C: Use System Gradle
```bash
# If Gradle is installed globally, you can use:
cd cordapp
gradle clean build deployNodes
```

### Step 4: Configure Corda Nodes ⚠️

Before deploying nodes, you need to configure them. The system expects:

1. **BankA Node** - RPC port 10006
2. **BankB Node** - RPC port 10009  
3. **Notary Node** - Standard notary setup
4. **LEA Node** (optional) - For law enforcement

**Action:** You'll need to either:
- Use Corda's `deployNodes` task with proper configuration
- Or manually configure nodes after deployment

**Example node configuration** (see `configs/node.conf.example`):
```hocon
myLegalName="O=BankA,L=London,C=GB"
p2pAddress="localhost:10002"
rpcSettings {
    address="localhost:10006"
    adminAddress="localhost:10046"
}
rpcUsers=[ {
    password=test
    permissions=[ ALL ]
    user= "user1"
}]
```

### Step 5: Build and Deploy Corda Nodes 🚀

```bash
cd cordapp
./gradlew clean build deployNodes
```

**Expected output:**
- Builds contracts and workflows
- Creates node directories in `build/nodes/`
- Generates node configurations

**If this fails:**
- Check Java version: `java -version` (must be 17)
- Check Gradle wrapper exists
- Review error messages

### Step 6: Start Corda Nodes 🚀

```bash
cd cordapp/build/nodes
./runnodes.sh  # On macOS/Linux
# OR
runnodes.bat   # On Windows
```

**What happens:**
- Multiple terminal windows open (one per node)
- Nodes start up and connect to network
- Wait for "started successfully" messages

**Troubleshooting:**
- If ports are in use, modify node configurations
- Check node logs in `logs/` directory
- Ensure all nodes can communicate

### Step 7: Update Bank API Configuration ⚙️

Edit `bank-api/src/main/resources/application.yml`:

```yaml
corda:
  rpc:
    host: localhost
    port: 10006  # Match your BankA node RPC port
    username: user1
    password: test  # Match your node RPC password
```

**Important:** The port and credentials must match your actual Corda node configuration!

### Step 8: Start All Services 🚀

```bash
# From project root
./scripts/start-all.sh
```

**Or start manually:**

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

### Step 9: Test the System ✅

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

**Expected:**
- AI Risk Engine calculates risk score
- If risk >= 0.7, alert created in Corda
- Alert appears in LEA Frontend dashboard

### Step 10: Open Dashboard 🌐

Open browser: `http://localhost:3000`

You should see:
- Connection status (should be "CONNECTED")
- Alert list (empty initially)
- Transaction trace visualization area

## 🔧 Common Issues & Solutions

### Issue: Gradle Wrapper Missing

**Solution:**
```bash
cd cordapp
# Option 1: Copy from Corda sample
# Option 2: Generate wrapper
gradle wrapper --gradle-version 7.6
# Option 3: Use system Gradle
gradle clean build deployNodes
```

### Issue: RPC Connection Failed

**Check:**
1. Node is running: `ps aux | grep java`
2. RPC port matches: Check `node.conf` vs `application.yml`
3. Credentials match: Username/password must be identical
4. Firewall: Port must be accessible

**Fix:**
- Update `bank-api/src/main/resources/application.yml`
- Or update node's `node.conf`
- Restart both node and bank-api

### Issue: Port Already in Use

**Find process:**
```bash
lsof -i :8081  # macOS/Linux
netstat -ano | findstr :8081  # Windows
```

**Kill process or change port in configuration**

### Issue: Python Dependencies Fail

**Solution:**
```bash
cd ai-risk-engine
rm -rf venv
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

### Issue: Node.js Dependencies Fail

**Solution:**
```bash
cd lea-backend
rm -rf node_modules package-lock.json
npm install

cd ../lea-frontend
rm -rf node_modules package-lock.json
npm install
```

## 📋 Pre-Flight Checklist

Before starting, ensure:

- [ ] Java 17+ installed and JAVA_HOME set
- [ ] Python 3.11+ installed
- [ ] Node.js 18+ and npm installed
- [ ] Gradle wrapper in `cordapp/` OR Gradle installed globally
- [ ] Ports 5001, 8080, 8081, 8082, 3000 available
- [ ] Corda sample project available (for gradlew) OR Gradle installed
- [ ] Read [GETTING_STARTED.md](GETTING_STARTED.md)
- [ ] Read [QUICKSTART.md](QUICKSTART.md)

## 🎓 Learning Resources

1. **Corda Basics**: https://docs.corda.net/
2. **Spring Boot**: https://spring.io/guides
3. **React**: https://react.dev/learn
4. **Docker**: https://docs.docker.com/get-started/

## 🚀 After Everything Works

Once the system is running:

1. **Explore the Code**
   - Read through Corda states and contracts
   - Understand the flows
   - Review API endpoints
   - Study the frontend components

2. **Customize**
   - Modify AI risk model
   - Add new states/contracts
   - Enhance dashboard
   - Add authentication

3. **Extend**
   - Add database integration
   - Implement authentication
   - Add monitoring
   - Create more tests

4. **Deploy**
   - Review [DEPLOYMENT.md](DEPLOYMENT.md)
   - Set up production environment
   - Configure security (see [SECURITY.md](SECURITY.md))

## 📞 Getting Help

If you encounter issues:

1. Check logs in `logs/` directory
2. Review [README.md](README.md) troubleshooting section
3. Check service health endpoints
4. Verify all configurations match
5. Review error messages carefully

## ✅ Success Criteria

You'll know everything works when:

- ✅ All services start without errors
- ✅ Health endpoints return 200 OK
- ✅ Test transaction creates alert
- ✅ Alert appears in dashboard
- ✅ WebSocket connection shows "CONNECTED"
- ✅ Trace visualization displays data

## 🎯 Priority Order

1. **CRITICAL**: Get Gradle wrapper or install Gradle
2. **CRITICAL**: Build and deploy Corda nodes
3. **IMPORTANT**: Configure RPC connection
4. **IMPORTANT**: Start all services
5. **NICE TO HAVE**: Run tests and verify

---

**Ready to start?** Begin with Step 1: `./scripts/check-prerequisites.sh`

Good luck! 🚀

