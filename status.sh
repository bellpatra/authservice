#!/bin/bash

echo "🔍 Auth Service Status Check"
echo "============================"
echo ""

# Check Spring Boot Application
echo "🌐 Spring Boot Application:"
if curl -s http://localhost:8080/api/health > /dev/null 2>&1; then
    echo "   ✅ Running on http://localhost:8080"
    echo "   📊 Health: $(curl -s http://localhost:8080/api/health | jq -r '.status')"
else
    echo "   ❌ Not running on port 8080"
fi

echo ""

# Check Infrastructure Services
echo "📦 Infrastructure Services:"
echo "   PostgreSQL: $(docker-compose -f docker-compose-no-postgres.yml ps postgres | grep -o 'Up' || echo '❌ Not running')"
echo "   Redis: $(docker-compose -f docker-compose-no-postgres.yml ps redis | grep -o 'Up' || echo '❌ Not running')"
echo "   Kafka: $(docker-compose -f docker-compose-no-postgres.yml ps kafka | grep -o 'Up' || echo '❌ Not running')"
echo "   Kafka UI: $(docker-compose -f docker-compose-no-postgres.yml ps kafka-ui | grep -o 'Up' || echo '❌ Not running')"
echo "   pgAdmin: $(docker-compose -f docker-compose-no-postgres.yml ps pgadmin | grep -o 'Up' || echo '❌ Not running')"

echo ""

# Check Ports
echo "🔌 Port Status:"
echo "   Port 8080 (Auth Service): $(lsof -i:8080 >/dev/null 2>&1 && echo '✅ In use' || echo '❌ Available')"
echo "   Port 8081 (Kafka UI): $(lsof -i:8081 >/dev/null 2>&1 && echo '✅ In use' || echo '❌ Available')"
echo "   Port 8082 (pgAdmin): $(lsof -i:8082 >/dev/null 2>&1 && echo '✅ In use' || echo '❌ Available')"
echo "   Port 5432 (PostgreSQL): $(lsof -i:5432 >/dev/null 2>&1 && echo '✅ In use' || echo '❌ Available')"
echo "   Port 6379 (Redis): $(lsof -i:6379 >/dev/null 2>&1 && echo '✅ In use' || echo '❌ Available')"
echo "   Port 9092 (Kafka): $(lsof -i:9092 >/dev/null 2>&1 && echo '✅ In use' || echo '❌ Available')"

echo ""
echo "🌐 Quick Access URLs:"
echo "   Main Dashboard: http://localhost:8080"
echo "   Health Check: http://localhost:8080/api/health"
echo "   Kafka UI: http://localhost:8081"
echo "   pgAdmin: http://localhost:8082"
echo "   Actuator: http://localhost:8080/actuator"
