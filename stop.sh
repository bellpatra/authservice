#!/bin/bash

echo "🛑 Stopping Auth Service Infrastructure..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running."
    exit 1
fi

echo "📦 Stopping Docker services..."
docker-compose down

echo "🧹 Cleaning up..."
docker system prune -f

echo "✅ All services stopped and cleaned up!"
echo ""
echo "💡 To start services again, run:"
echo "   ./start.sh"
