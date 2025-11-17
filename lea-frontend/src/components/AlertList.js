import React from 'react';
import './AlertList.css';

function AlertList({ alerts, selectedAlert, onSelectAlert }) {
  const formatAmount = (amount) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0
    }).format(amount);
  };

  const getRiskColor = (riskScore) => {
    if (riskScore >= 0.8) return '#f44336';
    if (riskScore >= 0.6) return '#ff9800';
    return '#4caf50';
  };

  return (
    <div className="alert-list">
      <h2>Fraud Alerts</h2>
      <div className="alert-list-content">
        {alerts.length === 0 ? (
          <div className="empty-state">
            <p>No alerts received yet.</p>
            <p className="empty-hint">Waiting for fraud alerts...</p>
          </div>
        ) : (
          alerts.map(alert => (
            <div
              key={alert.id}
              className={`alert-item ${selectedAlert?.id === alert.id ? 'selected' : ''}`}
              onClick={() => onSelectAlert(alert)}
            >
              <div className="alert-header">
                <span className="alert-tx-id">{alert.txId}</span>
                <span 
                  className="risk-badge"
                  style={{ backgroundColor: getRiskColor(alert.riskScore) }}
                >
                  {(alert.riskScore * 100).toFixed(0)}%
                </span>
              </div>
              <div className="alert-details">
                <div className="alert-amount">
                  {formatAmount(alert.amount)}
                </div>
                <div className="alert-time">
                  {new Date(alert.timestamp || alert.receivedAt).toLocaleString()}
                </div>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}

export default AlertList;

