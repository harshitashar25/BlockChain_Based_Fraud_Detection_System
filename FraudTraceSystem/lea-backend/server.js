const express = require('express');
const WebSocket = require('ws');
const axios = require('axios');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

const WS_PORT = 8082;
const HTTP_PORT = 8080;

// WebSocket server for real-time alerts
const wss = new WebSocket.Server({ port: WS_PORT });

let sockets = [];

wss.on('connection', (ws) => {
  console.log('New WebSocket client connected');
  sockets.push(ws);
  
  ws.on('close', () => {
    console.log('WebSocket client disconnected');
    sockets = sockets.filter(s => s !== ws);
  });
  
  ws.on('error', (error) => {
    console.error('WebSocket error:', error);
  });
  
  // Send welcome message
  ws.send(JSON.stringify({
    type: 'connected',
    message: 'Connected to LEA Alert System'
  }));
});

// Broadcast alert to all connected clients
function broadcastAlert(alert) {
  const message = JSON.stringify({
    type: 'alert',
    data: alert,
    timestamp: new Date().toISOString()
  });
  
  sockets.forEach(socket => {
    if (socket.readyState === WebSocket.OPEN) {
      socket.send(message);
    }
  });
  
  console.log(`Broadcasted alert to ${sockets.length} clients`);
}

// HTTP endpoint to receive alerts from bank-api
app.post('/notify', (req, res) => {
  const alert = req.body;
  console.log('Received alert:', alert);
  
  // Broadcast to all WebSocket clients
  broadcastAlert(alert);
  
  res.json({ 
    ok: true, 
    message: 'Alert broadcasted',
    clients: sockets.length 
  });
});

// Get all alerts (in production, this would query Corda RPC or database)
app.get('/alerts', async (req, res) => {
  try {
    // In production, query Corda RPC or database
    // For now, return empty array or mock data
    res.json({
      alerts: [],
      message: 'Query Corda RPC or database for alerts'
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy',
    websocketClients: sockets.length,
    timestamp: new Date().toISOString()
  });
});

// Start HTTP server
app.listen(HTTP_PORT, () => {
  console.log(`LEA backend HTTP server listening on port ${HTTP_PORT}`);
  console.log(`WebSocket server listening on port ${WS_PORT}`);
});

// Handle graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, closing servers...');
  wss.close(() => {
    console.log('WebSocket server closed');
    process.exit(0);
  });
});

