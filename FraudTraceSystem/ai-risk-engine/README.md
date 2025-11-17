# AI Risk Engine

Python Flask service for fraud risk scoring.

## Setup

```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

## Run

```bash
python app.py
```

The service will run on port 5001 by default.

## API

### POST /risk-score

Request body:
```json
{
  "txId": "TXN101",
  "amount": 50000,
  "fromAccount": "X",
  "toAccount": "Y",
  "timestamp": "2025-11-17T04:00:00Z"
}
```

Response:
```json
{
  "riskScore": 0.85,
  "amount": 50000,
  "anomalyScore": -0.3
}
```

