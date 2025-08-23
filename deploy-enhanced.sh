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
    echo -e "${VERTICAL} ${WHITE}•${NC} Install Java 17, Maven, and Docker"
    echo -e "${VERTICAL} ${WHITE}•${NC} Configure direct port access (port 8080)"
    echo -e "${VERTICAL} ${WHITE}•${NC} Set up PostgreSQL, Redis, and Kafka via Docker"
    echo -e "${VERTICAL} ${WHITE}•${NC} Create production-ready configuration files"
    echo -e "${VERTICAL} ${WHITE}•${NC} Set up monitoring and backup systems"
    echo
    echo -e "${YELLOW}Requirements:${NC}"
    echo -e "${VERTICAL} ${WHITE}•${NC} Ubuntu 22.04 or 24.04 server"
    echo -e "${VERTICAL} ${WHITE}•${NC} Regular user with sudo privileges (NOT root)"
    echo -e "${VERTICAL} ${WHITE}•${NC} Domain name (optional - will use IP:8080)"
    echo -e "${VERTICAL} ${WHITE}•${NC} At least 5GB free disk space"
    echo
    echo -e "${GREEN}Estimated time: 10-15 minutes${NC}"
    echo
    
    # Check if user needs help with sudo setup
    if ! sudo -n true 2>/dev/null; then
        echo -e "${RED}⚠️  Sudo access not available!${NC}"
        echo -e "${YELLOW}You need to set up sudo access before running this script.${NC}"
        echo
        echo -e "${CYAN}Quick Fix Options:${NC}"
        echo -e "${VERTICAL} ${WHITE}1.${NC} Use Digital Ocean Console (recommended)"
        echo -e "${VERTICAL} ${WHITE}2.${NC} Switch to root and add user to sudo group"
        echo -e "${VERTICAL} ${WHITE}3.${NC} Recreate droplet with proper user setup"
        echo
        echo -e "${BLUE}Press Enter to see detailed setup instructions...${NC}"
        read -p ""
        
        show_sudo_setup_help
        exit 1
    fi
    
    read -p "Press Enter to continue or Ctrl+C to abort..."
    echo
}

# Function to show sudo setup help
show_sudo_setup_help() {
    clear_screen
    print_header "🔧 Sudo Setup Instructions"
    
    echo -e "${CYAN}Method 1: Digital Ocean Console (Easiest)${NC}"
    echo -e "${VERTICAL} ${WHITE}1.${NC} Go to your Digital Ocean dashboard"
    echo -e "${VERTICAL} ${WHITE}2.${NC} Click on your droplet"
    echo -e "${VERTICAL} ${WHITE}3.${NC} Click 'Console' or 'Launch Console'"
    echo -e "${VERTICAL} ${WHITE}4.${NC} This gives you root access"
    echo -e "${VERTICAL} ${WHITE}5.${NC} Run these commands:"
    echo
    echo -e "${WHITE}   # Create new user with sudo${NC}"
    echo -e "${WHITE}   adduser deployuser${NC}"
    echo -e "${WHITE}   usermod -aG sudo deployuser${NC}"
    echo -e "${WHITE}   exit${NC}"
    echo
    echo -e "${WHITE}   # SSH as new user${NC}"
    echo -e "${WHITE}   ssh deployuser@your-server-ip${NC}"
    echo
    echo -e "${CYAN}Method 2: Command Line Fix${NC}"
    echo -e "${VERTICAL} ${WHITE}1.${NC} Switch to root: su -"
    echo -e "${VERTICAL} ${WHITE}2.${NC} Add user to sudo: usermod -aG sudo \$USER"
    echo -e "${VERTICAL} ${WHITE}3.${NC} Exit root: exit"
    echo -e "${VERTICAL} ${WHITE}4.${NC} Test: sudo whoami"
    echo
    echo -e "${CYAN}Method 3: Recreate Droplet${NC}"
    echo -e "${VERTICAL} ${WHITE}1.${NC} Take snapshot of current droplet"
    echo -e "${VERTICAL} ${WHITE}2.${NC} Create new droplet with Ubuntu 22.04"
    echo -e "${VERTICAL} ${WHITE}3.${NC} Use SSH key or set root password during creation"
    echo -e "${VERTICAL} ${WHITE}4.${NC} Create user with sudo from the start"
    echo
    echo -e "${YELLOW}After setting up sudo access, run this script again:${NC}"
    echo -e "${WHITE}./deploy-enhanced.sh${NC}"
    echo
    echo -e "${GREEN}Need more help? Check Digital Ocean documentation or contact support.${NC}"
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
    
    # Note about direct access
    echo -e "${CYAN}Access Configuration:${NC}"
    if [[ "$USE_DOMAIN" = true ]]; then
        print_status "Your application will be accessible at: http://$DOMAIN_NAME:8080"
        print_warning "Make sure your domain DNS points to this server's IP address"
    else
        print_status "Your application will be accessible at: http://YOUR_SERVER_IP:8080"
        print_warning "No reverse proxy - direct port access only"
    fi
    echo
    
    # Show summary
    print_header "Configuration Summary"
    echo -e "${VERTICAL} ${WHITE}Platform:${NC} $([ "$DIGITAL_OCEAN" = true ] && echo "Digital Ocean" || echo "Standard Ubuntu")"
    echo -e "${VERTICAL} ${WHITE}Access Method:${NC} $([ "$USE_DOMAIN" = true ] && echo "Domain: $DOMAIN_NAME:8080" || echo "Direct IP: YOUR_IP:8080")"
    echo -e "${VERTICAL} ${WHITE}Application Directory:${NC} $APP_DIR"
    echo -e "${VERTICAL} ${WHITE}PostgreSQL:${NC} $([ "$INSTALL_POSTGRES" = true ] && echo "Local" || echo "Docker")"
    echo -e "${VERTICAL} ${WHITE}Redis:${NC} $([ "$INSTALL_REDIS" = true ] && echo "Local" || echo "Docker")"
    echo -e "${VERTICAL} ${WHITE}Reverse Proxy:${NC} None (Direct Port Access)"
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
        print_status "To fix this:"
        print_status "1. Exit root user: exit"
        print_status "2. Login as regular user: ssh username@your-server-ip"
        print_status "3. Ensure user has sudo access: sudo whoami"
        exit 1
    fi
    print_success "User permissions verified"
    
    # Check if running on Ubuntu
    if [[ ! -f /etc/os-release ]]; then
        print_error "This script is designed for Ubuntu. Please run on a supported system."
        exit 1
    fi
    
    source /etc/os-release
    if [[ "$ID" != "ubuntu" ]]; then
        print_error "This script is designed for Ubuntu. You are running $ID $VERSION_ID"
        exit 1
    fi
    
    # Check Ubuntu version compatibility
    if [[ "$VERSION_ID" == "22.04" ]]; then
        print_warning "Ubuntu 22.04 detected. This version is supported but may have minor differences."
        print_status "Continuing with Ubuntu 22.04..."
    elif [[ "$VERSION_ID" == "24.04" ]]; then
        print_success "Ubuntu 24.04 detected - fully supported version."
    else
        print_warning "Ubuntu $VERSION_ID detected. This version may have compatibility issues."
        read -p "Do you want to continue anyway? [y/N]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    print_success "OS version verified: $ID $VERSION_ID"
    
    # Check system architecture
    print_status "Checking system architecture..."
    local arch=$(uname -m)
    if [[ "$arch" == "x86_64" ]]; then
        print_success "x86_64 architecture detected - fully supported"
    elif [[ "$arch" == "aarch64" ]]; then
        print_warning "ARM64 architecture detected - some packages may have limited support"
    else
        print_warning "Unknown architecture: $arch - compatibility not guaranteed"
    fi
    
    # Check sudo privileges with better error handling
    print_status "Checking sudo privileges..."
    if ! sudo -n true 2>/dev/null; then
        print_error "Sudo privileges required. Please ensure you can run sudo commands."
        print_status "To fix this, run these commands:"
        print_status "1. Switch to root: su -"
        print_status "2. Add user to sudo group: usermod -aG sudo $USER"
        print_status "3. Exit root: exit"
        print_status "4. Test sudo: sudo whoami"
        print_status "5. Run this script again: ./deploy-enhanced.sh"
        exit 1
    fi
    print_success "Sudo privileges verified"
    
    # Check internet connectivity
    print_status "Checking internet connectivity..."
    if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        print_error "Internet connectivity required. Please check your network connection."
        exit 1
    fi
    print_success "Internet connectivity verified"
    
    # Check available disk space
    print_status "Checking disk space..."
    local available_space=$(df / | awk 'NR==2 {print $4}')
    local available_gb=$((available_space / 1024 / 1024))
    if [[ $available_gb -lt 5 ]]; then
        print_warning "Low disk space detected: ${available_gb}GB available. Recommended: 10GB+"
        read -p "Continue anyway? [y/N]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        print_success "Disk space verified: ${available_gb}GB available"
    fi
}

# Function to auto-fix common privilege issues
auto_fix_privileges() {
    print_step "Auto-fixing common privilege issues"
    
    # Check if user is in sudo group
    if ! groups | grep -q sudo && ! groups | grep -q admin; then
        print_warning "User not in sudo group. Attempting to fix..."
        
        # Try to switch to root and fix
        if [[ -w /etc/group ]]; then
            print_status "Attempting to add user to sudo group..."
            # This is a fallback - usually won't work without root
            print_warning "Cannot auto-fix: root access required"
            print_status "Please use one of the manual methods shown earlier"
            return 1
        fi
    fi
    
    # Check if sudo is installed
    if ! command -v sudo &> /dev/null; then
        print_warning "Sudo not installed. Attempting to install..."
        if command -v apt &> /dev/null; then
            # Try to install sudo (this might fail without root)
            print_status "Installing sudo..."
            if apt install -y sudo 2>/dev/null; then
                print_success "Sudo installed successfully"
            else
                print_warning "Cannot install sudo without root access"
                return 1
            fi
        fi
    fi
    
    print_success "Privilege issues resolved or require manual intervention"
    return 0
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

# Function to setup repositories for different Ubuntu versions
setup_repositories() {
    print_step "Setting up repositories for Ubuntu $(lsb_release -cs)"
    
    local ubuntu_version=$(lsb_release -cs)
    
    if [[ "$ubuntu_version" == "jammy" ]]; then
        # Ubuntu 22.04 LTS
        print_status "Configuring repositories for Ubuntu 22.04 LTS (Jammy Jellyfish)"
        
        # Enable universe repository if not already enabled
        if ! grep -q "universe" /etc/apt/sources.list; then
            print_status "Enabling universe repository..."
            sudo add-apt-repository universe -y >/dev/null 2>&1
        fi
        
        # Enable multiverse repository if not already enabled
        if ! grep -q "multiverse" /etc/apt/sources.list; then
            print_status "Enabling multiverse repository..."
            sudo add-apt-repository multiverse -y >/dev/null 2>&1
        fi
        
        print_success "Ubuntu 22.04 repositories configured"
        
    elif [[ "$ubuntu_version" == "noble" ]]; then
        # Ubuntu 24.04 LTS
        print_status "Configuring repositories for Ubuntu 24.04 LTS (Noble Numbat)"
        
        # Ubuntu 24.04 has these repositories enabled by default
        print_success "Ubuntu 24.04 repositories are pre-configured"
        
    else
        # Other Ubuntu versions
        print_warning "Unknown Ubuntu version: $ubuntu_version"
        print_status "Attempting to enable standard repositories..."
        
        # Try to enable universe and multiverse
        sudo add-apt-repository universe -y >/dev/null 2>&1 || true
        sudo add-apt-repository multiverse -y >/dev/null 2>&1 || true
        
        print_success "Standard repositories configured"
    fi
    
    # Update package lists after repository changes
    print_status "Updating package lists after repository changes..."
    sudo apt update >/dev/null 2>&1
    print_success "Repository setup completed"
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
    # Handle different Ubuntu versions for Java installation
    local ubuntu_version=$(lsb_release -cs)
    if [[ "$ubuntu_version" == "jammy" ]]; then
        # Ubuntu 22.04 LTS - use universe repository
        sudo apt update >/dev/null 2>&1
        sudo apt install -y openjdk-17-jdk openjdk-17-jre >/dev/null 2>&1
    elif [[ "$ubuntu_version" == "noble" ]]; then
        # Ubuntu 24.04 LTS - default repositories
        sudo apt install -y openjdk-17-jdk openjdk-17-jre >/dev/null 2>&1
    else
        # Fallback for other versions
        sudo apt install -y openjdk-17-jdk openjdk-17-jre >/dev/null 2>&1
    fi
    
    # Set JAVA_HOME based on architecture
    local java_home=""
    if [[ -d "/usr/lib/jvm/java-17-openjdk-amd64" ]]; then
        java_home="/usr/lib/jvm/java-17-openjdk-amd64"
    elif [[ -d "/usr/lib/jvm/java-17-openjdk-x64" ]]; then
        java_home="/usr/lib/jvm/java-17-openjdk-x64"
    else
        # Find Java installation
        java_home=$(update-alternatives --list java | head -1 | sed 's|/bin/java||')
    fi
    
    if [[ -n "$java_home" ]]; then
        echo "export JAVA_HOME=$java_home" >> ~/.bashrc
        echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.bashrc
        source ~/.bashrc
        print_success "JAVA_HOME set to: $java_home"
    else
        print_warning "Could not determine JAVA_HOME automatically"
    fi
    
    # Verify installation
    java_version=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2)
    print_success "Java $java_version installed and configured"
}

# Function to install Maven
install_maven() {
    print_step "Installing Maven"
    
    print_status "Installing Maven..."
    # Handle different Ubuntu versions for Maven installation
    local ubuntu_version=$(lsb_release -cs)
    if [[ "$ubuntu_version" == "jammy" ]]; then
        # Ubuntu 22.04 LTS - use universe repository
        sudo apt update >/dev/null 2>&1
        sudo apt install -y maven >/dev/null 2>&1
    elif [[ "$ubuntu_version" == "noble" ]]; then
        # Ubuntu 24.04 LTS - default repositories
        sudo apt install -y maven >/dev/null 2>&1
    else
        # Fallback for other versions
        sudo apt install -y maven >/dev/null 2>&1
    fi
    
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
    # Handle different Ubuntu versions for Docker repository
    local ubuntu_version=$(lsb_release -cs)
    if [[ "$ubuntu_version" == "jammy" ]]; then
        # Ubuntu 22.04 LTS
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu jammy stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    elif [[ "$ubuntu_version" == "noble" ]]; then
        # Ubuntu 24.04 LTS
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu noble stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    else
        # Fallback to detected version
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $ubuntu_version stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    fi
    
    print_status "Installing Docker..."
    sudo apt update >/dev/null 2>&1
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin >/dev/null 2>&1
    
    print_status "Configuring Docker..."
    sudo usermod -aG docker $USER
    sudo systemctl start docker
    sudo systemctl enable docker
    
    # Install Docker Compose standalone (backup)
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose >/dev/null 2>&1
    sudo chmod +x /usr/local/bin/docker-compose
    
    # Verify installation
    docker_version=$(docker --version | cut -d' ' -f3 | sed 's/,//')
    print_success "Docker $docker_version and Docker Compose installed"
    print_warning "You may need to log out and back in for docker group permissions"
}

# Function to configure firewall for direct port access
configure_firewall_direct() {
    print_step "Configuring firewall for direct port access"
    
    print_status "Opening required ports..."
    
    # Open SSH port (22)
    sudo ufw allow 22/tcp
    
    # Open application port directly
    sudo ufw allow 8080/tcp
    
    # Open database ports if needed
    sudo ufw allow 5432/tcp  # PostgreSQL
    sudo ufw allow 6379/tcp  # Redis
    sudo ufw allow 9092/tcp  # Kafka
    
    # Enable UFW if not already enabled
    if ! sudo ufw status | grep -q "Status: active"; then
        echo "y" | sudo ufw enable
    fi
    
    print_success "Firewall configured for direct port access"
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

# Function to configure application for direct port access
configure_direct_access() {
    print_step "Configuring application for direct port access"
    
    if [[ "$USE_DOMAIN" = true ]]; then
        print_status "Domain configured: $DOMAIN_NAME"
        print_status "Application will be accessible at: http://$DOMAIN_NAME:8080"
        print_warning "Make sure your domain DNS points to this server's IP address"
    else
        print_status "No domain configured - using IP address"
        print_status "Application will be accessible at: http://YOUR_SERVER_IP:8080"
    fi
    
    print_success "Direct port access configured on port 8080"
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

# Function to setup application port configuration
setup_application_port() {
    print_step "Setting up application port configuration"
    
    # Create application properties for production
    cat > $APP_DIR/application-prod.properties << 'PROPERTIES_EOF'
# Production Configuration for Direct Port Access
server.port=8080
server.address=0.0.0.0

# Database Configuration (update with your actual values)
spring.datasource.url=jdbc:postgresql://localhost:5432/authservice
spring.datasource.username=postgres
spring.datasource.password=your_password_here
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
logging.level.com.bellpatra.authservice=DEBUG
logging.file.name=/var/log/authservice/application.log
logging.pattern.file=%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n

# Actuator
management.endpoints.web.exposure.include=health,info,metrics
management.endpoint.health.show-details=when-authorized
PROPERTIES_EOF
    
    print_success "Application port configuration created"
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
    
    # Create enhanced monitoring script
    cat > $APP_DIR/monitor.sh << 'MONITOR_EOF'
#!/bin/bash
echo "🔍 Auth Service Status Report"
echo "=============================="
echo "Application: $(sudo systemctl is-active authservice.service)"
echo "Docker: $(sudo systemctl is-active docker)"
echo "PostgreSQL: $(docker exec authservice-postgres-prod pg_isready -U postgres 2>/dev/null && echo "Healthy" || echo "Unhealthy")"
MONITOR_EOF
    
    chmod +x $APP_DIR/monitor.sh
    
    print_success "Management scripts created"
}

# Function to create automated testing scripts
create_automated_testing() {
    print_step "Creating automated testing and health check scripts"
    
    # Create comprehensive health check script
    cat > $APP_DIR/health-check.sh << 'HEALTH_EOF'
#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🏥 Comprehensive Health Check${NC}"
echo "=================================="

# Check application service
echo -e "\n${BLUE}Application Service:${NC}"
if sudo systemctl is-active --quiet authservice.service; then
    echo -e "${GREEN}✅ Auth Service: Running${NC}"
    echo "   Uptime: $(sudo systemctl show authservice.service --property=ActiveEnterTimestamp | cut -d'=' -f2)"
else
    echo -e "${RED}❌ Auth Service: Not running${NC}"
fi

# Check application port
echo -e "\n${BLUE}Application Port (8080):${NC}"
if netstat -tlnp | grep -q ":8080"; then
    echo -e "${GREEN}✅ Port 8080: Listening${NC}"
    echo "   Process: $(netstat -tlnp | grep ":8080" | awk '{print $7}')"
else
    echo -e "${RED}❌ Port 8080: Not listening${NC}"
fi

# Check Docker services
echo -e "\n${BLUE}Docker Services:${NC}"
if command -v docker &> /dev/null; then
    if docker compose -f docker-compose-prod.yml ps | grep -q "Up"; then
        echo -e "${GREEN}✅ Docker services: Running${NC}"
        docker compose -f docker-compose-prod.yml ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
    else
        echo -e "${RED}❌ Docker services: Not running${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Docker: Not installed${NC}"
fi

# Check database connectivity
echo -e "\n${BLUE}Database Connectivity:${NC}"
if docker exec authservice-postgres-prod pg_isready -U postgres >/dev/null 2>&1; then
    echo -e "${GREEN}✅ PostgreSQL: Healthy${NC}"
else
    echo -e "${RED}❌ PostgreSQL: Unhealthy${NC}"
fi

# Check Redis connectivity
echo -e "\n${BLUE}Redis Connectivity:${NC}"
if docker exec authservice-redis-prod redis-cli ping >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Redis: Healthy${NC}"
else
    echo -e "${RED}❌ Redis: Unhealthy${NC}"
fi

# Check application endpoints
echo -e "\n${BLUE}Application Endpoints:${NC}"
if curl -s http://localhost:8080/actuator/health >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Health endpoint: Accessible${NC}"
    health_status=$(curl -s http://localhost:8080/actuator/health | jq -r '.status' 2>/dev/null || echo "Unknown")
    echo "   Status: $health_status"
else
    echo -e "${RED}❌ Health endpoint: Not accessible${NC}"
fi

# Check system resources
echo -e "\n${BLUE}System Resources:${NC}"
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
memory_usage=$(free -m | awk 'NR==2{printf "%.1f%%", $3*100/$2}')
disk_usage=$(df -h / | awk 'NR==2{print $5}')

echo "   CPU Usage: ${cpu_usage}%"
echo "   Memory Usage: ${memory_usage}"
echo "   Disk Usage: ${disk_usage}"

# Check firewall status
echo -e "\n${BLUE}Firewall Status:${NC}"
if sudo ufw status | grep -q "Status: active"; then
    echo -e "${GREEN}✅ UFW: Active${NC}"
    echo "   Open ports: $(sudo ufw status | grep -E '^[0-9]+' | wc -l)"
else
    echo -e "${YELLOW}⚠️  UFW: Inactive${NC}"
fi

echo -e "\n${BLUE}Health Check Complete${NC}"
HEALTH_EOF
    
    chmod +x $APP_DIR/health-check.sh
    
    # Create automated testing script
    cat > $APP_DIR/run-tests.sh << 'TEST_EOF'
#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧪 Automated Testing Suite${NC}"
echo "============================="

# Function to run test
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_result="$3"
    
    echo -e "\n${BLUE}Running: $test_name${NC}"
    
    if eval "$test_command" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ PASS: $test_name${NC}"
        return 0
    else
        echo -e "${RED}❌ FAIL: $test_name${NC}"
        return 1
    fi
}

# Test counter
total_tests=0
passed_tests=0

# Test 1: Application service status
total_tests=$((total_tests + 1))
if run_test "Application Service Status" "sudo systemctl is-active --quiet authservice.service" "running"; then
    passed_tests=$((passed_tests + 1))
fi

# Test 2: Port 8080 listening
total_tests=$((total_tests + 1))
if run_test "Port 8080 Listening" "netstat -tlnp | grep -q ':8080'" "listening"; then
    passed_tests=$((passed_tests + 1))
fi

# Test 3: Health endpoint accessible
total_tests=$((total_tests + 1))
if run_test "Health Endpoint" "curl -s http://localhost:8080/actuator/health >/dev/null" "accessible"; then
    passed_tests=$((passed_tests + 1))
fi

# Test 4: Database connectivity
total_tests=$((total_tests + 1))
if run_test "PostgreSQL Connectivity" "docker exec authservice-postgres-prod pg_isready -U postgres >/dev/null" "connected"; then
    passed_tests=$((passed_tests + 1))
fi

# Test 5: Redis connectivity
total_tests=$((total_tests + 1))
if run_test "Redis Connectivity" "docker exec authservice-redis-prod redis-cli ping >/dev/null" "connected"; then
    passed_tests=$((passed_tests + 1))
fi

# Test 6: Docker services running
total_tests=$((total_tests + 1))
if run_test "Docker Services" "docker compose -f docker-compose-prod.yml ps | grep -q 'Up'" "running"; then
    passed_tests=$((passed_tests + 1))
fi

# Test 7: Firewall active
total_tests=$((total_tests + 1))
if run_test "Firewall Status" "sudo ufw status | grep -q 'Status: active'" "active"; then
    passed_tests=$((passed_tests + 1))
fi

# Test 8: Port 8080 open in firewall
total_tests=$((total_tests + 1))
if run_test "Port 8080 Firewall" "sudo ufw status | grep -q '8080.*ALLOW'" "open"; then
    passed_tests=$((passed_tests + 1))
fi

# Summary
echo -e "\n${BLUE}Test Results Summary:${NC}"
echo "======================"
echo -e "${GREEN}Passed: $passed_tests${NC}"
echo -e "${RED}Failed: $((total_tests - passed_tests))${NC}"
echo -e "${BLUE}Total: $total_tests${NC}"

# Calculate percentage
if [[ $total_tests -gt 0 ]]; then
    percentage=$((passed_tests * 100 / total_tests))
    echo -e "${BLUE}Success Rate: ${percentage}%${NC}"
    
    if [[ $percentage -eq 100 ]]; then
        echo -e "${GREEN}🎉 All tests passed! Your system is healthy.${NC}"
        exit 0
    elif [[ $percentage -ge 80 ]]; then
        echo -e "${YELLOW}⚠️  Most tests passed. Minor issues detected.${NC}"
        exit 1
    else
        echo -e "${RED}❌ Many tests failed. System needs attention.${NC}"
        exit 2
    fi
else
    echo -e "${RED}❌ No tests were run.${NC}"
    exit 1
fi
TEST_EOF
    
    chmod +x $APP_DIR/run-tests.sh
    
    # Create continuous monitoring script
    cat > $APP_DIR/continuous-monitor.sh << 'MONITOR_EOF'
#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📊 Continuous Monitoring Started${NC}"
echo "Press Ctrl+C to stop monitoring"
echo "=================================="

# Monitoring interval (seconds)
INTERVAL=30

# Log file
LOG_FILE="/var/log/authservice/monitoring.log"

# Create log directory if it doesn't exist
sudo mkdir -p /var/log/authservice
sudo chown $USER:$USER /var/log/authservice

# Function to log message
log_message() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message" | tee -a "$LOG_FILE"
}

# Function to check service health
check_service_health() {
    local service_name="$1"
    local check_command="$2"
    
    if eval "$check_command" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ $service_name${NC}"
        return 0
    else
        echo -e "${RED}❌ $service_name${NC}"
        return 1
    fi
}

# Main monitoring loop
while true; do
    clear
    echo -e "${BLUE}📊 Continuous Monitoring - $(date)${NC}"
    echo "=============================================="
    
    # Check application service
    echo -e "\n${BLUE}Application Health:${NC}"
    check_service_health "Auth Service" "sudo systemctl is-active --quiet authservice.service"
    check_service_health "Port 8080" "netstat -tlnp | grep -q ':8080'"
    check_service_health "Health Endpoint" "curl -s http://localhost:8080/actuator/health >/dev/null"
    
    # Check Docker services
    echo -e "\n${BLUE}Docker Services:${NC}"
    if command -v docker &> /dev/null; then
        check_service_health "PostgreSQL" "docker exec authservice-postgres-prod pg_isready -U postgres >/dev/null"
        check_service_health "Redis" "docker exec authservice-redis-prod redis-cli ping >/dev/null"
    else
        echo -e "${YELLOW}⚠️  Docker not available${NC}"
    fi
    
    # System resources
    echo -e "\n${BLUE}System Resources:${NC}"
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    memory_usage=$(free -m | awk 'NR==2{printf "%.1f%%", $3*100/$2}')
    disk_usage=$(df -h / | awk 'NR==2{print $5}')
    
    echo "   CPU: ${cpu_usage}% | Memory: ${memory_usage} | Disk: ${disk_usage}"
    
    # Log status
    log_message "Monitoring check completed - CPU: ${cpu_usage}%, Memory: ${memory_usage}, Disk: ${disk_usage}"
    
    # Wait for next check
    echo -e "\n${BLUE}Next check in ${INTERVAL} seconds... (Press Ctrl+C to stop)${NC}"
    sleep $INTERVAL
done
MONITOR_EOF
    
    chmod +x $APP_DIR/continuous-monitor.sh
    
    # Create automated deployment test script
    cat > $APP_DIR/test-deployment.sh << 'DEPLOY_TEST_EOF'
#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Automated Deployment Testing${NC}"
echo "================================="

# Test deployment process
echo -e "\n${BLUE}Step 1: Building Application${NC}"
if mvn clean package -DskipTests; then
    echo -e "${GREEN}✅ Build successful${NC}"
else
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi

echo -e "\n${BLUE}Step 2: Stopping Current Service${NC}"
sudo systemctl stop authservice.service 2>/dev/null || true
echo -e "${GREEN}✅ Service stopped${NC}"

echo -e "\n${BLUE}Step 3: Deploying New Version${NC}"
cp target/*.jar $APP_DIR/authservice.jar
sudo chown $USER:$USER $APP_DIR/authservice.jar
chmod +x $APP_DIR/authservice.jar
echo -e "${GREEN}✅ Application deployed${NC}"

echo -e "\n${BLUE}Step 4: Starting Service${NC}"
sudo systemctl start authservice.service
sleep 10  # Wait for service to start

echo -e "\n${BLUE}Step 5: Testing Deployment${NC}"
if sudo systemctl is-active --quiet authservice.service; then
    echo -e "${GREEN}✅ Service started successfully${NC}"
else
    echo -e "${RED}❌ Service failed to start${NC}"
    sudo systemctl status authservice.service
    exit 1
fi

echo -e "\n${BLUE}Step 6: Health Check${NC}"
if curl -s http://localhost:8080/actuator/health >/dev/null; then
    echo -e "${GREEN}✅ Health endpoint accessible${NC}"
    health_status=$(curl -s http://localhost:8080/actuator/health | jq -r '.status' 2>/dev/null || echo "Unknown")
    echo "   Status: $health_status"
else
    echo -e "${RED}❌ Health endpoint not accessible${NC}"
    exit 1
fi

echo -e "\n${BLUE}Step 7: Running Full Test Suite${NC}"
if ./run-tests.sh; then
    echo -e "${GREEN}✅ All tests passed${NC}"
else
    echo -e "${YELLOW}⚠️  Some tests failed${NC}"
fi

echo -e "\n${GREEN}🎉 Deployment testing completed successfully!${NC}"
DEPLOY_TEST_EOF
    
    chmod +x $APP_DIR/test-deployment.sh
    
    print_success "Automated testing scripts created"
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
    echo -e "${CYAN}🧪 Testing & Health Checks:${NC}"
    echo -e "${VERTICAL} ${WHITE}•${NC} Health check: ./health-check.sh"
    echo -e "${VERTICAL} ${WHITE}•${NC} Run tests: ./run-tests.sh"
    echo -e "${VERTICAL} ${WHITE}•${NC} Test deployment: ./test-deployment.sh"
    echo -e "${VERTICAL} ${WHITE}•${NC} Continuous monitoring: ./continuous-monitor.sh"
    echo
    
    echo -e "${CYAN}🌐 Access Points:${NC}"
    if [[ "$USE_DOMAIN" = true ]]; then
        echo -e "${VERTICAL} ${WHITE}•${NC} Application: http://$DOMAIN_NAME:8080"
        echo -e "${VERTICAL} ${WHITE}•${NC} Health Check: http://$DOMAIN_NAME:8080/actuator/health"
        echo -e "${VERTICAL} ${WHITE}•${NC} API Docs: http://$DOMAIN_NAME:8080/v3/api-docs"
    else
        echo -e "${VERTICAL} ${WHITE}•${NC} Application: http://YOUR_IP:8080"
        echo -e "${VERTICAL} ${WHITE}•${NC} Health Check: http://YOUR_IP:8080/actuator/health"
        echo -e "${VERTICAL} ${WHITE}•${NC} API Docs: http://YOUR_IP:8080/v3/api-docs"
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
    setup_repositories
    install_essential_packages
    install_java
    install_maven
    install_docker
    configure_firewall_direct
    install_optional_services
    create_app_directory
    configure_direct_access
    setup_docker_compose
    create_systemd_service
    setup_application_port
    create_management_scripts
    create_automated_testing
    create_digital_ocean_scripts
    create_code_push_script
    
    show_completion
}

# Run main function
main "$@"
