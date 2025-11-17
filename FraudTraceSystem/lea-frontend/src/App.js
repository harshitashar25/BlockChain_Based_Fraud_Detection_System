import React, { useState, useEffect } from 'react';
import './App.css';
import AlertList from './components/AlertList';
import TraceVisualization from './components/TraceVisualization';
import Header from './components/Header';
import WebSocketService from './services/WebSocketService';

function App() {
  const [alerts, setAlerts] = useState([]);
  const [selectedAlert, setSelectedAlert] = useState(null);
  const [connectionStatus, setConnectionStatus] = useState('disconnected');

  useEffect(() => {
    const ws = new WebSocketService('ws://localhost:8082');
    
    ws.onConnect = () => {
      setConnectionStatus('connected');
      console.log('WebSocket connected');
    };
    
    ws.onDisconnect = () => {
      setConnectionStatus('disconnected');
      console.log('WebSocket disconnected');
    };
    
    ws.onError = (error) => {
      setConnectionStatus('error');
      console.error('WebSocket error:', error);
    };
    
    ws.onMessage = (message) => {
      if (message.type === 'alert') {
        const newAlert = {
          ...message.data,
          id: message.data.txId || Date.now().toString(),
          receivedAt: message.timestamp
        };
        setAlerts(prev => [newAlert, ...prev]);
      }
    };
    
    ws.connect();
    
    return () => {
      ws.disconnect();
    };
  }, []);

  return (
    <div className="App">
      <Header connectionStatus={connectionStatus} alertCount={alerts.length} />
      <div className="main-content">
        <div className="left-panel">
          <AlertList 
            alerts={alerts} 
            selectedAlert={selectedAlert}
            onSelectAlert={setSelectedAlert}
          />
        </div>
        <div className="right-panel">
          <TraceVisualization alert={selectedAlert} />
        </div>
      </div>
    </div>
  );
}

export default App;

