# Testing Components Without Corda

You can test most of the system without building the Corda CorDapp first. Here's how:

## Current Directory Structure

```
FraudTraceSystem/
├── ai-risk-engine/      ✅ Ready to test
├── lea-backend/         ✅ Ready to test  
├── lea-frontend/        ✅ Ready to test
├── bank-api/            ⚠️ Needs Corda for full functionality
└── cordapp/             ⚠️ Needs R3 Artifactory credentials
```

## Step-by-Step Testing

### 1. Test AI Risk Engine

**Terminal 1:**
```bash
cd /Users/harshita_shar25/Documents/corda/FraudTraceSystem/ai-risk-engine
source venv/bin/activate
python app.py
```

**Expected:** Server starts on `http://localhost:5001`

**Test it (in another terminal):**
```bash
curl -X POST http://localhost:5001/risk-score \
  -H "Content-Type: application/json" \
  -d '{
    "txId": "TEST001",
    "amount": 100000,
    "fromAccount": "ACC001",
    "toAccount": "ACC002",
    "timestamp": "2025-11-17T04:00:00Z"
  }'
```

**Expected response:**
```json
{
  "riskScore": 0.85,
  "amount": 100000,
  "anomalyScore": -0.3
}
```

### 2. Test LEA Backend

**Terminal 2:**
```bash
cd /Users/harshita_shar25/Documents/corda/FraudTraceSystem/lea-backend
npm start
```

**Expected:** 
- HTTP server on `http://localhost:8080`
- WebSocket server on `ws://localhost:8082`

**Test it:**
```bash
# Health check
curl http://localhost:8080/health

# Send test alert
curl -X POST http://localhost:8080/notify \
  -H "Content-Type: application/json" \
  -d '{
    "txId": "ALERT001",
    "amount": 50000,
    "riskScore": 0.85,
    "timestamp": "2025-11-17T04:00:00Z"
  }'
```

### 3. Test LEA Frontend

**Terminal 3:**
```bash
cd /Users/harshita_shar25/Documents/corda/FraudTraceSystem/lea-frontend
npm start
```

**Expected:** 
- Opens browser at `http://localhost:3000`
- Shows dashboard with connection status
- WebSocket connects to LEA Backend

**What to see:**
- Connection status: "CONNECTED" (green)
- Alert list (empty initially)
- When you send alerts via LEA Backend, they appear in real-time

### 4. Test Bank API (Limited - Without Corda)

**Note:** Bank API needs Corda RPC connection, so it won't work fully without Corda nodes running.

**Terminal 4:**
```bash
cd /Users/harshita_shar25/Documents/corda/FraudTraceSystem/bank-api
./gradlew bootRun
```

**Expected:** Will start but fail to connect to Corda (expected without nodes)

**What works:**
- AI Risk Engine integration (if AI Engine is running)
- HTTP endpoints respond
- Can't create blockchain alerts (needs Corda)

## Quick Test Script

Create a file `test-services.sh`:

```bash
#!/bin/bash

echo "Testing AI Risk Engine..."
curl -s -X POST http://localhost:5001/risk-score \
  -H "Content-Type: application/json" \
  -d '{"txId":"TEST","amount":100000,"fromAccount":"A","toAccount":"B","timestamp":"2025-11-17T04:00:00Z"}' \
  | jq .

echo -e "\nTesting LEA Backend..."
curl -s http://localhost:8080/health | jq .

echo -e "\nSending test alert..."
curl -s -X POST http://localhost:8080/notify \
  -H "Content-Type: application/json" \
  -d '{"txId":"ALERT001","amount":50000,"riskScore":0.85,"timestamp":"2025-11-17T04:00:00Z"}' \
  | jq .
```

## Testing Order

1. ✅ **Start AI Risk Engine** (Terminal 1)
2. ✅ **Start LEA Backend** (Terminal 2)  
3. ✅ **Start LEA Frontend** (Terminal 3)
4. ✅ **Open Dashboard** - http://localhost:3000
5. ✅ **Send test alert** via curl to LEA Backend
6. ✅ **See alert appear** in dashboard in real-time

## What Works Without Corda

- ✅ AI Risk Engine - Fully functional
- ✅ LEA Backend - Fully functional (WebSocket + HTTP)
- ✅ LEA Frontend - Fully functional (real-time updates)
- ✅ End-to-end flow: AI → LEA Backend → LEA Frontend

## What Needs Corda

- ⚠️ Bank API - Needs Corda RPC connection
- ⚠️ Blockchain alerts - Need Corda nodes running
- ⚠️ Immutable fraud records - Need Corda blockchain

## Next Steps After Testing

Once you have R3 Artifactory credentials:
1. Add credentials to `~/.gradle/gradle.properties`
2. Build Corda CorDapp: `cd cordapp && gradle wrapper && ./gradlew deployNodes`
3. Start Corda nodes: `cd build/nodes && ./runnodes.sh`
4. Then start Bank API and test full integration

