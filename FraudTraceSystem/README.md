# Blockchain-Enabled Financial Fraud Traceability System

A comprehensive system for detecting, tracking, and managing financial fraud using Corda blockchain, AI risk scoring, and real-time dashboards.

## Architecture

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

## Project Structure

```
FraudTraceSystem/
├── cordapp/                 # Corda CorDapp
│   ├── contracts/           # States and Contracts
│   ├── workflows/           # Flows
│   └── build.gradle
├── bank-api/                # Spring Boot microservice
│   └── src/main/kotlin/
├── ai-risk-engine/          # Python Flask AI service
│   └── app.py
├── lea-backend/             # Node.js WebSocket server
│   └── server.js
├── lea-frontend/            # React dashboard
│   └── src/
└── docker-compose.yml
```

## Prerequisites

1. **Java 17** - Required for Corda and Spring Boot
   ```bash
   java -version
   ```

2. **Gradle** - For building Corda CorDapp and Spring Boot
   ```bash
   gradle --version
   ```

3. **Python 3.11+** - For AI Risk Engine
   ```bash
   python --version
   ```

4. **Node.js 18+** - For LEA Backend and Frontend
   ```bash
   node --version
   ```

5. **Corda 4.12** - Corda Enterprise or Open Source

## Quick Start

### Phase 1: Build and Deploy Corda Nodes

```bash
cd cordapp
./gradlew clean
./gradlew deployNodes
cd build/nodes
./runnodes.sh  # On Windows: runnodes.bat
```

This starts:
- Notary node
- BankA node (RPC port 10006)
- BankB node (RPC port 10009)
- LEA node (optional)

### Phase 2: Start AI Risk Engine

```bash
cd ai-risk-engine
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
python app.py
```

Service runs on `http://localhost:5001`

### Phase 3: Start LEA Backend

```bash
cd lea-backend
npm install
npm start
```

Service runs on:
- HTTP: `http://localhost:8080`
- WebSocket: `ws://localhost:8082`

### Phase 4: Start Bank API

```bash
cd bank-api
./gradlew bootRun
```

Service runs on `http://localhost:8081`

**Important**: Update `application.yml` with correct Corda RPC connection details for your node.

### Phase 5: Start LEA Frontend

```bash
cd lea-frontend
npm install
npm start
```

Dashboard opens at `http://localhost:3000`

## Testing the System

### 1. Send a Test Transaction

```bash
curl -X POST http://localhost:8081/fraud/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "txId": "TXN101",
    "amount": 50000,
    "fromAccount": "ACC001",
    "toAccount": "ACC002",
    "timestamp": "2025-11-17T04:00:00Z"
  }'
```

### 2. Check AI Risk Score

```bash
curl -X POST http://localhost:5001/risk-score \
  -H "Content-Type: application/json" \
  -d '{
    "txId": "TXN101",
    "amount": 50000,
    "fromAccount": "ACC001",
    "toAccount": "ACC002",
    "timestamp": "2025-11-17T04:00:00Z"
  }'
```

### 3. View Alerts in Dashboard

Open `http://localhost:3000` and watch for real-time alerts.

## Docker Deployment

### Build and Run All Services

```bash
docker-compose up --build
```

**Note**: Corda nodes must run on the host machine (not in Docker) due to RPC requirements.

### Run Individual Services

```bash
docker-compose up ai-risk-engine
docker-compose up lea-backend
docker-compose up lea-frontend
```

## Corda Flow Invocation

### From Node Shell

```bash
# Connect to BankA node shell
flow start SendFraudAlertFlow txId:"TXN001" amount:10000 destination:PartyB riskScore:0.9 message:"suspicious"
```

### Query Vault

```bash
run vaultQuery contractStateType: com.quadra.fraud.states.FraudAlertState
```

## Configuration

### Bank API Configuration

Edit `bank-api/src/main/resources/application.yml`:

```yaml
corda:
  rpc:
    host: localhost
    port: 10006  # BankA RPC port
    username: user1
    password: test
```

### Node Configuration

Each Corda node's `node.conf` should include:

```hocon
rpcSettings {
    address="localhost:10006"
    adminAddress="localhost:10046"
}
rpcUsers=[ {
    password=test
    permissions=[ ALL ]
    user= "user1"
}]
myLegalName="O=BankA,L=London,C=GB"
p2pAddress="localhost:10002"
```

## API Endpoints

### Bank API

- `POST /fraud/analyze` - Analyze transaction and create alert if risky

### AI Risk Engine

- `POST /risk-score` - Calculate fraud risk score
- `GET /health` - Health check

### LEA Backend

- `POST /notify` - Receive fraud alerts
- `GET /alerts` - Get all alerts
- `GET /health` - Health check

## Development

### Adding New States/Contracts

1. Create state in `cordapp/contracts/src/main/kotlin/com/quadra/fraud/states/`
2. Create contract in `cordapp/contracts/src/main/kotlin/com/quadra/fraud/contracts/`
3. Create flow in `cordapp/workflows/src/main/kotlin/com/quadra/fraud/flows/`
4. Rebuild: `./gradlew clean build`
5. Redeploy nodes: `./gradlew deployNodes`

### Testing

```bash
# Corda tests
cd cordapp
./gradlew test

# Bank API tests
cd bank-api
./gradlew test

# Python tests
cd ai-risk-engine
pytest
```

## Troubleshooting

### RPC Connection Failed

- Ensure Corda node is running
- Check RPC port in `node.conf`
- Verify credentials match `application.yml`

### WebSocket Not Connecting

- Check LEA backend is running on port 8082
- Verify CORS settings
- Check browser console for errors

### Gradle Build Fails

- Ensure Java 17 is active: `java -version`
- Check `JAVA_HOME` environment variable
- Clean build: `./gradlew clean`

## Security Considerations

1. **RPC Security**: Use TLS in production
2. **API Authentication**: Add JWT/OAuth for HTTP endpoints
3. **WebSocket Security**: Implement authentication
4. **Data Privacy**: Don't send raw customer data to AI engine
5. **Secrets Management**: Use environment variables or secrets manager

## Production Deployment

1. Use HTTPS for all HTTP endpoints
2. Enable RPC TLS in Corda nodes
3. Implement authentication/authorization
4. Set up monitoring and logging
5. Use production-grade databases
6. Configure proper CORS policies
7. Set up CI/CD pipelines

## License

[Your License Here]

## Support

For issues and questions, please refer to the documentation or contact the development team.

