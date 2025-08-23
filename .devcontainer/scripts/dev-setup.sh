#!/bin/bash

echo "🚀 Setting up Spring Boot Auth Service Development Environment..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop."
    exit 1
fi

# Check if services are already running
if docker-compose -f docker-compose.yml -p authservice ps | grep -q "Up"; then
    echo "✅ Services are already running"
else
    echo "🐳 Starting Docker services..."
    docker-compose -f docker-compose.yml -p authservice up -d
    
    echo "⏳ Waiting for services to start..."
    sleep 15
    
    echo "🔍 Checking service status..."
    docker-compose -f docker-compose.yml -p authservice ps
fi

# Compile the project
echo "🔨 Compiling project..."
mvn clean compile

echo "✅ Development environment is ready!"
echo ""
echo "🌐 Access URLs:"
echo "   Spring Boot App: http://localhost:8080"
echo "   Kafka UI:        http://localhost:8081"
echo "   pgAdmin:         http://localhost:8082"
echo ""
echo "📝 Next steps:"
echo "   1. Run the Spring Boot application: mvn spring-boot:run"
echo "   2. Or use IntelliJ IDEA Run Configuration"
echo "   3. Check health endpoint: http://localhost:8080/api/health"
