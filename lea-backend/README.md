# LEA Backend

Node.js backend service for Law Enforcement Agency dashboard.

## Features

- WebSocket server for real-time fraud alerts
- HTTP API for receiving alerts from bank-api
- RPC proxy for querying Corda (to be implemented)

## Setup

```bash
npm install
```

## Run

```bash
npm start
```

Or for development with auto-reload:

```bash
npm run dev
```

## API Endpoints

### POST /notify
Receive fraud alerts from bank-api and broadcast to WebSocket clients.

### GET /alerts
Get all alerts (queries Corda RPC or database).

### GET /health
Health check endpoint.

## WebSocket

Connect to `ws://localhost:8082` to receive real-time alerts.

Message format:
```json
{
  "type": "alert",
  "data": {
    "txId": "TXN101",
    "amount": 50000,
    "riskScore": 0.85,
    "timestamp": "2025-11-17T04:00:00Z"
  },
  "timestamp": "2025-11-17T04:00:00Z"
}
```

