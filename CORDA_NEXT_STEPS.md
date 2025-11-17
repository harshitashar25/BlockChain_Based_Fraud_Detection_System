# 🎯 Next Steps: Get Corda Working

## Current Status

✅ **Working Components:**
- AI Risk Engine - Running and tested
- LEA Backend - Running and tested  
- LEA Frontend - Running and tested
- Dashboard showing real-time alerts

⏳ **Needs Setup:**
- Corda CorDapp - Requires R3 Artifactory credentials
- Bank API - Waiting for Corda nodes

## 🚀 Quick Path to Get Corda Working

### Step 1: Get R3 Artifactory Credentials (5 minutes)

**Option A: Sign Up Online**
1. Visit: **https://www.corda.net/get-corda/**
2. Fill out the registration form
3. Check your email for Artifactory credentials

**Option B: Use Helper Script**
```bash
cd /Users/harshita_shar25/Documents/corda/FraudTraceSystem/cordapp
./setup-corda.sh
```

This script will:
- Check if you have credentials
- Help you add them if you don't
- Generate Gradle wrapper
- Build the project
- Deploy nodes

### Step 2: Add Credentials

Once you have credentials, add them:

```bash
# Edit the file
nano ~/.gradle/gradle.properties

# Add these lines:
cordaArtifactoryUsername=your-username
cordaArtifactoryPassword=your-password
```

### Step 3: Build Corda

```bash
cd /Users/harshita_shar25/Documents/corda/FraudTraceSystem/cordapp

# Generate wrapper (if not done)
gradle wrapper --gradle-version 7.6

# Build
./gradlew clean build

# Deploy nodes
./gradlew deployNodes
```

### Step 4: Start Corda Nodes

```bash
cd build/nodes
./runnodes.sh
```

**Keep this terminal open!** You'll see 4 node windows open.

### Step 5: Start Bank API

**In a new terminal:**
```bash
cd /Users/harshita_shar25/Documents/corda/FraudTraceSystem/bank-api
./gradlew bootRun
```

### Step 6: Test Full Flow

```bash
# Send a transaction
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
1. AI calculates risk score (high risk)
2. Bank API creates Corda alert
3. Alert appears in dashboard
4. Alert stored on blockchain

## 📋 Checklist

- [ ] Get R3 Artifactory credentials
- [ ] Add credentials to `~/.gradle/gradle.properties`
- [ ] Generate Gradle wrapper: `gradle wrapper --gradle-version 7.6`
- [ ] Build CorDapp: `./gradlew clean build`
- [ ] Deploy nodes: `./gradlew deployNodes`
- [ ] Start nodes: `cd build/nodes && ./runnodes.sh`
- [ ] Start Bank API: `cd bank-api && ./gradlew bootRun`
- [ ] Test end-to-end flow

## 🆘 Need Help?

- **Credentials:** See `cordapp/GET_CORDA_CREDENTIALS.md`
- **Quick Start:** See `cordapp/QUICK_START_CORDA.md`
- **Setup Script:** Run `cordapp/setup-corda.sh`
- **R3 Website:** https://www.corda.net/get-corda/

## 🎉 Once Working

You'll have a complete blockchain-enabled fraud detection system:
- ✅ AI-powered risk scoring
- ✅ Blockchain immutability (Corda)
- ✅ Real-time alerting (WebSocket)
- ✅ Visual dashboard (React)
- ✅ Full audit trail

**Ready to proceed?** Get your R3 credentials and run `./setup-corda.sh`!

