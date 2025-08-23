#!/bin/bash

echo "🔍 Health Check for Auth Service Infrastructure"
echo "=============================================="

# Check Docker services
echo ""
echo "📦 Docker Services Status:"
docker-compose ps

echo ""
echo "🌐 Service Connectivity:"

# Check PostgreSQL
if nc -z localhost 5432 2>/dev/null; then
    echo "✅ PostgreSQL (5432) - Running"
else
    echo "❌ PostgreSQL (5432) - Not accessible"
fi

# Check Redis
if nc -z localhost 6379 2>/dev/null; then
    echo "✅ Redis (6379) - Running"
else
    echo "❌ Redis (6379) - Not accessible"
fi

# Check Kafka
if nc -z localhost 9092 2>/dev/null; then
    echo "✅ Kafka (9092) - Running"
else
    echo "❌ Kafka (9092) - Not accessible"
fi

# Check Kafka UI
if nc -z localhost 8081 2>/dev/null; then
    echo "✅ Kafka UI (8081) - Running"
else
    echo "❌ Kafka UI (8081) - Not accessible"
fi

# Check pgAdmin
if nc -z localhost 8082 2>/dev/null; then
    echo "✅ pgAdmin (8082) - Running"
else
    echo "❌ pgAdmin (8082) - Not accessible"
fi

# Check Auth Service (if running)
if nc -z localhost 8080 2>/dev/null; then
    echo "✅ Auth Service (8080) - Running"
else
    echo "❌ Auth Service (8080) - Not accessible"
fi

echo ""
echo "📊 Quick Access URLs:"
echo "   Main Dashboard: http://localhost:8080"
echo "   pgAdmin: http://localhost:8082"
echo "   Kafka UI: http://localhost:8081"
echo "   Health Check: http://localhost:8080/api/health"
