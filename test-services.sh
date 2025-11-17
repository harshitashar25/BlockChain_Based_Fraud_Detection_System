#!/bin/bash

echo "=========================================="
echo "Testing Fraud Traceability System Services"
echo "=========================================="

echo -e "\n1. Testing AI Risk Engine..."
if curl -s http://localhost:5001/health > /dev/null 2>&1; then
    echo "✅ AI Risk Engine is running"
    curl -s -X POST http://localhost:5001/risk-score \
      -H "Content-Type: application/json" \
      -d '{"txId":"TEST","amount":100000,"fromAccount":"A","toAccount":"B","timestamp":"2025-11-17T04:00:00Z"}' \
      | python3 -m json.tool 2>/dev/null || echo "Response received"
else
    echo "❌ AI Risk Engine is not running (start it first)"
fi

echo -e "\n2. Testing LEA Backend..."
if curl -s http://localhost:8080/health > /dev/null 2>&1; then
    echo "✅ LEA Backend is running"
    curl -s http://localhost:8080/health | python3 -m json.tool 2>/dev/null || echo "Response received"
else
    echo "❌ LEA Backend is not running (start it first)"
fi

echo -e "\n3. Testing LEA Frontend..."
if curl -s http://localhost:3000 > /dev/null 2>&1; then
    echo "✅ LEA Frontend is running"
    echo "   Open http://localhost:3000 in your browser"
else
    echo "❌ LEA Frontend is not running (start it first)"
fi

echo -e "\n=========================================="
echo "Test complete!"
echo "=========================================="
