import React from 'react';
import './Header.css';

function Header({ connectionStatus, alertCount }) {
  const getStatusColor = () => {
    switch (connectionStatus) {
      case 'connected':
        return '#4caf50';
      case 'disconnected':
        return '#f44336';
      case 'error':
        return '#ff9800';
      default:
        return '#9e9e9e';
    }
  };

  return (
    <header className="header">
      <div className="header-content">
        <h1>LEA Fraud Alert Dashboard</h1>
        <div className="header-stats">
          <div className="stat-item">
            <span className="stat-label">Connection:</span>
            <span 
              className="stat-value status-indicator"
              style={{ color: getStatusColor() }}
            >
              {connectionStatus.toUpperCase()}
            </span>
          </div>
          <div className="stat-item">
            <span className="stat-label">Active Alerts:</span>
            <span className="stat-value">{alertCount}</span>
          </div>
        </div>
      </div>
    </header>
  );
}

export default Header;

