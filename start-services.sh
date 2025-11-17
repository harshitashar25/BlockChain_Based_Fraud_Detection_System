#!/bin/bash

echo "=========================================="
echo "Starting Fraud Traceability System Services"
echo "=========================================="

# Kill any existing processes
pkill -f "python app.py" 2>/dev/null
pkill -f "node server.js" 2>/dev/null
pkill -f "react-scripts start" 2>/dev/null

# Start AI Risk Engine
echo "Starting AI Risk Engine..."
cd ai-risk-engine
source venv/bin/activate
python app.py > ../logs/ai-engine.log 2>&1 &
AI_PID=$!
echo "✅ AI Risk Engine started (PID: $AI_PID)"
cd ..

sleep 2

# Start LEA Backend
echo "Starting LEA Backend..."
cd lea-backend
npm start > ../logs/lea-backend.log 2>&1 &
LEA_PID=$!
echo "✅ LEA Backend started (PID: $LEA_PID)"
cd ..

sleep 2

# Start LEA Frontend
echo "Starting LEA Frontend..."
cd lea-frontend
npm start > ../logs/lea-frontend.log 2>&1 &
FRONTEND_PID=$!
echo "✅ LEA Frontend started (PID: $FRONTEND_PID)"
cd ..

echo ""
echo "=========================================="
echo "Services Started!"
echo "=========================================="
echo "AI Risk Engine:    http://localhost:5001"
echo "LEA Backend HTTP:  http://localhost:8080"
echo "LEA Backend WS:    ws://localhost:8082"
echo "LEA Frontend:      http://localhost:3000"
echo ""
echo "PIDs saved to: logs/service-pids.txt"
echo "$AI_PID" > logs/service-pids.txt
echo "$LEA_PID" >> logs/service-pids.txt
echo "$FRONTEND_PID" >> logs/service-pids.txt
echo ""
echo "To stop all services: ./stop-services.sh"
echo "To test: ./test-services.sh"
