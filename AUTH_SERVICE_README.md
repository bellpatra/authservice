# 🔐 Authentication Service - Complete Guide

This document provides comprehensive information about the Authentication Service, including all available endpoints, features, and usage examples.

## 🚀 Features

### Core Authentication
- ✅ **User Registration** - Complete user onboarding with validation
- ✅ **User Login** - Secure authentication with JWT tokens
- ✅ **Password Reset** - Forgot password and reset functionality
- ✅ **Token Management** - JWT access and refresh tokens
- ✅ **User Logout** - Secure session termination

### Security Features
- ✅ **Password Validation** - Strong password requirements
- ✅ **Account Locking** - Protection against brute force attacks
- ✅ **JWT Security** - Secure token-based authentication
- ✅ **Input Validation** - Comprehensive request validation
- ✅ **Audit Logging** - User action tracking

### API Documentation
- ✅ **Swagger UI** - Interactive API documentation
- ✅ **OpenAPI 3.0** - Standard-compliant API specs
- ✅ **Example Requests** - Ready-to-use API examples
- ✅ **Response Schemas** - Detailed response documentation

## 🌐 API Endpoints

### Base URL
```
http://localhost:8080/api/auth
```

### 1. User Registration
```http
POST /api/auth/register
Content-Type: application/json

{
  "firstName": "John",
  "lastName": "Doe",
  "email": "john.doe@example.com",
  "username": "johndoe",
  "password": "SecurePass123!",
  "confirmPassword": "SecurePass123!",
  "phoneNumber": "+1234567890",
  "dateOfBirth": "15/03/1990",
  "gender": "MALE",
  "termsAccepted": true,
  "marketingConsent": false,
  "referralCode": "REF123"
}
```

**Response (201 Created):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresIn": 3600,
  "tokenType": "Bearer",
  "userId": "123e4567-e89b-12d3-a456-426614174000",
  "email": "john.doe@example.com",
  "username": "johndoe",
  "fullName": "John Doe",
  "roles": ["USER"],
  "emailVerified": false,
  "phoneVerified": false
}
```

### 2. User Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "john.doe@example.com",
  "password": "SecurePass123!",
  "rememberMe": false,
  "deviceInfo": "Chrome 120.0.0.0 on Windows 10",
  "ipAddress": "192.168.1.1"
}
```

**Response (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresIn": 3600,
  "tokenType": "Bearer",
  "userId": "123e4567-e89b-12d3-a456-426614174000",
  "email": "john.doe@example.com",
  "username": "johndoe",
  "fullName": "John Doe",
  "roles": ["USER"],
  "emailVerified": false,
  "phoneVerified": false
}
```

### 3. Forgot Password
```http
POST /api/auth/forgot-password
Content-Type: application/json

{
  "email": "john.doe@example.com",
  "deviceInfo": "Chrome 120.0.0.0 on Windows 10",
  "ipAddress": "192.168.1.1"
}
```

**Response (200 OK):**
```json
{
  "status": "SUCCESS",
  "message": "Password reset email sent successfully"
}
```

### 4. Reset Password
```http
POST /api/auth/reset-password
Content-Type: application/json

{
  "token": "reset-token-123",
  "newPassword": "NewSecurePass123!",
  "confirmPassword": "NewSecurePass123!",
  "deviceInfo": "Chrome 120.0.0.0 on Windows 10",
  "ipAddress": "192.168.1.1"
}
```

**Response (200 OK):**
```json
{
  "status": "SUCCESS",
  "message": "Password reset successfully"
}
```

### 5. Refresh Token
```http
POST /api/auth/refresh-token?refreshToken=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresIn": 3600,
  "tokenType": "Bearer",
  "userId": "123e4567-e89b-12d3-a456-426614174000",
  "email": "john.doe@example.com",
  "username": "johndoe",
  "fullName": "John Doe",
  "roles": ["USER"],
  "emailVerified": false,
  "phoneVerified": false
}
```

### 6. User Logout
```http
POST /api/auth/logout
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response (200 OK):**
```json
{
  "status": "SUCCESS",
  "message": "Logged out successfully"
}
```

### 7. Validate Email
```http
GET /api/auth/validate-email?email=john.doe@example.com
```

**Response (200 OK):**
```json
{
  "available": false,
  "message": "Email already registered"
}
```

### 8. Validate Username
```http
GET /api/auth/validate-username?username=johndoe
```

**Response (200 OK):**
```json
{
  "available": false,
  "message": "Username already taken"
}
```

## 🔒 Security & Validation

### Password Requirements
- **Minimum Length**: 8 characters
- **Maximum Length**: 100 characters
- **Must Contain**:
  - At least one uppercase letter (A-Z)
  - At least one lowercase letter (a-z)
  - At least one number (0-9)
  - At least one special character (@$!%*?&)

### Input Validation
- **Email**: Valid email format, max 100 characters
- **Username**: 3-30 characters, alphanumeric + underscore only
- **First/Last Name**: 2-50 characters, letters and spaces only
- **Phone Number**: International format (+1234567890)
- **Date of Birth**: DD/MM/YYYY format
- **Gender**: MALE, FEMALE, or OTHER

### JWT Configuration
- **Access Token Expiry**: 1 hour (3600 seconds)
- **Refresh Token Expiry**: 24 hours (86400 seconds)
- **Algorithm**: HS256 (HMAC SHA-256)
- **Secret Key**: Configurable via `jwt.secret` property

## 📚 API Documentation

### Swagger UI
Access the interactive API documentation at:
```
http://localhost:8080/swagger-ui/index.html
```

### OpenAPI JSON
Get the raw OpenAPI specification at:
```
http://localhost:8080/v3/api-docs
```

## 🛠️ Development

### Prerequisites
- Java 17+
- Maven 3.6+
- PostgreSQL 15+
- Docker & Docker Compose

### Running the Service
1. **Start Infrastructure**:
   ```bash
   docker-compose up -d
   ```

2. **Run the Application**:
   ```bash
   mvn spring-boot:run
   ```

3. **Access the Service**:
   - Application: http://localhost:8080
   - Swagger UI: http://localhost:8080/swagger-ui/index.html
   - Health Check: http://localhost:8080/api/health

### Configuration
Key configuration properties in `application.properties`:
```properties
# JWT Configuration
jwt.secret=your-super-secret-jwt-key-here
jwt.expiration=3600
jwt.refresh-expiration=86400

# Database Configuration
spring.datasource.url=jdbc:postgresql://localhost:5433/authservice
spring.datasource.username=postgres
spring.datasource.password=postgres
```

## 🧪 Testing

### Test User Registration
```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "User",
    "email": "test@example.com",
    "username": "testuser",
    "password": "TestPass123!",
    "confirmPassword": "TestPass123!",
    "termsAccepted": true
  }'
```

### Test User Login
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "TestPass123!"
  }'
```

## 🔍 Monitoring & Health

### Health Endpoints
- **Overall Health**: `/api/health`
- **Infrastructure Health**: `/api/health/infrastructure`
- **Actuator Health**: `/actuator/health`

### Logging
- **Log Level**: DEBUG (configurable)
- **Security Logs**: Authentication attempts, failures
- **Validation Logs**: Input validation errors
- **Performance Logs**: Request/response timing

## 🚨 Error Handling

### Common Error Responses

#### Validation Error (400)
```json
{
  "status": "ERROR",
  "message": "Validation failed",
  "errors": {
    "email": "Invalid email format",
    "password": "Password must be between 8 and 100 characters"
  },
  "timestamp": "2024-08-23T18:30:00"
}
```

#### Authentication Error (401)
```json
{
  "status": "ERROR",
  "message": "Invalid credentials",
  "timestamp": "2024-08-23T18:30:00"
}
```

#### Account Locked (423)
```json
{
  "status": "ERROR",
  "message": "Account is temporarily locked. Please try again later.",
  "timestamp": "2024-08-23T18:30:00"
}
```

#### User Not Found (404)
```json
{
  "status": "ERROR",
  "message": "User not found with email: user@example.com",
  "timestamp": "2024-08-23T18:30:00"
}
```

## 🔐 Security Best Practices

### For Production Use
1. **Change JWT Secret**: Use a strong, unique secret key
2. **Enable HTTPS**: Use SSL/TLS encryption
3. **Rate Limiting**: Implement API rate limiting
4. **CORS Configuration**: Restrict cross-origin requests
5. **Audit Logging**: Enable comprehensive audit trails
6. **Password Policies**: Enforce strong password requirements
7. **Session Management**: Implement proper session handling

### Token Security
- Store refresh tokens securely
- Implement token blacklisting for logout
- Use short-lived access tokens
- Validate tokens on every request
- Implement token rotation

## 📞 Support

For questions, issues, or contributions:
- **Repository**: [GitHub Repository]
- **Documentation**: [API Documentation]
- **Issues**: [GitHub Issues]

---

**Built with ❤️ using Spring Boot, Spring Security, and JWT**
