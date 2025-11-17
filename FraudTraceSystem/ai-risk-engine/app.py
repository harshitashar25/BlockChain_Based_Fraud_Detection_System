from flask import Flask, request, jsonify
from flask_cors import CORS
import numpy as np
from sklearn.ensemble import IsolationForest
import joblib
import os

app = Flask(__name__)
CORS(app)  # Enable CORS for cross-origin requests

# For demo we use a trivial model - in prod train on real features
model = IsolationForest(n_estimators=100, contamination=0.1, random_state=42)

# Fit on random data for demo purposes
# In production, load a pre-trained model: model = joblib.load('model.joblib')
X_dummy = np.random.rand(1000, 3) * 100000
model.fit(X_dummy)

@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "healthy"})

@app.route('/risk-score', methods=['POST'])
def risk_score():
    try:
        data = request.json
        
        # Extract features from transaction
        amount = float(data.get('amount', 0))
        # In production, extract more features like:
        # - Transaction velocity (frequency)
        # - Account age
        # - Geographic patterns
        # - Time patterns
        
        # Create feature vector
        # For demo: [amount, amount_normalized, log(amount+1)]
        amount_normalized = amount / 100000.0  # normalize by max expected
        log_amount = np.log1p(amount)
        
        features = np.array([[amount, amount_normalized, log_amount]])
        
        # Get anomaly score (lower is more anomalous)
        anomaly_score = model.score_samples(features)[0]
        
        # Convert to risk score (0-1 scale, higher = more risky)
        # IsolationForest returns negative scores for anomalies
        # We'll map it to 0-1 where 1 is highest risk
        risk_score = min(1.0, max(0.0, (1.0 - anomaly_score) / 2.0))
        
        # Simple heuristic: large amounts get higher risk
        if amount > 50000:
            risk_score = min(1.0, risk_score + 0.2)
        
        return jsonify({
            "riskScore": float(risk_score),
            "amount": amount,
            "anomalyScore": float(anomaly_score)
        })
    except Exception as e:
        return jsonify({
            "error": str(e),
            "riskScore": 0.5  # default on error
        }), 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5001))
    app.run(host='0.0.0.0', port=port, debug=True)

