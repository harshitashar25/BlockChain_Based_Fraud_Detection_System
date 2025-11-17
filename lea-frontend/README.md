# LEA Frontend

React dashboard for Law Enforcement Agency to monitor fraud alerts in real-time.

## Features

- Real-time fraud alerts via WebSocket
- Transaction trace visualization using D3.js
- Alert list with risk scoring
- Responsive design

## Setup

```bash
npm install
```

## Run

```bash
npm start
```

The app will open at http://localhost:3000

## Build

```bash
npm run build
```

## Environment Variables

Create a `.env` file if needed:

```
REACT_APP_WS_URL=ws://localhost:8082
REACT_APP_API_URL=http://localhost:8080
```

