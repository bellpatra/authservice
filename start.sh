#!/bin/bash

echo "🚀 Starting Auth Service Infrastructure..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Check if Docker Compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

echo "📦 Starting Docker services..."
docker-compose up -d

echo "⏳ Waiting for services to be ready..."
sleep 10

echo "🔍 Checking service status..."
echo "PostgreSQL: $(docker-compose ps postgres | grep -o 'Up')"
echo "Redis: $(docker-compose ps redis | grep -o 'Up')"
echo "Kafka: $(docker-compose ps kafka | grep -o 'Up')"
echo "Kafka UI: $(docker-compose ps kafka-ui | grep -o 'Up')"
echo "pgAdmin: $(docker-compose ps pgadmin | grep -o 'Up')"

echo ""
echo "✅ All services are starting up!"
echo ""
echo "🌐 Service URLs:"
echo "   Auth Service: http://localhost:8080"
echo "   pgAdmin: http://localhost:8082 (admin@authservice.com / admin123)"
echo "   Kafka UI: http://localhost:8081"
echo ""
echo "📊 Database Info:"
echo "   PostgreSQL: localhost:5432"
echo "   Database: authservice"
echo "   Username: postgres"
echo "   Password: postgres"
echo ""
echo "🔄 To start the Spring Boot application, run:"
echo "   mvn spring-boot:run"
echo ""
echo "🛑 To stop all services, run:"
echo "   docker-compose down"
