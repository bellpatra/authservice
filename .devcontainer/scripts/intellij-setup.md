# IntelliJ IDEA Dev Container Setup

## Prerequisites
- IntelliJ IDEA Ultimate Edition (Dev Containers are not supported in Community Edition)
- Docker Desktop running
- Dev Containers plugin installed in IntelliJ IDEA

## Setup Steps

### 1. Install Dev Containers Plugin
1. Go to `File` → `Settings` → `Plugins`
2. Search for "Dev Containers"
3. Install the plugin and restart IntelliJ IDEA

### 2. Open Project in Dev Container
1. Open your project in IntelliJ IDEA
2. When prompted, click "Reopen in Container" 
3. Or go to `File` → `Dev Containers` → `Reopen in Container`

### 3. Wait for Container Build
- IntelliJ IDEA will build the Dev Container
- This may take several minutes on first run
- The container includes:
  - Java 17
  - Maven
  - Docker CLI
  - Development tools

### 4. Verify Environment
Once the container is running:
1. Open Terminal in IntelliJ IDEA
2. Run: `./scripts/dev-setup.sh`
3. This will start all Docker services

### 5. Run Your Application
- Use IntelliJ IDEA's Run Configuration
- Or run `mvn spring-boot:run` in the terminal
- The app will be available at http://localhost:8080

## Benefits of Dev Container
- ✅ **Consistent Environment**: Same setup across all developers
- ✅ **Isolated Dependencies**: No conflicts with local Java/Maven versions
- ✅ **Easy Onboarding**: New developers can start immediately
- ✅ **Docker Integration**: Full access to Docker from within the container
- ✅ **Port Forwarding**: Automatic port forwarding for all services

## Troubleshooting

### Container Won't Start
- Ensure Docker Desktop is running
- Check Docker has enough resources (4GB RAM, 2 CPUs minimum)
- Restart Docker Desktop if needed

### Port Conflicts
- The container forwards ports: 8080, 8081, 8082, 5433, 6379, 9092
- Ensure these ports are not in use on your host machine

### Maven Issues
- The container includes Maven wrapper
- Use `./mvnw` instead of `mvn` if needed
- Maven settings are pre-configured

## Development Workflow
1. **Code**: Write code in IntelliJ IDEA
2. **Build**: Use Maven or IntelliJ IDEA build tools
3. **Run**: Use IntelliJ IDEA Run Configuration
4. **Debug**: Full debugging support in the container
5. **Test**: Run tests with Maven or IntelliJ IDEA test runner

## Container Features
- **Java 17**: Latest LTS version
- **Maven**: Latest stable version
- **Docker**: Full Docker CLI access
- **Git**: Version control tools
- **Development Tools**: curl, wget, vim, nano, tree, htop, jq
