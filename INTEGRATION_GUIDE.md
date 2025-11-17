# Integration Guide

This guide provides step-by-step instructions for integrating and testing the Fraud Traceability System.

## End-to-End Integration Test

### Step 1: Start All Services

**Terminal 1 - Corda Nodes:**
```bash
cd FraudTraceSystem/cordapp
./gradlew deployNodes
cd build/nodes
./runnodes.sh
```

Wait for all nodes to start (check logs for "started successfully").

**Terminal 2 - AI Risk Engine:**
```bash
cd FraudTraceSystem/ai-risk-engine
source venv/bin/activate
python app.py
```

**Terminal 3 - LEA Backend:**
```bash
cd FraudTraceSystem/lea-backend
npm start
```

**Terminal 4 - Bank API:**
```bash
cd FraudTraceSystem/bank-api
./gradlew bootRun
```

**Terminal 5 - LEA Frontend:**
```bash
cd FraudTraceSystem/lea-frontend
npm start
```

### Step 2: Verify Services

1. **AI Risk Engine**: `curl http://localhost:5001/health`
2. **LEA Backend**: `curl http://localhost:8080/health`
3. **Bank API**: `curl http://localhost:8081/fraud/analyze` (should return error without body, but service is up)
4. **Frontend**: Open `http://localhost:3000` in browser

### Step 3: Test Transaction Flow

**Send a low-risk transaction:**
```bash
curl -X POST http://localhost:8081/fraud/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "txId": "TXN001",
    "amount": 1000,
    "fromAccount": "ACC001",
    "toAccount": "ACC002",
    "timestamp": "2025-11-17T04:00:00Z"
  }'
```

Expected: `{"status":"ok","riskScore":0.XX}` (low risk, no alert)

**Send a high-risk transaction:**
```bash
curl -X POST http://localhost:8081/fraud/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "txId": "TXN002",
    "amount": 100000,
    "fromAccount": "ACC001",
    "toAccount": "ACC002",
    "timestamp": "2025-11-17T04:00:00Z"
  }'
```

Expected: Alert created in Corda and broadcast to LEA dashboard

### Step 4: Verify in Dashboard

1. Open `http://localhost:3000`
2. Check connection status (should be "CONNECTED")
3. Verify alert appears in the list
4. Click alert to see trace visualization

## Component Integration Points

### Bank API → AI Risk Engine

- **Endpoint**: `POST /risk-score`
- **Protocol**: HTTP REST
- **Data Flow**: TransactionDTO → RiskScoreResponse

### Bank API → Corda RPC

- **Protocol**: Corda RPC
- **Flow**: `SendFraudAlertFlow`
- **Configuration**: `application.yml` → `corda.rpc.*`

### Bank API → LEA Backend

- **Endpoint**: `POST /notify`
- **Protocol**: HTTP REST
- **Purpose**: Broadcast alerts to LEA

### LEA Backend → LEA Frontend

- **Protocol**: WebSocket
- **Port**: 8082
- **Message Format**: JSON with `type` and `data` fields

## Testing Individual Components

### Test AI Risk Engine

```bash
curl -X POST http://localhost:5001/risk-score \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 50000,
    "txId": "TEST"
  }'
```

### Test LEA Backend Notification

```bash
curl -X POST http://localhost:8080/notify \
  -H "Content-Type: application/json" \
  -d '{
    "txId": "TEST001",
    "amount": 50000,
    "riskScore": 0.85,
    "timestamp": "2025-11-17T04:00:00Z"
  }'
```

Check WebSocket clients receive the message.

### Test Corda Flow (from node shell)

```bash
# In BankA node shell
flow start SendFraudAlertFlow \
  txId:"MANUAL001" \
  amount:50000 \
  destination:PartyB \
  riskScore:0.9 \
  message:"manual test"
```

## Common Integration Issues

### Issue: Bank API cannot connect to Corda

**Symptoms**: `Connection refused` or `RPC connection failed`

**Solutions**:
1. Verify node is running: Check node logs
2. Check RPC port: Ensure `node.conf` matches `application.yml`
3. Verify credentials: Username/password must match
4. Check firewall: RPC port must be accessible

### Issue: AI Risk Engine not responding

**Symptoms**: `Connection refused` or timeout

**Solutions**:
1. Check Python service is running: `curl http://localhost:5001/health`
2. Verify port: Check `app.py` PORT configuration
3. Check dependencies: `pip install -r requirements.txt`

### Issue: WebSocket not connecting

**Symptoms**: Frontend shows "DISCONNECTED"

**Solutions**:
1. Verify LEA backend is running: `curl http://localhost:8080/health`
2. Check WebSocket port: Default is 8082
3. Check CORS: Ensure `cors` package is installed
4. Browser console: Check for WebSocket errors

### Issue: Alerts not appearing in dashboard

**Symptoms**: Alert created but not visible

**Solutions**:
1. Check WebSocket connection status
2. Verify Bank API → LEA Backend notification: Check LEA backend logs
3. Check browser console for errors
4. Verify alert format matches expected schema

## Performance Testing

### Load Test AI Risk Engine

```bash
# Using Apache Bench
ab -n 1000 -c 10 -p test_tx.json -T application/json \
  http://localhost:5001/risk-score
```

### Load Test Bank API

```bash
ab -n 100 -c 5 -p test_tx.json -T application/json \
  http://localhost:8081/fraud/analyze
```

## Monitoring

### Check Service Health

```bash
# All services
curl http://localhost:5001/health  # AI Engine
curl http://localhost:8080/health  # LEA Backend
curl http://localhost:8081/actuator/health  # Bank API (if actuator enabled)
```

### View Logs

```bash
# Corda nodes
tail -f cordapp/build/nodes/BankA/logs/node.log

# Bank API (Spring Boot logs)
# Check console output or logs/ directory

# LEA Backend
# Check console output

# AI Risk Engine
# Check console output
```

## Next Steps

1. **Add Database**: Store alerts in PostgreSQL
2. **Add Authentication**: Implement JWT for APIs
3. **Add Monitoring**: Integrate Prometheus/Grafana
4. **Add Logging**: Centralized logging with ELK stack
5. **Add Tests**: Unit and integration tests
6. **Production Hardening**: Security, performance tuning

