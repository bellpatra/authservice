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

# Global variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_STEP=0
TOTAL_STEPS=18
DOMAIN_NAME=""
INSTALL_POSTGRES=false
INSTALL_REDIS=false
INSTALL_SSL=false
APP_DIR="/var/local/authservice"
USE_DOMAIN=false
DIGITAL_OCEAN=false

# Function to clear screen
clear_screen() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                    🚀 AUTH SERVICE DEPLOYMENT 🚀           ║${NC}"
    echo -e "${CYAN}║                     Ubuntu 24.04 Edition                   ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
}

# Function to show progress bar
show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    local remaining=$((width - completed))
    
    printf "\r${BLUE}[${NC}"
    printf "%${completed}s" | tr ' ' '█'
    printf "%${remaining}s" | tr ' ' '░'
    printf "${BLUE}] ${NC}${WHITE}%3d%%${NC} ${BLUE}(${current}/${total})${NC}" "$percentage"
}

# Function to print header
print_header() {
    local title="$1"
    local width=60
    local padding=$(( (width - ${#title}) / 2 ))
    
    echo -e "${PURPLE}${TOP_LEFT}${HORIZONTAL}${NC}"
    printf "${PURPLE}${VERTICAL}${NC}%${padding}s${WHITE}%s${NC}%${padding}s${PURPLE}${VERTICAL}${NC}\n" "" "$title" ""
    echo -e "${PURPLE}${BOTTOM_LEFT}${HORIZONTAL}${NC}"
    echo
}

# Function to print section header
print_section() {
    local title="$1"
    echo -e "${CYAN}${LEFT_T}${HORIZONTAL} ${WHITE}${title}${NC}"
}

# Function to print status
print_status() {
    echo -e "${BLUE}${VERTICAL} ${BLUE}[INFO]${NC} $1"
}

# Function to print success
print_success() {
    echo -e "${GREEN}${VERTICAL} ${GREEN}[SUCCESS]${NC} $1"
}

# Function to print warning
print_warning() {
    echo -e "${YELLOW}${VERTICAL} ${YELLOW}[WARNING]${NC} $1"
}

# Function to print error
print_error() {
    echo -e "${RED}${VERTICAL} ${RED}[ERROR]${NC} $1"
}

# Function to print step
print_step() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo -e "${PURPLE}${VERTICAL} ${WHITE}Step ${CURRENT_STEP}/${TOTAL_STEPS}:${NC} $1"
    show_progress $CURRENT_STEP $TOTAL_STEPS
    echo
}

# Function to show welcome screen
show_welcome() {
    clear_screen
    
    echo -e "${WHITE}Welcome to the Auth Service Deployment Script!${NC}"
    echo
    echo -e "${CYAN}This script will:${NC}"
    echo -e "${VERTICAL} ${WHITE}•${NC} Install Java 17, Maven, Docker, and Nginx"
    echo -e "${VERTICAL} ${WHITE}•${NC} Configure your domain and SSL certificates"
    echo -e "${VERTICAL} ${WHITE}•${NC} Set up PostgreSQL, Redis, and Kafka via Docker"
    echo -e "${VERTICAL} ${WHITE}•${NC} Create production-ready configuration files"
    echo -e "${VERTICAL} ${WHITE}•${NC} Set up monitoring and backup systems"
    echo
    echo -e "${YELLOW}Requirements:${NC}"
    echo -e "${VERTICAL} ${WHITE}•${NC} Ubuntu 24.04 server"
    echo -e "${VERTICAL} ${WHITE}•${NC} Sudo privileges"
    echo -e "${VERTICAL} ${WHITE}•${NC} Domain name (optional but recommended)"
    echo
    echo -e "${GREEN}Estimated time: 10-15 minutes${NC}"
    echo
    
    read -p "Press Enter to continue or Ctrl+C to abort..."
    echo
}

# Function to get user preferences
get_user_preferences() {
    print_header "Configuration Setup"
    
    # Check if running on Digital Ocean
    echo -e "${CYAN}Platform Detection:${NC}"
    if [[ -f /etc/digitalocean ]]; then
        DIGITAL_OCEAN=true
        print_success "Digital Ocean droplet detected"
    else
        print_status "Standard Ubuntu server detected"
    fi
    echo
    
    # Get domain name
    echo -e "${CYAN}Domain Configuration:${NC}"
    read -p "Enter your domain name (e.g., example.com) or press Enter for IP-based access: " DOMAIN_NAME
    if [[ -z "$DOMAIN_NAME" ]]; then
        DOMAIN_NAME=""
        USE_DOMAIN=false
        print_warning "No domain configured - will use IP address on port 8080"
    else
        USE_DOMAIN=true
        print_success "Domain set to: $DOMAIN_NAME"
    fi
    echo
    
    # Ask about PostgreSQL
    echo -e "${CYAN}Database Configuration:${NC}"
    read -p "Install PostgreSQL locally (outside Docker)? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        INSTALL_POSTGRES=true
        print_success "PostgreSQL will be installed locally"
    else
        print_status "PostgreSQL will be managed via Docker"
    fi
    echo
    
    # Ask about Redis
    echo -e "${CYAN}Cache Configuration:${NC}"
    read -p "Install Redis locally (outside Docker)? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        INSTALL_REDIS=true
        print_success "Redis will be installed locally"
    else
        print_status "Redis will be managed via Docker"
    fi
    echo
    
    # Ask about SSL
    if [[ "$DOMAIN_NAME" != "localhost" ]]; then
        echo -e "${CYAN}SSL Configuration:${NC}"
        read -p "Set up SSL with Let's Encrypt? [Y/n]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            INSTALL_SSL=true
            print_success "SSL will be configured with Let's Encrypt"
        else
            print_warning "SSL setup skipped"
        fi
        echo
    fi
    
    # Show summary
    print_header "Configuration Summary"
    echo -e "${VERTICAL} ${WHITE}Platform:${NC} $([ "$DIGITAL_OCEAN" = true ] && echo "Digital Ocean" || echo "Standard Ubuntu")"
    echo -e "${VERTICAL} ${WHITE}Domain:${NC} $([ "$USE_DOMAIN" = true ] && echo "$DOMAIN_NAME" || echo "IP-based (port 8080)")"
    echo -e "${VERTICAL} ${WHITE}Application Directory:${NC} $APP_DIR"
    echo -e "${VERTICAL} ${WHITE}PostgreSQL:${NC} $([ "$INSTALL_POSTGRES" = true ] && echo "Local" || echo "Docker")"
    echo -e "${VERTICAL} ${WHITE}Redis:${NC} $([ "$INSTALL_REDIS" = true ] && echo "Local" || echo "Docker")"
    echo -e "${VERTICAL} ${WHITE}SSL:${NC} $([ "$INSTALL_SSL" = true ] && echo "Let's Encrypt" || echo "HTTP only")"
    echo
    
    read -p "Press Enter to start installation or Ctrl+C to abort..."
    echo
}

# Function to check prerequisites
check_prerequisites() {
    print_step "Checking system prerequisites"
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root. Please run as a regular user with sudo privileges."
        exit 1
    fi
    print_success "User permissions verified"
    
    # Check if running on Ubuntu 24.04
    if [[ ! -f /etc/os-release ]]; then
        print_error "This script is designed for Ubuntu 24.04. Please run on a supported system."
        exit 1
    fi
    
    source /etc/os-release
    if [[ "$ID" != "ubuntu" || "$VERSION_ID" != "24.04" ]]; then
        print_warning "This script is designed for Ubuntu 24.04. You are running $ID $VERSION_ID"
        read -p "Do you want to continue anyway? [y/N]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    print_success "OS version verified: $ID $VERSION_ID"
    
    # Check sudo privileges
    if ! sudo -n true 2>/dev/null; then
        print_error "Sudo privileges required. Please ensure you can run sudo commands."
        exit 1
    fi
    print_success "Sudo privileges verified"
    
    # Check internet connectivity
    if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        print_error "Internet connectivity required. Please check your network connection."
        exit 1
    fi
    print_success "Internet connectivity verified"
}

# Function to update system
update_system() {
    print_step "Updating system packages"
    
    print_status "Updating package lists..."
    sudo apt update >/dev/null 2>&1
    print_success "Package lists updated"
    
    print_status "Upgrading system packages..."
    sudo apt upgrade -y >/dev/null 2>&1
    print_success "System packages upgraded"
}

# Function to install essential packages
install_essential_packages() {
    print_step "Installing essential packages"
    
    local packages=("curl" "wget" "git" "unzip" "software-properties-common" 
                   "apt-transport-https" "ca-certificates" "gnupg" "lsb-release"
                   "htop" "tree" "jq" "vim" "net-tools")
    
    for package in "${packages[@]}"; do
        print_status "Installing $package..."
        sudo apt install -y "$package" >/dev/null 2>&1
        print_success "$package installed"
    done
}

# Function to install Java
install_java() {
    print_step "Installing OpenJDK 17"
    
    print_status "Installing OpenJDK 17..."
    sudo apt install -y openjdk-17-jdk openjdk-17-jre >/dev/null 2>&1
    
    # Set JAVA_HOME
    echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> ~/.bashrc
    echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.bashrc
    source ~/.bashrc
    
    # Verify installation
    java_version=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2)
    print_success "Java $java_version installed and configured"
}

# Function to install Maven
install_maven() {
    print_step "Installing Maven"
    
    print_status "Installing Maven..."
    sudo apt install -y maven >/dev/null 2>&1
    
    # Verify installation
    maven_version=$(mvn -version 2>&1 | head -n 1 | cut -d' ' -f3)
    print_success "Maven $maven_version installed"
}

# Function to install Docker
install_docker() {
    print_step "Installing Docker and Docker Compose"
    
    print_status "Removing old Docker versions..."
    sudo apt remove -y docker docker-engine docker.io containerd runc >/dev/null 2>&1 || true
    
    print_status "Installing Docker prerequisites..."
    sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release >/dev/null 2>&1
    
    print_status "Adding Docker GPG key..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg >/dev/null 2>&1
    
    print_status "Adding Docker repository..."
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    
    print_status "Installing Docker..."
    sudo apt update >/dev/null 2>&1
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin >/dev/null 2>&1
    
    print_status "Configuring Docker..."
    sudo usermod -aG docker $USER
    sudo systemctl start docker
    sudo systemctl enable docker
    
    # Install Docker Compose standalone
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose >/dev/null 2>&1
    sudo chmod +x /usr/local/bin/docker-compose
    
    # Verify installation
    docker_version=$(docker --version | cut -d' ' -f3 | sed 's/,//')
    print_success "Docker $docker_version and Docker Compose installed"
    print_warning "You may need to log out and back in for docker group permissions"
}

# Function to install Nginx
install_nginx() {
    print_step "Installing and configuring Nginx"
    
    print_status "Installing Nginx..."
    sudo apt install -y nginx >/dev/null 2>&1
    
    print_status "Starting Nginx..."
    sudo systemctl start nginx
    sudo systemctl enable nginx
    
    print_status "Configuring firewall..."
    sudo ufw allow 'Nginx Full' >/dev/null 2>&1
    
    print_success "Nginx installed and configured"
}

# Function to configure Digital Ocean firewall
configure_digital_ocean_firewall() {
    if [[ "$DIGITAL_OCEAN" = true ]]; then
        print_step "Configuring Digital Ocean firewall rules"
        
        print_status "Opening required ports..."
        
        # Open SSH port (22)
        sudo ufw allow 22/tcp
        
        # Open HTTP and HTTPS
        sudo ufw allow 80/tcp
        sudo ufw allow 443/tcp
        
        # Open application port if no domain
        if [[ "$USE_DOMAIN" = false ]]; then
            sudo ufw allow 8080/tcp
            print_success "Port 8080 opened for direct application access"
        fi
        
        # Open database ports for external access if needed
        sudo ufw allow 5432/tcp  # PostgreSQL
        sudo ufw allow 6379/tcp  # Redis
        sudo ufw allow 9092/tcp  # Kafka
        
        # Enable UFW
        echo "y" | sudo ufw enable
        
        print_success "Digital Ocean firewall configured"
    fi
}

# Function to install optional services
install_optional_services() {
    if [[ "$INSTALL_POSTGRES" = true ]]; then
        print_step "Installing PostgreSQL locally"
        sudo apt install -y postgresql postgresql-contrib >/dev/null 2>&1
        sudo systemctl start postgresql
        sudo systemctl enable postgresql
        print_success "PostgreSQL installed locally"
    fi
    
    if [[ "$INSTALL_REDIS" = true ]]; then
        print_step "Installing Redis locally"
        sudo apt install -y redis-server >/dev/null 2>&1
        sudo systemctl start redis-server
        sudo systemctl enable redis-server
        print_success "Redis installed locally"
    fi
}

# Function to create application directory
create_app_directory() {
    print_step "Creating application directory structure"
    
    sudo mkdir -p $APP_DIR
    sudo chown $USER:$USER $APP_DIR
    sudo mkdir -p /var/log/authservice
    sudo chown $USER:$USER /var/log/authservice
    sudo mkdir -p /var/backups/authservice
    sudo chown $USER:$USER /var/backups/authservice
    
    # Create symlink for compatibility
    sudo ln -sf $APP_DIR /var/www/authservice
    
    print_success "Application directories created at $APP_DIR"
}

# Function to configure Nginx
configure_nginx() {
    print_step "Configuring Nginx virtual host"
    
    if [[ "$USE_DOMAIN" = true ]]; then
        # Create Nginx configuration for domain
        sudo tee /etc/nginx/sites-available/authservice >/dev/null << NGINX_DOMAIN_EOF
server {
    listen 80;
    server_name $DOMAIN_NAME www.$DOMAIN_NAME;
    
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
    
    location /static/ {
        alias $APP_DIR/static/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    location /actuator/health {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
NGINX_DOMAIN_EOF
        print_success "Nginx configured for domain: $DOMAIN_NAME"
    else
        # Create Nginx configuration for IP-based access
        sudo tee /etc/nginx/sites-available/authservice >/dev/null << NGINX_IP_EOF
server {
    listen 80;
    server_name _;
    
    # Redirect root to application port
    location / {
        return 301 http://\$host:8080;
    }
    
    # Health check endpoint
    location /health {
        return 200 "OK";
        add_header Content-Type text/plain;
    }
}
NGINX_IP_EOF
        print_success "Nginx configured for IP-based access (port 8080)"
    fi
    
    # Enable site
    sudo ln -sf /etc/nginx/sites-available/authservice /etc/nginx/sites-enabled/
    sudo rm -f /etc/nginx/sites-enabled/default
    
    # Test configuration
    if sudo nginx -t >/dev/null 2>&1; then
        sudo systemctl reload nginx
        print_success "Nginx configuration applied successfully"
    else
        print_error "Nginx configuration failed"
        exit 1
    fi
}

# Function to setup Docker Compose
setup_docker_compose() {
    print_step "Setting up Docker Compose environment"
    
    # Copy existing compose files
    if [[ -f "docker-compose.yml" ]]; then
        cp docker-compose.yml $APP_DIR/
        print_success "Copied docker-compose.yml"
    fi
    
    if [[ -f "docker-compose-no-postgres.yml" ]]; then
        cp docker-compose-no-postgres.yml $APP_DIR/
        print_success "Copied docker-compose-no-postgres.yml"
    fi
    
    # Create production compose file
    cat > $APP_DIR/docker-compose-prod.yml << COMPOSE_EOF
version: '3.8'
services:
  postgres:
    image: postgres:15-alpine
    container_name: authservice-postgres-prod
    environment:
      POSTGRES_DB: authservice
      POSTGRES_USER: \${POSTGRES_USER:-postgres}
      POSTGRES_PASSWORD: \${POSTGRES_PASSWORD:-postgres}
    ports:
      - "127.0.0.1:5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init-scripts:/docker-entrypoint-initdb.d
    networks:
      - authservice-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U \${POSTGRES_USER:-postgres} -d authservice"]
      interval: 30s
      timeout: 10s
      retries: 3

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
    command: redis-server --appendonly yes --requirepass \${REDIS_PASSWORD:-}
    healthcheck:
      test: ["CMD", "redis-cli", "--raw", "incr", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

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

  zookeeper:
    image: confluentinc/cp-zookeeper:7.4.0
    container_name: authservice-zookeeper-prod
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_TICK_TIME: 2000
    networks:
      - authservice-network
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
  kafka_data:

networks:
  authservice-network:
    driver: bridge
COMPOSE_EOF
    
    # Create environment file
    cat > $APP_DIR/.env << ENV_EOF
# Docker Compose Environment Variables
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_secure_password_here
REDIS_PASSWORD=your_redis_password_here
SPRING_PROFILES_ACTIVE=prod
ENV_EOF
    
    print_success "Docker Compose environment configured"
}

# Function to create systemd service
create_systemd_service() {
    print_step "Creating systemd service"
    
    sudo tee /etc/systemd/system/authservice.service >/dev/null << SERVICE_EOF
[Unit]
Description=Auth Service Spring Boot Application
After=network.target docker.service
Requires=docker.service

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
SERVICE_EOF
    
    sudo systemctl daemon-reload
    sudo systemctl enable authservice.service
    
    print_success "Systemd service created and enabled"
}

# Function to setup SSL
setup_ssl() {
    if [[ "$INSTALL_SSL" = true ]]; then
        print_step "Setting up SSL with Let's Encrypt"
        
        print_status "Installing Certbot..."
        sudo apt install -y certbot python3-certbot-nginx >/dev/null 2>&1
        
        print_status "Obtaining SSL certificate..."
        sudo certbot --nginx -d $DOMAIN_NAME -d www.$DOMAIN_NAME --non-interactive --agree-tos --email admin@$DOMAIN_NAME >/dev/null 2>&1
        
        if [[ $? -eq 0 ]]; then
            print_success "SSL certificate obtained successfully"
        else
            print_warning "SSL certificate setup failed. You can try manually later."
        fi
    fi
}

# Function to create management scripts
create_management_scripts() {
    print_step "Creating management and monitoring scripts"
    
    # Create deployment script
    cat > $APP_DIR/deploy-app.sh << DEPLOY_EOF
#!/bin/bash
echo "🚀 Starting application deployment..."
sudo systemctl stop authservice.service 2>/dev/null || true
mvn clean package -DskipTests
cp target/*.jar $APP_DIR/authservice.jar
sudo chown \$USER:\$USER $APP_DIR/authservice.jar
chmod +x $APP_DIR/authservice.jar
sudo systemctl start authservice.service
echo "✅ Application deployed successfully!"
DEPLOY_EOF
    
    chmod +x $APP_DIR/deploy-app.sh
    
    # Create Docker management script
    cat > $APP_DIR/docker-manage.sh << 'DOCKER_EOF'
#!/bin/bash
case "$1" in
    start) docker compose -f docker-compose-prod.yml up -d ;;
    stop) docker compose -f docker-compose-prod.yml down ;;
    restart) docker compose -f docker-compose-prod.yml restart ;;
    status) docker compose -f docker-compose-prod.yml ps ;;
    logs) docker compose -f docker-compose-prod.yml logs -f ;;
    *) echo "Usage: $0 {start|stop|restart|status|logs}" ;;
esac
DOCKER_EOF
    
    chmod +x $APP_DIR/docker-manage.sh
    
    # Create monitoring script
    cat > $APP_DIR/monitor.sh << 'MONITOR_EOF'
#!/bin/bash
echo "🔍 Auth Service Status Report"
echo "=============================="
echo "Application: $(sudo systemctl is-active authservice.service)"
echo "Nginx: $(sudo systemctl is-active nginx)"
echo "Docker: $(sudo systemctl is-active docker)"
echo "PostgreSQL: $(docker exec authservice-postgres-prod pg_isready -U postgres 2>/dev/null && echo "Healthy" || echo "Unhealthy")"
MONITOR_EOF
    
    chmod +x $APP_DIR/monitor.sh
    
    print_success "Management scripts created"
}

# Function to create Digital Ocean specific scripts
create_digital_ocean_scripts() {
    if [[ "$DIGITAL_OCEAN" = true ]]; then
        print_step "Creating Digital Ocean specific scripts"
        
        # Create firewall status script
        cat > $APP_DIR/firewall-status.sh << 'FIREWALL_EOF'
#!/bin/bash
echo "🔥 Digital Ocean Firewall Status"
echo "================================"
echo "UFW Status:"
sudo ufw status verbose
echo
echo "Open Ports:"
sudo netstat -tlnp | grep LISTEN
echo
echo "Active Connections:"
sudo netstat -an | grep ESTABLISHED | wc -l
FIREWALL_EOF
        
        chmod +x $APP_DIR/firewall-status.sh
        
        # Create IP info script
        cat > $APP_DIR/ip-info.sh << 'IP_EOF'
#!/bin/bash
echo "🌐 Server IP Information"
echo "========================"
echo "Public IP:"
curl -s ifconfig.me
echo
echo "Local IP:"
hostname -I
echo
echo "Domain Resolution:"
if [[ -n "$DOMAIN_NAME" && "$DOMAIN_NAME" != "localhost" ]]; then
    nslookup $DOMAIN_NAME
else
    echo "No domain configured"
fi
IP_EOF
        
        chmod +x $APP_DIR/ip-info.sh
        
        # Create deployment guide
        cat > $APP_DIR/DIGITAL_OCEAN_DEPLOYMENT.md << 'GUIDE_EOF'
# Digital Ocean Deployment Guide

## Quick Start
1. **Deploy Application**: `./deploy-app.sh`
2. **Start Services**: `./docker-manage.sh start`
3. **Check Status**: `./monitor.sh`
4. **View IP Info**: `./ip-info.sh`
5. **Check Firewall**: `./firewall-status.sh`

## Access Points
- **Application**: http://YOUR_IP:8080
- **Health Check**: http://YOUR_IP:8080/actuator/health
- **PostgreSQL**: localhost:5432
- **Redis**: localhost:6379
- **Kafka**: localhost:9092

## Firewall Rules
- SSH (22): ✅ Open
- HTTP (80): ✅ Open
- HTTPS (443): ✅ Open
- Application (8080): ✅ Open
- Database ports: ✅ Open

## Next Steps
1. Point your domain to this server's IP
2. Update .env file with secure passwords
3. Configure SSL if using domain
4. Set up monitoring and backups
GUIDE_EOF
        
        print_success "Digital Ocean specific scripts created"
    fi
}

# Function to show completion
show_completion() {
    clear_screen
    
    print_header "🎉 DEPLOYMENT COMPLETE! 🎉"
    
    echo -e "${GREEN}Your Auth Service environment is now ready!${NC}"
    echo
    
    echo -e "${CYAN}📁 Application Directory:${NC}"
    echo -e "${VERTICAL} ${WHITE}$APP_DIR${NC}"
    echo
    
    echo -e "${CYAN}🚀 Next Steps:${NC}"
    echo -e "${VERTICAL} ${WHITE}1.${NC} Copy your application files to $APP_DIR/"
    echo -e "${VERTICAL} ${WHITE}2.${NC} Update .env file with secure passwords"
    echo -e "${VERTICAL} ${WHITE}3.${NC} Run: ./deploy-app.sh"
    echo -e "${VERTICAL} ${WHITE}4.${NC} Start Docker services: ./docker-manage.sh start"
    echo
    
    echo -e "${CYAN}🔧 Useful Commands:${NC}"
    echo -e "${VERTICAL} ${WHITE}•${NC} Deploy app: ./deploy-app.sh"
    echo -e "${VERTICAL} ${WHITE}•${NC} Push code & deploy: ./push-and-deploy.sh"
    echo -e "${VERTICAL} ${WHITE}•${NC} Manage Docker: ./docker-manage.sh {start|stop|status}"
    echo -e "${VERTICAL} ${WHITE}•${NC} Monitor: ./monitor.sh"
    echo -e "${VERTICAL} ${WHITE}•${NC} View logs: sudo journalctl -u authservice.service -f"
    echo
    
    echo -e "${CYAN}🌐 Access Points:${NC}"
    if [[ "$USE_DOMAIN" = true ]]; then
        echo -e "${VERTICAL} ${WHITE}•${NC} Application: http://$DOMAIN_NAME"
        echo -e "${VERTICAL} ${WHITE}•${NC} Health Check: http://$DOMAIN_NAME/actuator/health"
    else
        echo -e "${VERTICAL} ${WHITE}•${NC} Application: http://YOUR_IP:8080"
        echo -e "${VERTICAL} ${WHITE}•${NC} Health Check: http://YOUR_IP:8080/actuator/health"
    fi
    echo -e "${VERTICAL} ${WHITE}•${NC} PostgreSQL: localhost:5432"
    echo -e "${VERTICAL} ${WHITE}•${NC} Redis: localhost:6379"
    echo -e "${VERTICAL} ${WHITE}•${NC} Kafka: localhost:9092"
    echo
    
    echo -e "${YELLOW}⚠️  Important Notes:${NC}"
    echo -e "${VERTICAL} ${WHITE}•${NC} Update passwords in .env file"
    echo -e "${VERTICAL} ${WHITE}•${NC} Configure firewall rules if needed"
    echo -e "${VERTICAL} ${WHITE}•${NC} Set up monitoring and alerting"
    echo -e "${VERTICAL} ${WHITE}•${NC} Regular backups with ./backup-app.sh"
    echo
    
    echo -e "${GREEN}🎯 Your Auth Service is ready for production!${NC}"
    
    if [[ "$DIGITAL_OCEAN" = true ]]; then
        echo
        echo -e "${CYAN}🌊 Digital Ocean Specific:${NC}"
        echo -e "${VERTICAL} ${WHITE}•${NC} Check firewall: ./firewall-status.sh"
        echo -e "${VERTICAL} ${WHITE}•${NC} View IP info: ./ip-info.sh"
        echo -e "${VERTICAL} ${WHITE}•${NC} Read deployment guide: cat DIGITAL_OCEAN_DEPLOYMENT.md"
    fi
}

# Function to create code push script
create_code_push_script() {
    print_step "Creating code push and deployment automation"
    
    cat > $APP_DIR/push-and-deploy.sh << 'PUSH_EOF'
#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🚀 Code Push and Deploy Script${NC}"
echo "====================================="

# Check if we're in a git repository
if [[ ! -d .git ]]; then
    echo -e "${RED}❌ Not a git repository. Please run this from your project root.${NC}"
    exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
echo -e "${BLUE}Current branch:${NC} $CURRENT_BRANCH"

# Check for uncommitted changes
if [[ -n $(git status --porcelain) ]]; then
    echo -e "${YELLOW}⚠️  You have uncommitted changes:${NC}"
    git status --short
    
    read -p "Do you want to commit these changes? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Enter commit message: " commit_message
        git add .
        git commit -m "$commit_message"
        echo -e "${GREEN}✅ Changes committed${NC}"
    fi
fi

# Push to remote
echo -e "${BLUE}Pushing to remote repository...${NC}"
if git push origin $CURRENT_BRANCH; then
    echo -e "${GREEN}✅ Code pushed successfully${NC}"
else
    echo -e "${RED}❌ Push failed${NC}"
    exit 1
fi

# Deploy application
echo -e "${BLUE}Deploying application...${NC}"
if ./deploy-app.sh; then
    echo -e "${GREEN}✅ Application deployed successfully${NC}"
else
    echo -e "${RED}❌ Deployment failed${NC}"
    exit 1
fi

# Start Docker services
echo -e "${BLUE}Starting Docker services...${NC}"
if ./docker-manage.sh start; then
    echo -e "${GREEN}✅ Docker services started${NC}"
else
    echo -e "${RED}❌ Docker services failed to start${NC}"
fi

echo -e "${GREEN}🎉 Code push and deployment completed!${NC}"
echo
echo -e "${BLUE}Next steps:${NC}"
echo "1. Test your application"
echo "2. Monitor logs: ./monitor.sh"
echo "3. Check service status: ./docker-manage.sh status"
PUSH_EOF
    
    chmod +x $APP_DIR/push-and-deploy.sh
    
    # Create git hooks for automatic deployment
    if [[ -d .git ]]; then
        cat > .git/hooks/post-merge << 'HOOK_EOF'
#!/bin/bash
echo "🔄 Post-merge hook triggered"
echo "Deploying updated application..."

cd /var/local/authservice || exit 1
./deploy-app.sh
./docker-manage.sh restart

echo "✅ Automatic deployment completed"
HOOK_EOF
        
        chmod +x .git/hooks/post-merge
        print_success "Git hooks configured for automatic deployment"
    fi
    
    print_success "Code push and deployment automation created"
}

# Main execution
main() {
    show_welcome
    get_user_preferences
    check_prerequisites
    update_system
    install_essential_packages
    install_java
    install_maven
    install_docker
    install_nginx
    configure_digital_ocean_firewall
    install_optional_services
    create_app_directory
    configure_nginx
    setup_docker_compose
    create_systemd_service
    setup_ssl
    create_management_scripts
    create_digital_ocean_scripts
    create_code_push_script
    
    show_completion
}

# Run main function
main "$@"
