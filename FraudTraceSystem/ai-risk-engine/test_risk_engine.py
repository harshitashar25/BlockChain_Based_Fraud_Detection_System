#!/usr/bin/env python3
"""
Unit tests for AI Risk Engine
"""

import unittest
import json
from app import app

class TestRiskEngine(unittest.TestCase):
    
    def setUp(self):
        self.app = app.test_client()
        self.app.testing = True
    
    def test_health_endpoint(self):
        """Test health check endpoint"""
        response = self.app.get('/health')
        self.assertEqual(response.status_code, 200)
        data = json.loads(response.data)
        self.assertEqual(data['status'], 'healthy')
    
    def test_risk_score_low_amount(self):
        """Test risk score for low amount transaction"""
        payload = {
            "txId": "TEST001",
            "amount": 1000,
            "fromAccount": "ACC001",
            "toAccount": "ACC002",
            "timestamp": "2025-11-17T04:00:00Z"
        }
        response = self.app.post('/risk-score', 
                                data=json.dumps(payload),
                                content_type='application/json')
        self.assertEqual(response.status_code, 200)
        data = json.loads(response.data)
        self.assertIn('riskScore', data)
        self.assertGreaterEqual(data['riskScore'], 0.0)
        self.assertLessEqual(data['riskScore'], 1.0)
    
    def test_risk_score_high_amount(self):
        """Test risk score for high amount transaction"""
        payload = {
            "txId": "TEST002",
            "amount": 200000,
            "fromAccount": "ACC001",
            "toAccount": "ACC002",
            "timestamp": "2025-11-17T04:00:00Z"
        }
        response = self.app.post('/risk-score',
                                data=json.dumps(payload),
                                content_type='application/json')
        self.assertEqual(response.status_code, 200)
        data = json.loads(response.data)
        self.assertIn('riskScore', data)
        # High amount should have higher risk
        self.assertGreater(data['riskScore'], 0.5)
    
    def test_risk_score_missing_fields(self):
        """Test risk score with missing fields"""
        payload = {
            "amount": 5000
        }
        response = self.app.post('/risk-score',
                                data=json.dumps(payload),
                                content_type='application/json')
        # Should handle gracefully
        self.assertEqual(response.status_code, 200)
        data = json.loads(response.data)
        self.assertIn('riskScore', data)

if __name__ == '__main__':
    unittest.main()

