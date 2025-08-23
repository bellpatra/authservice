# 🐳 Dev Container for Spring Boot Auth Service

This project includes a Dev Container configuration that provides a consistent, isolated development environment for all developers.

## 🚀 Quick Start

### Prerequisites
- **IntelliJ IDEA Ultimate Edition** (Dev Containers not supported in Community Edition)
- **Docker Desktop** running
- **Dev Containers plugin** installed in IntelliJ IDEA

### 1. Install Dev Containers Plugin
1. Open IntelliJ IDEA
2. Go to `File` → `Settings` → `Plugins`
3. Search for "Dev Containers"
4. Install and restart IntelliJ IDEA

### 2. Open Project in Container
1. Open this project in IntelliJ IDEA
2. When prompted, click **"Reopen in Container"**
3. Or go to `File` → `Dev Containers` → `Reopen in Container`

### 3. Wait for Container Build
- First build may take 5-10 minutes
- Subsequent starts will be much faster
- Container includes Java 17, Maven, Docker CLI, and development tools

### 4. Start Development Environment
Once the container is running:
```bash
# In IntelliJ IDEA Terminal
./scripts/dev-setup.sh
```

This script will:
- ✅ Start all Docker services (PostgreSQL, Redis, Kafka, etc.)
- ✅ Compile the project
- ✅ Show access URLs and next steps

## 🌟 What's Included

### Development Tools
- **Java 17** - Latest LTS version
- **Maven** - Latest stable version with wrapper
- **Docker CLI** - Full Docker access from within container
- **Git** - Version control tools
- **Development utilities** - curl, wget, vim, nano, tree, htop, jq

### Services (Auto-started)
- **PostgreSQL** - Database on port 5433
- **Redis** - Cache on port 6379
- **Kafka** - Message broker on port 9092
- **Zookeeper** - Kafka coordination
- **Kafka UI** - Web interface on port 8081
- **pgAdmin** - Database admin on port 8082

### Port Forwarding
All necessary ports are automatically forwarded:
- `8080` → Spring Boot Application
- `8081` → Kafka UI
- `8082` → pgAdmin
- `5433` → PostgreSQL
- `6379` → Redis
- `9092` → Kafka

## 🛠️ Development Workflow

### Running the Application
1. **Use IntelliJ IDEA Run Configuration** (Recommended)
   - Right-click on `AuthserviceApplication.java`
   - Select "Run 'AuthserviceApplication'"

2. **Or use Maven in Terminal**
   ```bash
   mvn spring-boot:run
   ```

### Building and Testing
```bash
# Clean and compile
mvn clean compile

# Run tests
mvn test

# Package
mvn package

# Install dependencies
mvn dependency:resolve
```

### Docker Operations
```bash
# Check service status
docker-compose -f docker-compose.yml -p authservice ps

# View logs
docker-compose -f docker-compose.yml -p authservice logs -f

# Stop services
docker-compose -f docker-compose.yml -p authservice down

# Restart services
docker-compose -f docker-compose.yml -p authservice restart
```

## 🔧 Troubleshooting

### Common Issues

#### Container Won't Start
- Ensure Docker Desktop is running
- Check Docker has enough resources (4GB RAM, 2 CPUs minimum)
- Restart Docker Desktop if needed

#### Port Conflicts
- The container forwards specific ports
- Ensure these ports are not in use on your host machine
- Check with: `lsof -i :8080` (or other ports)

#### Maven Issues
- Container includes Maven wrapper
- Use `./mvnw` instead of `mvn` if needed
- Maven settings are pre-configured

#### Database Connection Issues
- Ensure Docker services are running: `./scripts/dev-setup.sh`
- Check service status: `docker-compose -f docker-compose.yml -p authservice ps`
- Verify PostgreSQL is healthy

### Getting Help
1. Check the container logs in IntelliJ IDEA
2. Run `./scripts/dev-setup.sh` to verify environment
3. Check Docker service status
4. Restart the Dev Container if needed

## 📁 Project Structure in Container

```
/workspaces/
├── src/                    # Source code
├── target/                 # Compiled classes
├── .devcontainer/          # Dev Container configuration
├── docker-compose.yml      # Docker services
├── pom.xml                 # Maven configuration
├── scripts/                # Development scripts
└── README.md              # Project documentation
```

## 🎯 Benefits

- ✅ **Consistent Environment**: Same setup across all developers
- ✅ **Isolated Dependencies**: No conflicts with local Java/Maven versions
- ✅ **Easy Onboarding**: New developers can start immediately
- ✅ **Docker Integration**: Full access to Docker from within the container
- ✅ **Port Forwarding**: Automatic port forwarding for all services
- ✅ **IntelliJ IDEA Integration**: Full IDE support with debugging, testing, etc.

## 🚀 Next Steps

After setting up the Dev Container:

1. **Start the application** using IntelliJ IDEA Run Configuration
2. **Access the dashboard** at http://localhost:8080
3. **Check health endpoint** at http://localhost:8080/api/health
4. **Explore Kafka UI** at http://localhost:8081
5. **Manage database** with pgAdmin at http://localhost:8082

Happy coding! 🎉
