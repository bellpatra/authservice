package com.bellpatra.authservice.controller;

import com.bellpatra.authservice.dto.auth.*;
import com.bellpatra.authservice.dto.common.ApiResponse;
import com.bellpatra.authservice.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * Authentication REST Controller
 * 
 * This controller handles all authentication-related HTTP requests including:
 * - User registration and login
 * - Password reset functionality
 * - Token management (refresh, logout)
 * - User validation (email/username availability)
 * 
 * All endpoints return standardized ApiResponse format with:
 * - status: "success" or "error"
 * - statusCode: HTTP status code
 * - data: Response payload
 * - message: Human-readable message
 * - meta: Metadata (timestamp, fileName, functionName)
 * 
 * @author Bellpatra Team
 * @version 1.0.0
 * @since 2024-08-24
 */
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@Slf4j
public class AuthController {

    /**
     * Authentication service for handling business logic
     */
    private final AuthService authService;

    /**
     * Register a new user
     * 
     * Creates a new user account with the provided information.
     * Validates all input fields and checks for existing email/username.
     * Returns JWT tokens upon successful registration.
     * 
     * @param request RegisterRequest containing user registration data
     * @return ResponseEntity with ApiResponse containing AuthResponse (tokens and user info)
     * @throws IllegalArgumentException if email/username already exists or validation fails
     */
    @PostMapping("/register")
    public ResponseEntity<ApiResponse<AuthResponse>> register(
            @Valid @RequestBody RegisterRequest request) {
        
        log.info("Registration request received for email: {}", request.getEmail());
        AuthResponse response = authService.register(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(
            ApiResponse.success(response, "User registered successfully", "AuthController.java", "register")
        );
    }

    /**
     * Authenticate user login
     * 
     * Validates user credentials and returns JWT tokens upon successful authentication.
     * Handles account lockout after failed attempts and updates last login timestamp.
     * 
     * @param request LoginRequest containing email and password
     * @return ResponseEntity with ApiResponse containing AuthResponse (tokens and user info)
     * @throws BadCredentialsException if credentials are invalid
     * @throws IllegalStateException if account is locked
     */
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(
            @Valid @RequestBody LoginRequest request) {
        
        log.info("Login request received for email: {}", request.getEmail());
        AuthResponse response = authService.login(request);
        return ResponseEntity.ok(
            ApiResponse.success(response, "User logged in successfully", "AuthController.java", "login")
        );
    }

    /**
     * Initiate password reset process
     * 
     * Generates a password reset token and sends reset email to the user.
     * The reset token is valid for 24 hours.
     * 
     * @param request ForgotPasswordRequest containing user email
     * @return ResponseEntity with ApiResponse containing success message
     * @throws IllegalArgumentException if user with email not found
     */
    @PostMapping("/forgot-password")
    public ResponseEntity<ApiResponse<Map<String, String>>> forgotPassword(
            @Valid @RequestBody ForgotPasswordRequest request) {
        
        log.info("Forgot password request received for email: {}", request.getEmail());
        authService.forgotPassword(request);
        
        Map<String, String> data = Map.of("message", "Password reset email sent successfully");
        return ResponseEntity.ok(
            ApiResponse.success(data, "Password reset email sent successfully", "AuthController.java", "forgotPassword")
        );
    }

    /**
     * Reset user password using reset token
     * 
     * Validates the reset token and updates the user's password.
     * The reset token must be valid and not expired.
     * 
     * @param request ResetPasswordRequest containing reset token and new password
     * @return ResponseEntity with ApiResponse containing success message
     * @throws IllegalArgumentException if token is invalid, expired, or passwords don't match
     */
    @PostMapping("/reset-password")
    public ResponseEntity<ApiResponse<Map<String, String>>> resetPassword(
            @Valid @RequestBody ResetPasswordRequest request) {
        
        log.info("Password reset request received for token: {}", request.getToken());
        authService.resetPassword(request);
        
        Map<String, String> data = Map.of("message", "Password reset successfully");
        return ResponseEntity.ok(
            ApiResponse.success(data, "Password reset successfully", "AuthController.java", "resetPassword")
        );
    }

    /**
     * Refresh JWT access token
     * 
     * Generates a new access token using a valid refresh token.
     * Both access and refresh tokens are renewed.
     * 
     * @param refreshToken Valid refresh token as request parameter
     * @return ResponseEntity with ApiResponse containing new AuthResponse (tokens and user info)
     * @throws IllegalArgumentException if refresh token is invalid or expired
     */
    @PostMapping("/refresh-token")
    public ResponseEntity<ApiResponse<AuthResponse>> refreshToken(
            @RequestParam String refreshToken) {
        
        log.info("Token refresh request received");
        AuthResponse response = authService.refreshToken(refreshToken);
        return ResponseEntity.ok(
            ApiResponse.success(response, "Token refreshed successfully", "AuthController.java", "refreshToken")
        );
    }

    /**
     * Logout user and invalidate session
     * 
     * Logs out the user by invalidating their JWT token.
     * In production, this should blacklist the token.
     * 
     * @param token JWT token in Authorization header (Bearer format)
     * @return ResponseEntity with ApiResponse containing success message
     */
    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<Map<String, String>>> logout(
            @RequestHeader("Authorization") String token) {
        
        // Extract token from "Bearer <token>" format
        String actualToken = token.replace("Bearer ", "");
        log.info("Logout request received");
        authService.logout(actualToken);
        
        Map<String, String> data = Map.of("message", "Logged out successfully");
        return ResponseEntity.ok(
            ApiResponse.success(data, "Logged out successfully", "AuthController.java", "logout")
        );
    }

    /**
     * Validate email availability
     * 
     * Checks if the provided email address is already registered in the system.
     * Useful for frontend validation during registration process.
     * 
     * @param email Email address to validate
     * @return ResponseEntity with ApiResponse containing availability status and message
     */
    @GetMapping("/validate-email")
    public ResponseEntity<ApiResponse<Map<String, Object>>> validateEmail(
            @RequestParam String email) {
        
        boolean exists = authService.validateEmail(email);
        Map<String, Object> data = Map.of(
            "available", !exists,
            "message", exists ? "Email already registered" : "Email is available"
        );
        
        return ResponseEntity.ok(
            ApiResponse.success(data, "Email validation completed", "AuthController.java", "validateEmail")
        );
    }

    /**
     * Validate username availability
     * 
     * Checks if the provided username is already taken in the system.
     * Useful for frontend validation during registration process.
     * 
     * @param username Username to validate
     * @return ResponseEntity with ApiResponse containing availability status and message
     */
    @GetMapping("/validate-username")
    public ResponseEntity<ApiResponse<Map<String, Object>>> validateUsername(
            @RequestParam String username) {
        
        boolean exists = authService.validateUsername(username);
        Map<String, Object> data = Map.of(
            "available", !exists,
            "message", exists ? "Username already taken" : "Username is available"
        );
        
        return ResponseEntity.ok(
            ApiResponse.success(data, "Username validation completed", "AuthController.java", "validateUsername")
        );
    }
}
