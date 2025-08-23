#!/bin/bash

echo "🚀 Starting Auth Service (Local Development Mode)..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Check if PostgreSQL is running locally
if ! pg_isready -U postgres -h localhost > /dev/null 2>&1; then
    echo "❌ Local PostgreSQL is not running. Please start PostgreSQL first."
    echo "   You can start it with: brew services start postgresql"
    exit 1
fi

# Check if database exists
if ! psql -U postgres -h localhost -lqt | cut -d \| -f 1 | grep -qw authservice; then
    echo "📦 Creating database 'authservice'..."
    psql -U postgres -h localhost -c "CREATE DATABASE authservice;"
    echo "✅ Database created successfully!"
else
    echo "✅ Database 'authservice' already exists!"
fi

echo "📦 Starting infrastructure services (Redis, Kafka, pgAdmin)..."
docker-compose -f docker-compose-no-postgres.yml up -d

echo "⏳ Waiting for services to be ready..."
sleep 10

echo "🔍 Checking service status..."
echo "PostgreSQL (Local): ✅ Running on port 5432"
echo "Redis: $(docker-compose -f docker-compose-no-postgres.yml ps redis | grep -o 'Up')"
echo "Kafka: $(docker-compose -f docker-compose-no-postgres.yml ps kafka | grep -o 'Up')"
echo "Kafka UI: $(docker-compose -f docker-compose-no-postgres.yml ps kafka-ui | grep -o 'Up')"
echo "pgAdmin: $(docker-compose -f docker-compose-no-postgres.yml ps pgadmin | grep -o 'Up')"

echo ""
echo "✅ All services are ready!"
echo ""
echo "🌐 Service URLs:"
echo "   Main Dashboard: http://localhost:8080"
echo "   pgAdmin: http://localhost:8082 (admin@authservice.com / admin123)"
echo "   Kafka UI: http://localhost:8081"
echo "   Health Check: http://localhost:8080/api/health"
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
echo "🛑 To stop infrastructure services, run:"
echo "   docker-compose -f docker-compose-no-postgres.yml down"
