#!/bin/bash

echo "Stopping all services..."

pkill -f "python app.py" && echo "✅ Stopped AI Risk Engine"
pkill -f "node server.js" && echo "✅ Stopped LEA Backend"
pkill -f "react-scripts start" && echo "✅ Stopped LEA Frontend"

echo "All services stopped."
