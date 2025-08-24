# AuthService - Spring Boot Authentication Microservice

A comprehensive, production-ready authentication microservice built with Spring Boot 3.5.5, featuring JWT authentication, user management, and multi-language support.

## 🚀 Features

### Core Authentication
- **User Registration & Login** with email/username
- **JWT Token Management** (access & refresh tokens)
- **Password Management** (forgot, reset, change)
- **Email Verification** system
- **Two-Factor Authentication** (TOTP)
- **Account Security** (lockout, expiration, status management)

### Security Features
- **Spring Security 6** integration
- **BCrypt password encryption**
- **Account lockout protection**
- **Session management**
- **Audit logging** for all user actions
- **Soft delete** for data retention compliance

### Internationalization
- **Multi-language support** (English, Hindi, Spanish, French, German, Arabic, Chinese, Japanese)
- **Localized API responses** with message keys
- **Dynamic language switching** via headers
- **Fallback to default language**

### Infrastructure
- **PostgreSQL** database with Flyway migrations
- **Redis** for caching and session storage
- **Apache Kafka** for event streaming
- **Docker Compose** for easy development setup
- **Health monitoring** and metrics

## 🏗️ Project Structure

```
src/
├── main/
│   ├── java/com/josam/authservice/
│   │   ├── config/                 # Configuration classes
│   │   │   ├── JpaConfig.java     # JPA auditing configuration
│   │   │   └── SecurityConfig.java # Spring Security configuration
│   │   ├── constants/              # API constants and configuration
│   │   │   └── ApiConstants.java   # Centralized API configuration
│   │   ├── controller/             # REST API controllers
│   │   │   └── HealthController.java # Health check endpoint
│   │   ├── dto/                    # Data Transfer Objects
│   │   │   ├── ApiResponse.java    # Standard API response structure
│   │   │   └── auth/               # Authentication DTOs
│   │   │       ├── LoginRequest.java    # Login request DTO
│   │   │       └── RegisterRequest.java # Registration request DTO
│   │   ├── entity/                 # JPA entities
│   │   │   └── User.java          # User entity with UUID primary key
│   │   ├── repository/             # Data access layer
│   │   │   └── UserRepository.java # User repository with custom queries
│   │   └── service/                # Business logic layer
│   │       └── LocalizationService.java # Multi-language support
│   ├── resources/
│   │   ├── db/migration/           # Flyway database migrations
│   │   │   └── V1__Create_User_Table.sql # User table creation
│   │   ├── messages.properties     # Default English messages
│   │   ├── messages_hi.properties  # Hindi messages
│   │   ├── static/                 # Static web resources
│   │   │   └── index.html         # Beautiful dashboard
│   │   └── application.properties  # Application configuration
│   └── test/                       # Test resources
└── pom.xml                         # Maven dependencies

# Infrastructure & Scripts
├── docker-compose.yml              # Full Docker setup
├── docker-compose-no-postgres.yml  # Docker setup without PostgreSQL
├── start.sh                        # Start all services
├── stop.sh                         # Stop all services
├── start-local.sh                  # Start with local PostgreSQL
├── health-check.sh                 # Health check script
└── status.sh                       # Status overview script
```

## 🛠️ Technology Stack

- **Framework**: Spring Boot 3.5.5
- **Java Version**: 17
- **Build Tool**: Maven
- **Database**: PostgreSQL 15
- **ORM**: Spring Data JPA + Hibernate 6
- **Migration**: Flyway
- **Security**: Spring Security 6 + JWT
- **Cache**: Redis
- **Message Broker**: Apache Kafka
- **Containerization**: Docker + Docker Compose
- **Monitoring**: Spring Boot Actuator
- **Documentation**: OpenAPI 3 (Swagger)

## 🚀 Quick Start

### Prerequisites
- Java 17 or higher
- Maven 3.6+
- Docker & Docker Compose
- PostgreSQL (optional, can use Docker)

### Option 1: Full Docker Setup (Recommended for Development)

1. **Clone and navigate to project**
   ```bash
   cd authservice
   ```

2. **Start all services**
   ```bash
   ./start.sh
   ```
   This starts:
   - PostgreSQL (port 5432)
   - Redis (port 6379)
   - Kafka + Zookeeper (ports 9092, 2181)
   - Kafka UI (port 8080)
   - pgAdmin (port 5050)

3. **Access services**
   - **Application**: http://localhost:8080
   - **Kafka UI**: http://localhost:8080
   - **pgAdmin**: http://localhost:5050
   - **Health Check**: http://localhost:8080/api/health

### Option 2: Local Development (IntelliJ IDEA)

1. **Start infrastructure services only**
   ```bash
   ./start-local.sh
   ```

2. **Create database manually** (if using local PostgreSQL)
   ```bash
   psql -U postgres
   CREATE DATABASE authservice;
   \q
   ```

3. **Run in IntelliJ IDEA**
   - Open project in IntelliJ IDEA
   - Run `AuthserviceApplication.java`
   - Application starts on port 8080

### Option 3: Hybrid Setup

1. **Use local PostgreSQL + Docker services**
   ```bash
   ./start-local.sh
   ```

2. **Run Spring Boot app separately**
   ```bash
   mvn spring-boot:run
   ```

## 🔧 Configuration

### Application Properties

Key configuration options in `application.properties`:

```properties
# Database
spring.datasource.url=jdbc:postgresql://localhost:5432/authservice
spring.datasource.username=postgres
spring.datasource.password=postgres

# JPA & Hibernate
spring.jpa.hibernate.ddl-auto=validate
spring.jpa.show-sql=true
spring.jpa.open-in-view=false

# Flyway
spring.flyway.enabled=true
spring.flyway.baseline-on-migrate=true

# Localization
app.default.locale=en
app.supported.locales=en,hi,es,fr,de,ar,zh,ja

# Server
server.port=8080
```

### Environment Variables

```bash
# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=authservice
DB_USERNAME=postgres
DB_PASSWORD=postgres

# JWT
JWT_SECRET_KEY=your-secret-key
JWT_EXPIRATION=86400000

# Localization
DEFAULT_LOCALE=en
SUPPORTED_LOCALES=en,hi,es,fr,de,ar,zh,ja
```

## 🌐 Localization System

### Supported Languages
- **English (en)** - Default language
- **Hindi (hi)** - हिंदी
- **Spanish (es)** - Español
- **French (fr)** - Français
- **German (de)** - Deutsch
- **Arabic (ar)** - العربية
- **Chinese (zh)** - 中文
- **Japanese (ja)** - 日本語

### Usage

#### 1. Set Language via Header
```http
Accept-Language: hi
```

#### 2. API Response with Localization
```json
{
  "status": "success",
  "statusCode": 200,
  "messageKey": "auth.login.success",
  "message": "Login successful",
  "localizedMessages": {
    "en": "Login successful",
    "hi": "लॉगिन सफल",
    "es": "Inicio de sesión exitoso"
  },
  "data": {...},
  "timestamp": "2024-08-23T17:00:00"
}
```

#### 3. Localization Service Usage
```java
@Autowired
private LocalizationService localizationService;

// Get message in current locale
String message = localizationService.getMessage("auth.login.success");

// Get message in specific language
String hindiMessage = localizationService.getMessage("auth.login.success", "hi");

// Get all localized messages
Map<String, String> allMessages = localizationService.getLocalizedMessages("auth.login.success");
```

## 📊 API Structure

### Base URL
```
/api/v1
```

### Standard Response Format
```json
{
  "status": "success|error|warning|info",
  "statusCode": 200,
  "messageKey": "message.key.for.localization",
  "message": "Localized message",
  "localizedMessages": {
    "en": "English message",
    "hi": "हिंदी संदेश"
  },
  "data": {...},
  "meta": {
    "pagination": {...},
    "processingTime": 150,
    "requestId": "uuid-123",
    "apiVersion": "1.0.0"
  },
  "timestamp": "2024-08-23T17:00:00"
}
```

### Authentication Endpoints
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/register` - User registration
- `POST /api/v1/auth/logout` - User logout
- `POST /api/v1/auth/refresh` - Refresh token
- `POST /api/v1/auth/forgot-password` - Forgot password
- `POST /api/v1/auth/reset-password` - Reset password
- `POST /api/v1/auth/verify-email` - Email verification
- `POST /api/v1/auth/change-password` - Change password

### User Management Endpoints
- `GET /api/v1/users/{id}` - Get user by ID
- `PUT /api/v1/users/{id}` - Update user
- `DELETE /api/v1/users/{id}` - Delete user (soft delete)
- `GET /api/v1/users` - List users with pagination

## 🗄️ Database Schema

### Users Table
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20),
    date_of_birth VARCHAR(20),
    gender VARCHAR(10),
    profile_picture VARCHAR(255),
    enabled BOOLEAN DEFAULT true,
    email_verified BOOLEAN DEFAULT false,
    phone_verified BOOLEAN DEFAULT false,
    two_factor_enabled BOOLEAN DEFAULT false,
    two_factor_secret VARCHAR(255),
    marketing_consent BOOLEAN DEFAULT false,
    terms_accepted BOOLEAN DEFAULT false,
    referral_code VARCHAR(50),
    preferred_language VARCHAR(10) DEFAULT 'en',
    timezone VARCHAR(50) DEFAULT 'UTC',
    last_login TIMESTAMP,
    last_password_change TIMESTAMP,
    failed_login_attempts INTEGER DEFAULT 0,
    account_locked_until TIMESTAMP,
    password_reset_token VARCHAR(255),
    password_reset_expires TIMESTAMP,
    email_verification_token VARCHAR(255),
    email_verification_expires TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted BOOLEAN DEFAULT false,
    deleted_at TIMESTAMP,
    deleted_by UUID
);
```

### User Audit Log Table
```sql
CREATE TABLE user_audit_log (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    action VARCHAR(50) NOT NULL,
    details TEXT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 🔐 Security Features

### Password Policy
- Minimum 8 characters
- Must contain uppercase, lowercase, number, and special character
- BCrypt encryption with salt rounds

### Account Protection
- Failed login attempt tracking
- Account lockout after 5 failed attempts
- Lockout duration: 30 minutes
- Password expiration: 90 days

### JWT Configuration
- Access token expiration: 15 minutes
- Refresh token expiration: 7 days
- Secure token storage
- Token rotation on refresh

## 📝 Development Workflow

### 1. Code Quality Standards
- **Clean Code Principles**: Meaningful names, small functions, single responsibility
- **Documentation**: Comprehensive JavaDoc for all public methods
- **Validation**: Input validation with meaningful error messages
- **Error Handling**: Proper exception handling with localized messages

### 2. Pre-commit Hooks (Recommended)
```bash
# Install pre-commit hooks
pre-commit install

# Run checks manually
pre-commit run --all-files
```

### 3. Testing Strategy
- **Unit Tests**: Service layer and business logic
- **Integration Tests**: Repository and controller layers
- **API Tests**: End-to-end API testing
- **Security Tests**: Authentication and authorization

## 🐳 Docker Commands

### Service Management
```bash
# Start all services
docker-compose up -d

# Start specific service
docker-compose up -d postgres

# View logs
docker-compose logs -f

# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

### Individual Service Commands
```bash
# PostgreSQL
docker exec -it authservice-postgres-1 psql -U postgres

# Redis
docker exec -it authservice-redis-1 redis-cli

# Kafka
docker exec -it authservice-kafka-1 kafka-topics --list --bootstrap-server localhost:9092
```

## 📊 Monitoring & Health Checks

### Actuator Endpoints
- `/actuator/health` - Application health status
- `/actuator/info` - Application information
- `/actuator/metrics` - Application metrics

### Health Check Script
```bash
./health-check.sh
```

### Status Overview
```bash
./status.sh
```

## 🚨 Troubleshooting

### Common Issues

#### 1. Port Already in Use
```bash
# Find process using port
lsof -ti:8080

# Kill process
kill -9 <PID>
```

#### 2. Database Connection Failed
```bash
# Check PostgreSQL status
docker-compose ps postgres

# Check logs
docker-compose logs postgres

# Restart service
docker-compose restart postgres
```

#### 3. Kafka Connection Issues
```bash
# Check Zookeeper status
docker-compose ps zookeeper

# Check Kafka status
docker-compose ps kafka

# Restart Kafka
docker-compose restart kafka
```

### Log Analysis
```bash
# Application logs
tail -f logs/application.log

# Docker logs
docker-compose logs -f authservice

# Database logs
docker-compose logs -f postgres
```

## 🔄 Database Migrations

### Running Migrations
```bash
# Automatic (on startup)
# Migrations run automatically when application starts

# Manual (if needed)
mvn flyway:migrate
```

### Creating New Migration
```bash
# Create new migration file
touch src/main/resources/db/migration/V2__Add_New_Table.sql
```

## 🌍 Localization Development

### Adding New Language
1. Create `messages_<lang>.properties` file
2. Add language code to `app.supported.locales` in properties
3. Translate all message keys
4. Test with `Accept-Language` header

### Message Key Convention
```
<module>.<action>.<result>
Examples:
- auth.login.success
- user.create.failed
- validation.email.invalid
```

## 📚 API Documentation

### Swagger UI
- **URL**: http://localhost:8080/swagger-ui.html
- **API Docs**: http://localhost:8080/v3/api-docs

### Postman Collection
Import the provided Postman collection for testing all endpoints.

## 🤝 Contributing

### Development Setup
1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open Pull Request

### Code Standards
- Follow Java coding conventions
- Add comprehensive JavaDoc
- Include unit tests for new features
- Update documentation as needed

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

### Getting Help
- **Issues**: Create GitHub issue with detailed description
- **Documentation**: Check this README and inline code comments
- **Community**: Join our developer community

### Contact
- **Email**: support@josam.com
- **GitHub**: [Josam Team](https://github.com/josam)

---

**Built with ❤️ by Josam Team**

*Last updated: August 23, 2024*
*Version: 1.0.0*
