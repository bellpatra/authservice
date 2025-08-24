#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Box drawing characters
TOP_LEFT="╭"
TOP_RIGHT="╮"
BOTTOM_LEFT="╰"
BOTTOM_RIGHT="╯"
HORIZONTAL="─"
VERTICAL="│"
LEFT_T="├"
RIGHT_T="┤"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root. Please run as a regular user with sudo privileges."
        exit 1
    fi
}

# Function to check if running on Ubuntu 24.04
check_ubuntu_version() {
    if [[ ! -f /etc/os-release ]]; then
        print_error "This script is designed for Ubuntu 24.04. Please run on a supported system."
        exit 1
    fi
    
    source /etc/os-release
    if [[ "$ID" != "ubuntu" || "$VERSION_ID" != "24.04" ]]; then
        print_warning "This script is designed for Ubuntu 24.04. You are running $ID $VERSION_ID"
        read -p "Do you want to continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Function to update system packages
update_system() {
    print_status "Updating system packages..."
    sudo apt update && sudo apt upgrade -y
    print_success "System packages updated successfully"
}

# Function to install essential packages
install_essential_packages() {
    print_status "Installing essential packages..."
    sudo apt install -y curl wget git unzip software-properties-common apt-transport-https ca-certificates gnupg lsb-release
    print_success "Essential packages installed successfully"
}

# Function to install OpenJDK 17
install_java() {
    print_status "Installing OpenJDK 17..."
    sudo apt install -y openjdk-17-jdk openjdk-17-jre
    
    # Set JAVA_HOME
    echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> ~/.bashrc
    echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.bashrc
    source ~/.bashrc
    
    # Verify installation
    java_version=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2)
    print_success "Java $java_version installed successfully"
}

# Function to install Maven
install_maven() {
    print_status "Installing Maven..."
    sudo apt install -y maven
    
    # Verify installation
    maven_version=$(mvn -version 2>&1 | head -n 1 | cut -d' ' -f3)
    print_success "Maven $maven_version installed successfully"
}

# Function to install Nginx
install_nginx() {
    print_status "Installing Nginx..."
    sudo apt install -y nginx
    
    # Start and enable Nginx
    sudo systemctl start nginx
    sudo systemctl enable nginx
    
    # Configure firewall
    sudo ufw allow 'Nginx Full'
    
    print_success "Nginx installed and configured successfully"
}

# Function to install PostgreSQL (optional)
install_postgresql() {
    read -p "Do you want to install PostgreSQL locally (outside Docker)? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Installing PostgreSQL..."
        sudo apt install -y postgresql postgresql-contrib
        
        # Start and enable PostgreSQL
        sudo systemctl start postgresql
        sudo systemctl enable postgresql
        
        print_success "PostgreSQL installed successfully"
        print_warning "Remember to configure PostgreSQL user and database for your application"
    fi
}

# Function to install Docker
install_docker() {
    print_status "Installing Docker..."
    
    # Remove old versions if they exist
    sudo apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
    
    # Install prerequisites
    sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
    
    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Add Docker repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Update package index and install Docker
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # Add current user to docker group
    sudo usermod -aG docker $USER
    
    # Start and enable Docker
    sudo systemctl start docker
    sudo systemctl enable docker
    
    # Install Docker Compose standalone (backup)
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    
    # Verify installation
    docker_version=$(docker --version | cut -d' ' -f3 | sed 's/,//')
    compose_version=$(docker compose version | grep "Docker Compose version" | cut -d' ' -f4)
    
    print_success "Docker $docker_version and Docker Compose $compose_version installed successfully"
    print_warning "You may need to log out and back in for docker group permissions to take effect"
}

# Function to install Redis (optional)
install_redis() {
    read -p "Do you want to install Redis locally (outside Docker)? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Installing Redis..."
        sudo apt install -y redis-server
        
        # Start and enable Redis
        sudo systemctl start redis-server
        sudo systemctl enable redis-server
        
        print_success "Redis installed successfully"
    fi
}

# Function to create application directory
create_app_directory() {
    print_status "Creating application directory..."
    sudo mkdir -p /var/www/authservice
    sudo chown $USER:$USER /var/www/authservice
    print_success "Application directory created at /var/www/authservice"
}

# Function to configure Nginx virtual host
configure_nginx_vhost() {
    print_status "Configuring Nginx virtual host..."
    
    # Get domain name from user
    read -p "Enter your domain name (e.g., example.com): " domain_name
    
    if [[ -z "$domain_name" ]]; then
        print_warning "No domain name provided. Using localhost for configuration."
        domain_name="localhost"
    fi
    
    # Create Nginx configuration file
    sudo tee /etc/nginx/sites-available/authservice << EOF
server {
    listen 80;
    server_name $domain_name www.$domain_name;
    
    # Redirect HTTP to HTTPS (uncomment when SSL is configured)
    # return 301 https://\$server_name\$request_uri;
    
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
    
    # Static files (if any)
    location /static/ {
        alias /var/www/authservice/static/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Health check endpoint
    location /actuator/health {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF
    
    # Enable the site
    sudo ln -sf /etc/nginx/sites-available/authservice /etc/nginx/sites-enabled/
    
    # Remove default site
    sudo rm -f /etc/nginx/sites-enabled/default
    
    # Test Nginx configuration
    if sudo nginx -t; then
        sudo systemctl reload nginx
        print_success "Nginx virtual host configured successfully for $domain_name"
    else
        print_error "Nginx configuration test failed"
        exit 1
    fi
}

# Function to create systemd service
create_systemd_service() {
    print_status "Creating systemd service for the application..."
    
    sudo tee /etc/systemd/system/authservice.service << EOF
[Unit]
Description=Auth Service Spring Boot Application
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=/var/www/authservice
ExecStart=/usr/bin/java -jar -Dspring.profiles.active=prod authservice.jar
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
    
    # Reload systemd and enable service
    sudo systemctl daemon-reload
    sudo systemctl enable authservice.service
    
    print_success "Systemd service created and enabled"
}

# Function to create deployment script
create_deployment_script() {
    print_status "Creating deployment helper script..."
    
    cat > deploy-app.sh << 'EOF'
#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}[INFO]${NC} Starting application deployment..."

# Stop the service if running
sudo systemctl stop authservice.service

# Build the application
echo -e "${BLUE}[INFO]${NC} Building application with Maven..."
mvn clean package -DskipTests

# Copy the JAR file
echo -e "${BLUE}[INFO]${NC} Copying JAR file to application directory..."
cp target/*.jar /var/www/authservice/authservice.jar

# Set proper permissions
sudo chown $USER:$USER /var/www/authservice/authservice.jar
chmod +x /var/www/authservice/authservice.jar

# Start the service
echo -e "${BLUE}[INFO]${NC} Starting application service..."
sudo systemctl start authservice.service

# Check status
if sudo systemctl is-active --quiet authservice.service; then
    echo -e "${GREEN}[SUCCESS]${NC} Application deployed and running successfully!"
    echo -e "${BLUE}[INFO]${NC} Service status:"
    sudo systemctl status authservice.service --no-pager -l
else
    echo -e "${RED}[ERROR]${NC} Failed to start the application service"
    sudo systemctl status authservice.service --no-pager -l
    exit 1
fi
EOF
    
    chmod +x deploy-app.sh
    print_success "Deployment helper script created: deploy-app.sh"
}

# Function to create environment configuration
create_env_config() {
    print_status "Creating environment configuration..."
    
    cat > /var/www/authservice/application-prod.properties << 'EOF'
# Production Configuration
server.port=8080
server.address=0.0.0.0

# Database Configuration (update with your actual values)
spring.datasource.url=jdbc:postgresql://localhost:5432/authservice
spring.datasource.username=your_username
spring.datasource.password=your_password
spring.datasource.driver-class-name=org.postgresql.Driver

# JPA Configuration
spring.jpa.hibernate.ddl-auto=validate
spring.jpa.show-sql=false
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect

# JWT Configuration
jwt.secret=your_jwt_secret_key_here_change_in_production
jwt.expiration=86400000

# Email Configuration (update with your actual values)
spring.mail.host=smtp.gmail.com
spring.mail.port=587
spring.mail.username=your_email@gmail.com
spring.mail.password=your_app_password
spring.mail.properties.mail.smtp.auth=true
spring.mail.properties.mail.smtp.starttls.enable=true

# Logging
logging.level.root=INFO
logging.level.com.josam.authservice=DEBUG
logging.file.name=/var/log/authservice/application.log
logging.pattern.file=%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n

# Actuator
management.endpoints.web.exposure.include=health,info,metrics
management.endpoint.health.show-details=when-authorized
EOF
    
    # Create log directory
    sudo mkdir -p /var/log/authservice
    sudo chown $USER:$USER /var/log/authservice
    
    print_success "Environment configuration created"
}

# Function to create SSL configuration (Let's Encrypt)
setup_ssl() {
    read -p "Do you want to set up SSL with Let's Encrypt? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Setting up SSL with Let's Encrypt..."
        
        # Install Certbot
        sudo apt install -y certbot python3-certbot-nginx
        
        # Get domain name from Nginx config
        domain_name=$(grep "server_name" /etc/nginx/sites-available/authservice | awk '{print $2}' | sed 's/;//')
        
        if [[ "$domain_name" != "localhost" ]]; then
            print_status "Obtaining SSL certificate for $domain_name..."
            sudo certbot --nginx -d $domain_name -d www.$domain_name --non-interactive --agree-tos --email admin@$domain_name
            
            print_success "SSL certificate obtained and configured successfully"
        else
            print_warning "Cannot set up SSL for localhost. Please configure a real domain first."
        fi
    fi
}

# Function to setup Docker Compose
setup_docker_compose() {
    print_status "Setting up Docker Compose environment..."
    
    # Copy Docker Compose files to application directory
    if [[ -f "docker-compose.yml" ]]; then
        cp docker-compose.yml /var/www/authservice/
        print_success "Copied docker-compose.yml to application directory"
    fi
    
    if [[ -f "docker-compose-no-postgres.yml" ]]; then
        cp docker-compose-no-postgres.yml /var/www/authservice/
        print_success "Copied docker-compose-no-postgres.yml to application directory"
    fi
    
    # Create production Docker Compose file
    cat > /var/www/authservice/docker-compose-prod.yml << 'EOF'
version: '3.8'

services:
  # PostgreSQL Database
  postgres:
    image: postgres:15-alpine
    container_name: authservice-postgres-prod
    environment:
      POSTGRES_DB: authservice
      POSTGRES_USER: ${POSTGRES_USER:-postgres}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-postgres}
    ports:
      - "127.0.0.1:5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init-scripts:/docker-entrypoint-initdb.d
    networks:
      - authservice-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-postgres} -d authservice"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Redis Cache
  redis:
    image: redis:7-alpine
    container_name: authservice-redis-prod
    ports:
      - "127.0.0.1:6379:6379"
    volumes:
      - redis_data:/data
    networks:
      - authservice-network
    restart: unless-stopped
    command: redis-server --appendonly yes --requirepass ${REDIS_PASSWORD:-}
    healthcheck:
      test: ["CMD", "redis-cli", "--raw", "incr", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Kafka
  zookeeper:
    image: confluentinc/cp-zookeeper:7.4.0
    container_name: authservice-zookeeper-prod
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_TICK_TIME: 2000
    networks:
      - authservice-network
    restart: unless-stopped

  kafka:
    image: confluentinc/cp-kafka:7.4.0
    container_name: authservice-kafka-prod
    depends_on:
      - zookeeper
    ports:
      - "127.0.0.1:9092:9092"
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://localhost:9092,PLAINTEXT_INTERNAL://kafka:29092
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_INTERNAL:PLAINTEXT
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
      KAFKA_TRANSACTION_STATE_LOG_MIN_ISR: 1
      KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR: 1
      KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS: 0
    volumes:
      - kafka_data:/var/lib/kafka/data
    networks:
      - authservice-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "kafka-topics --bootstrap-server localhost:9092 --list"]
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  postgres_data:
  redis_data:
  kafka_data:

networks:
  authservice-network:
    driver: bridge
EOF
    
    # Create environment file for Docker Compose
    cat > /var/www/authservice/.env << 'EOF'
# Docker Compose Environment Variables
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_secure_password_here
REDIS_PASSWORD=your_redis_password_here

# Application Environment
SPRING_PROFILES_ACTIVE=prod
EOF
    
    # Create Docker management scripts
    cat > /var/www/authservice/docker-manage.sh << 'EOF'
#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}Auth Service Docker Management Script${NC}"
echo "======================================"

case "$1" in
    start)
        echo -e "${BLUE}Starting all services...${NC}"
        docker compose -f docker-compose-prod.yml up -d
        echo -e "${GREEN}Services started successfully!${NC}"
        ;;
    stop)
        echo -e "${BLUE}Stopping all services...${NC}"
        docker compose -f docker-compose-prod.yml down
        echo -e "${GREEN}Services stopped successfully!${NC}"
        ;;
    restart)
        echo -e "${BLUE}Restarting all services...${NC}"
        docker compose -f docker-compose-prod.yml restart
        echo -e "${GREEN}Services restarted successfully!${NC}"
        ;;
    status)
        echo -e "${BLUE}Service status:${NC}"
        docker compose -f docker-compose-prod.yml ps
        ;;
    logs)
        echo -e "${BLUE}Showing logs for all services:${NC}"
        docker compose -f docker-compose-prod.yml logs -f
        ;;
    logs-service)
        if [[ -z "$2" ]]; then
            echo -e "${RED}Please specify a service name${NC}"
            echo "Usage: $0 logs-service <service-name>"
            exit 1
        fi
        echo -e "${BLUE}Showing logs for $2:${NC}"
        docker compose -f docker-compose-prod.yml logs -f "$2"
        ;;
    backup)
        echo -e "${BLUE}Creating backup...${NC}"
        ./backup-app.sh
        ;;
    update)
        echo -e "${BLUE}Updating Docker images...${NC}"
        docker compose -f docker-compose-prod.yml pull
        docker compose -f docker-compose-prod.yml up -d
        echo -e "${GREEN}Services updated successfully!${NC}"
        ;;
    clean)
        echo -e "${YELLOW}Cleaning up unused Docker resources...${NC}"
        docker system prune -f
        docker volume prune -f
        echo -e "${GREEN}Cleanup completed!${NC}"
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|logs|logs-service <service>|backup|update|clean}"
        echo
        echo "Commands:"
        echo "  start         - Start all services"
        echo "  stop          - Stop all services"
        echo "  restart       - Restart all services"
        echo "  status        - Show service status"
        echo "  logs          - Show logs for all services"
        echo "  logs-service  - Show logs for specific service"
        echo "  backup        - Create backup"
        echo "  update        - Update and restart services"
        echo "  clean         - Clean up unused Docker resources"
        exit 1
        ;;
esac
EOF
    
    chmod +x /var/www/authservice/docker-manage.sh
    
    # Create Docker health check script
    cat > /var/www/authservice/docker-health-check.sh << 'EOF'
#!/bin/bash

# Health check script for Docker services
echo "Checking Docker services health..."

# Check if services are running
if docker compose -f docker-compose-prod.yml ps | grep -q "Up"; then
    echo "✅ All services are running"
    
    # Check PostgreSQL
    if docker exec authservice-postgres-prod pg_isready -U postgres > /dev/null 2>&1; then
        echo "✅ PostgreSQL is healthy"
    else
        echo "❌ PostgreSQL health check failed"
    fi
    
    # Check Redis
    if docker exec authservice-redis-prod redis-cli ping > /dev/null 2>&1; then
        echo "✅ Redis is healthy"
    else
        echo "❌ Redis health check failed"
    fi
    
    # Check Kafka
    if docker exec authservice-kafka-prod kafka-topics --bootstrap-server localhost:9092 --list > /dev/null 2>&1; then
        echo "✅ Kafka is healthy"
    else
        echo "❌ Kafka health check failed"
    fi
else
    echo "❌ Some services are not running"
    docker compose -f docker-compose-prod.yml ps
fi
EOF
    
    chmod +x /var/www/authservice/docker-health-check.sh
    
    print_success "Docker Compose environment configured successfully"
}

# Function to create monitoring and maintenance scripts
create_maintenance_scripts() {
    print_status "Creating monitoring and maintenance scripts..."
    
    # Log rotation script
    sudo tee /etc/logrotate.d/authservice << 'EOF'
/var/log/authservice/*.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 644 $USER $USER
    postrotate
        systemctl reload authservice.service > /dev/null 2>&1 || true
    endscript
}
EOF
    
    # Enhanced backup script with Docker support
    cat > backup-app.sh << 'EOF'
#!/bin/bash

# Enhanced backup script for Auth Service with Docker support
BACKUP_DIR="/var/backups/authservice"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

echo "Starting backup process..."

# Backup application
echo "Backing up application files..."
tar -czf $BACKUP_DIR/authservice_$DATE.tar.gz -C /var/www authservice/

# Backup logs
echo "Backing up application logs..."
tar -czf $BACKUP_DIR/logs_$DATE.tar.gz -C /var/log authservice/

# Backup Docker volumes
echo "Backing up Docker volumes..."
if command -v docker &> /dev/null; then
    # Backup PostgreSQL data
    docker run --rm -v authservice_postgres_data:/data -v $(pwd):/backup alpine tar czf /backup/postgres_data_$DATE.tar.gz -C /data .
    mv postgres_data_$DATE.tar.gz $BACKUP_DIR/
    
    # Backup Redis data
    docker run --rm -v authservice_redis_data:/data -v $(pwd):/backup alpine tar czf /backup/redis_data_$DATE.tar.gz -C /data .
    mv redis_data_$DATE.tar.gz $BACKUP_DIR/
    
    # Backup Kafka data
    docker run --rm -v authservice_kafka_data:/data -v $(pwd):/backup alpine tar czf /backup/kafka_data_$DATE.tar.gz -C /data .
    mv kafka_data_$DATE.tar.gz $BACKUP_DIR/
fi

# Backup database (if PostgreSQL is installed locally)
if command -v pg_dump &> /dev/null; then
    echo "Backing up local PostgreSQL database..."
    pg_dump -U postgres authservice > $BACKUP_DIR/database_local_$DATE.sql 2>/dev/null || echo "Local PostgreSQL backup failed"
fi

# Create backup manifest
cat > $BACKUP_DIR/backup_manifest_$DATE.txt << MANIFEST
Backup created: $(date)
Backup directory: $BACKUP_DIR
Files included:
- Application: authservice_$DATE.tar.gz
- Logs: logs_$DATE.tar.gz
- PostgreSQL data: postgres_data_$DATE.tar.gz
- Redis data: redis_data_$DATE.tar.gz
- Kafka data: kafka_data_$DATE.tar.gz
- Local database: database_local_$DATE.sql

Total size: $(du -sh $BACKUP_DIR | cut -f1)
MANIFEST

# Keep only last 7 backups
echo "Cleaning up old backups..."
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
find $BACKUP_DIR -name "backup_manifest_*.txt" -mtime +7 -delete

echo "✅ Backup completed successfully: $BACKUP_DIR"
echo "📁 Backup manifest: $BACKUP_DIR/backup_manifest_$DATE.txt"
EOF
    
    chmod +x backup-app.sh
    
    # Create monitoring script
    cat > monitor-app.sh << 'EOF'
#!/bin/bash

# Monitoring script for Auth Service
echo "🔍 Auth Service Monitoring Report"
echo "=================================="
echo "Generated: $(date)"
echo

# System resources
echo "📊 System Resources:"
echo "CPU Usage: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)%"
echo "Memory Usage: $(free -m | awk 'NR==2{printf "%.1f%%", $3*100/$2}')"
echo "Disk Usage: $(df -h / | awk 'NR==2{print $5}')"
echo

# Application status
echo "🚀 Application Status:"
if sudo systemctl is-active --quiet authservice.service; then
    echo "✅ Auth Service: Running"
    echo "   Uptime: $(sudo systemctl show authservice.service --property=ActiveEnterTimestamp | cut -d'=' -f2)"
else
    echo "❌ Auth Service: Not running"
fi
echo

# Docker services status
if command -v docker &> /dev/null; then
    echo "🐳 Docker Services:"
    if [[ -f "docker-compose-prod.yml" ]]; then
        docker compose -f docker-compose-prod.yml ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
    else
        echo "No Docker Compose file found"
    fi
    echo
fi

# Network status
echo "🌐 Network Status:"
echo "Nginx: $(sudo systemctl is-active nginx)"
echo "Port 8080: $(netstat -tlnp | grep :8080 | wc -l) connections"
echo "Port 80: $(netstat -tlnp | grep :80 | wc -l) connections"
echo

# Log summary
echo "📝 Recent Logs Summary:"
if [[ -f "/var/log/authservice/application.log" ]]; then
    echo "Last 5 application log entries:"
    tail -5 /var/log/authservice/application.log | while read line; do
        echo "   $line"
    done
else
    echo "No application logs found"
fi
EOF
    
    chmod +x monitor-app.sh
    
    print_success "Enhanced monitoring and maintenance scripts created"
}

# Function to display final instructions
show_final_instructions() {
    echo
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}           DEPLOYMENT COMPLETE!        ${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Copy your application files to /var/www/authservice/"
    echo "2. Update /var/www/authservice/application-prod.properties with your actual values"
    echo "3. Run: ./deploy-app.sh"
    echo "4. Check service status: sudo systemctl status authservice.service"
    echo "5. View logs: sudo journalctl -u authservice.service -f"
    echo
    echo -e "${BLUE}Useful commands:${NC}"
    echo "• Start service: sudo systemctl start authservice.service"
    echo "• Stop service: sudo systemctl stop authservice.service"
    echo "• Restart service: sudo systemctl restart authservice.service"
    echo "• View logs: sudo journalctl -u authservice.service -f"
    echo "• Check Nginx: sudo systemctl status nginx"
    echo
    echo -e "${BLUE}Files created:${NC}"
    echo "• /etc/nginx/sites-available/authservice"
    echo "• /etc/systemd/system/authservice.service"
    echo "• deploy-app.sh (deployment helper)"
    echo "• backup-app.sh (backup script)"
    echo
    echo -e "${YELLOW}Remember to:${NC}"
    echo "• Configure your domain DNS to point to this server"
    echo "• Set up SSL certificate if needed"
    echo "• Configure firewall rules"
    echo "• Set up monitoring and alerting"
    echo "• Regular backups"
}

# Main execution
main() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}    Auth Service Deployment Script     ${NC}"
    echo -e "${BLUE}         Ubuntu 24.04 Edition          ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo
    
    # Check prerequisites
    check_root
    check_ubuntu_version
    
    # Install everything
    update_system
    install_essential_packages
    install_java
    install_maven
    install_docker
    install_nginx
    install_postgresql
    install_redis
    create_app_directory
    configure_nginx_vhost
    create_systemd_service
    create_deployment_script
    create_env_config
    setup_ssl
    create_maintenance_scripts
    setup_docker_compose
    
    # Show final instructions
    show_final_instructions
}

# Run main function
main "$@"
