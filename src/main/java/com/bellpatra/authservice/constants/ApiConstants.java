package com.bellpatra.authservice.constants;

/**
 * API Constants for the Authentication Service
 * Contains all API endpoints, status codes, and common constants
 * 
 * @author Bellpatra Team
 * @version 1.0.0
 * @since 2024-08-23
 */
public final class ApiConstants {
    
    // Private constructor to prevent instantiation
    private ApiConstants() {
        throw new UnsupportedOperationException("Utility class cannot be instantiated");
    }
    
    // API Version and Base Path
    public static final String API_VERSION = "v1";
    public static final String API_BASE_PATH = "/api/" + API_VERSION;
    
    // Authentication Endpoints
    public static final String AUTH_BASE_PATH = API_BASE_PATH + "/auth";
    public static final String LOGIN_ENDPOINT = "/login";
    public static final String REGISTER_ENDPOINT = "/register";
    public static final String FORGOT_PASSWORD_ENDPOINT = "/forgot-password";
    public static final String RESET_PASSWORD_ENDPOINT = "/reset-password";
    public static final String REFRESH_TOKEN_ENDPOINT = "/refresh-token";
    public static final String LOGOUT_ENDPOINT = "/logout";
    public static final String VERIFY_TOKEN_ENDPOINT = "/verify-token";
    
    // User Management Endpoints
    public static final String USER_BASE_PATH = API_BASE_PATH + "/users";
    public static final String USER_PROFILE_ENDPOINT = "/profile";
    public static final String UPDATE_PROFILE_ENDPOINT = "/profile";
    public static final String CHANGE_PASSWORD_ENDPOINT = "/change-password";
    
    // Health and Monitoring Endpoints
    public static final String HEALTH_ENDPOINT = "/health";
    public static final String ACTUATOR_BASE_PATH = "/actuator";
    
    // HTTP Status Codes
    public static final int HTTP_OK = 200;
    public static final int HTTP_CREATED = 201;
    public static final int HTTP_ACCEPTED = 202;
    public static final int HTTP_NO_CONTENT = 204;
    public static final int HTTP_BAD_REQUEST = 400;
    public static final int HTTP_UNAUTHORIZED = 401;
    public static final int HTTP_FORBIDDEN = 403;
    public static final int HTTP_NOT_FOUND = 404;
    public static final int HTTP_METHOD_NOT_ALLOWED = 405;
    public static final int HTTP_CONFLICT = 409;
    public static final int HTTP_UNPROCESSABLE_ENTITY = 422;
    public static final int HTTP_TOO_MANY_REQUESTS = 429;
    public static final int HTTP_INTERNAL_SERVER_ERROR = 500;
    public static final int HTTP_SERVICE_UNAVAILABLE = 503;
    
    // Business Status Codes
    public static final String STATUS_SUCCESS = "SUCCESS";
    public static final String STATUS_ERROR = "ERROR";
    public static final String STATUS_WARNING = "WARNING";
    public static final String STATUS_INFO = "INFO";
    
    // JWT Configuration
    public static final String JWT_SECRET_KEY = "jwt.secret.key";
    public static final String JWT_EXPIRATION_TIME = "jwt.expiration.time";
    public static final String JWT_REFRESH_EXPIRATION_TIME = "jwt.refresh.expiration.time";
    public static final String JWT_ISSUER = "jwt.issuer";
    public static final String JWT_AUDIENCE = "jwt.audience";
    
    // Token Types
    public static final String TOKEN_TYPE_ACCESS = "ACCESS";
    public static final String TOKEN_TYPE_REFRESH = "REFRESH";
    public static final String TOKEN_TYPE_RESET_PASSWORD = "RESET_PASSWORD";
    
    // Security Constants
    public static final String ROLE_USER = "ROLE_USER";
    public static final String ROLE_ADMIN = "ROLE_ADMIN";
    public static final String ROLE_MODERATOR = "ROLE_MODERATOR";
    
    // Validation Constants
    public static final int MIN_PASSWORD_LENGTH = 8;
    public static final int MAX_PASSWORD_LENGTH = 128;
    public static final int MIN_USERNAME_LENGTH = 3;
    public static final int MAX_USERNAME_LENGTH = 50;
    public static final int MAX_EMAIL_LENGTH = 100;
    
    // Pagination Constants
    public static final int DEFAULT_PAGE_SIZE = 20;
    public static final int MAX_PAGE_SIZE = 100;
    
    // Cache Constants
    public static final String CACHE_USER_PROFILE = "user_profile";
    public static final String CACHE_USER_PERMISSIONS = "user_permissions";
    public static final String CACHE_REFRESH_TOKENS = "refresh_tokens";
    
    // Error Messages
    public static final String ERROR_INVALID_CREDENTIALS = "Invalid username or password";
    public static final String ERROR_USER_NOT_FOUND = "User not found";
    public static final String ERROR_USER_ALREADY_EXISTS = "User already exists";
    public static final String ERROR_INVALID_TOKEN = "Invalid or expired token";
    public static final String ERROR_TOKEN_EXPIRED = "Token has expired";
    public static final String ERROR_INSUFFICIENT_PERMISSIONS = "Insufficient permissions";
    public static final String ERROR_ACCOUNT_LOCKED = "Account is locked";
    public static final String ERROR_ACCOUNT_DISABLED = "Account is disabled";
    
    // Success Messages
    public static final String SUCCESS_LOGIN = "Login successful";
    public static final String SUCCESS_REGISTER = "User registered successfully";
    public static final String SUCCESS_LOGOUT = "Logout successful";
    public static final String SUCCESS_PASSWORD_RESET = "Password reset successful";
    public static final String SUCCESS_PASSWORD_CHANGE = "Password changed successfully";
    public static final String SUCCESS_TOKEN_REFRESH = "Token refreshed successfully";
    
    // Date Format Constants
    public static final String DATE_TIME_FORMAT = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    public static final String DATE_FORMAT = "yyyy-MM-dd";
    public static final String TIME_FORMAT = "HH:mm:ss";
    
    // File Upload Constants
    public static final long MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
    public static final String[] ALLOWED_FILE_TYPES = {".jpg", ".jpeg", ".png", ".gif", ".pdf"};
    
    // Rate Limiting Constants
    public static final int MAX_LOGIN_ATTEMPTS = 5;
    public static final int LOGIN_ATTEMPT_WINDOW_MINUTES = 15;
    public static final int ACCOUNT_LOCKOUT_DURATION_MINUTES = 30;
    
    // Audit Constants
    public static final String AUDIT_LOGIN = "USER_LOGIN";
    public static final String AUDIT_LOGOUT = "USER_LOGOUT";
    public static final String AUDIT_PASSWORD_CHANGE = "PASSWORD_CHANGE";
    public static final String AUDIT_PROFILE_UPDATE = "PROFILE_UPDATE";
    public static final String AUDIT_ACCOUNT_LOCK = "ACCOUNT_LOCK";
    public static final String AUDIT_ACCOUNT_UNLOCK = "ACCOUNT_UNLOCK";
}
