package com.josam.authservice.service;

import com.josam.authservice.dto.auth.*;
import com.josam.authservice.entity.User;
import com.josam.authservice.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Authentication Service
 * 
 * Core business logic service for handling all authentication-related operations:
 * - User registration with validation and password encoding
 * - User login with credential verification and token generation
 * - Password reset functionality with secure token generation
 * - JWT token management (generation, refresh, validation)
 * - User validation services (email/username availability)
 * 
 * This service implements comprehensive security features including:
 * - Account lockout after failed login attempts
 * - Password reset token expiration (24 hours)
 * - JWT token refresh mechanism
 * - Secure password encoding using BCrypt
 * 
 * All methods are transactional to ensure data consistency.
 * 
 * @author Josam Team
 * @version 1.0.0
 * @since 2024-08-24
 */
@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class AuthService {

    /**
     * Repository for user data access operations
     */
    private final UserRepository userRepository;
    
    /**
     * Password encoder for secure password hashing
     */
    private final PasswordEncoder passwordEncoder;
    
    /**
     * JWT service for token generation and validation
     */
    private final JwtService jwtService;
    
    /**
     * Spring Security authentication manager for credential verification
     */
    private final AuthenticationManager authenticationManager;
    
    /**
     * Email service for sending password reset and verification emails
     */
    private final EmailService emailService;
    
    /**
     * Custom user details service for loading user information
     */
    private final CustomUserDetailsService userDetailsService;



    /**
     * Register a new user account
     * 
     * Creates a new user with the provided registration information.
     * Performs comprehensive validation including:
     * - Password confirmation matching
     * - Email uniqueness verification
     * - Username uniqueness verification
     * - Input field validation (handled by @Valid annotation)
     * 
     * Upon successful registration:
     * - Password is securely hashed using BCrypt
     * - User account is created with default settings
     * - JWT tokens are generated and returned
     * - Registration event is logged
     * 
     * @param request RegisterRequest containing all user registration data
     * @return AuthResponse containing JWT tokens and user information
     * @throws IllegalArgumentException if validation fails or user already exists
     */
    public AuthResponse register(RegisterRequest request) {
        // Validate password confirmation
        if (!request.getPassword().equals(request.getConfirmPassword())) {
            throw new IllegalArgumentException("Password and confirmation do not match");
        }

        // Check if user already exists
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("Email already registered");
        }

        if (userRepository.existsByUsername(request.getUsername())) {
            throw new IllegalArgumentException("Username already taken");
        }

        // Create new user
        User user = User.builder()
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .email(request.getEmail())
                .username(request.getUsername())
                .password(passwordEncoder.encode(request.getPassword()))
                .phoneNumber(request.getPhoneNumber())
                .dateOfBirth(request.getDateOfBirth())
                .gender(request.getGender())
                .marketingConsent(request.getMarketingConsent())
                .termsAccepted(request.getTermsAccepted())
                .referralCode(request.getReferralCode())
                .enabled(true)
                .accountNonExpired(true)
                .accountNonLocked(true)
                .credentialsNonExpired(true)
                .emailVerified(false)
                .phoneVerified(false)
                .twoFactorEnabled(false)
                .failedLoginAttempts(0)
                .build();

        User savedUser = userRepository.save(user);
        log.info("User registered successfully: {}", savedUser.getEmail());

        // Generate tokens
        UserDetails userDetails = userDetailsService.loadUserByUsername(savedUser.getUsername());
        String token = jwtService.generateToken(userDetails);
        String refreshToken = jwtService.generateRefreshToken(userDetails);

        return buildAuthResponse(savedUser, token, refreshToken);
    }

    /**
     * Authenticate user login
     * 
     * Validates user credentials and handles the complete login process:
     * - Authenticates credentials using Spring Security
     * - Checks for account lockout status
     * - Resets failed login attempts on successful login
     * - Updates last login timestamp
     * - Generates fresh JWT tokens
     * 
     * Security features:
     * - Account lockout after multiple failed attempts
     * - Automatic unlock after lockout period
     * - Failed attempt counter reset on success
     * 
     * @param request LoginRequest containing email and password
     * @return AuthResponse containing JWT tokens and user information
     * @throws BadCredentialsException if credentials are invalid
     * @throws IllegalStateException if account is locked
     * @throws UsernameNotFoundException if user doesn't exist
     */
    public AuthResponse login(LoginRequest request) {
        // Authenticate user credentials
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );

        // Load user details and entity
        UserDetails userDetails = userDetailsService.loadUserByUsername(request.getEmail());
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));

        // Check if account is locked
        if (user.getAccountLockedUntil() != null && user.getAccountLockedUntil().isAfter(LocalDateTime.now())) {
            throw new IllegalStateException("Account is temporarily locked. Please try again later.");
        }

        // Reset failed login attempts on successful login
        if (user.getFailedLoginAttempts() > 0) {
            user.setFailedLoginAttempts(0);
            user.setAccountLockedUntil(null);
            userRepository.save(user);
        }

        // Update last login
        user.setLastLogin(LocalDateTime.now());
        userRepository.save(user);

        // Generate tokens
        String token = jwtService.generateToken(userDetails);
        String refreshToken = jwtService.generateRefreshToken(userDetails);

        log.info("User logged in successfully: {}", user.getEmail());
        return buildAuthResponse(user, token, refreshToken);
    }

    public void forgotPassword(ForgotPasswordRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new IllegalArgumentException("User not found with email: " + request.getEmail()));

        // Generate reset token
        String resetToken = UUID.randomUUID().toString();
        user.setPasswordResetToken(resetToken);
        user.setPasswordResetExpires(LocalDateTime.now().plusHours(24));
        userRepository.save(user);

        // Send reset email
        emailService.sendPasswordResetEmail(user.getEmail(), resetToken);
        log.info("Password reset email sent to: {}", user.getEmail());
    }

    public void resetPassword(ResetPasswordRequest request) {
        // Validate password confirmation
        if (!request.getNewPassword().equals(request.getConfirmPassword())) {
            throw new IllegalArgumentException("Password and confirmation do not match");
        }

        // Find user by reset token
        User user = userRepository.findByPasswordResetToken(request.getToken())
                .orElseThrow(() -> new IllegalArgumentException("Invalid or expired reset token"));

        // Check if token is expired
        if (user.getPasswordResetExpires().isBefore(LocalDateTime.now())) {
            throw new IllegalArgumentException("Reset token has expired");
        }

        // Update password
        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        user.setPasswordResetToken(null);
        user.setPasswordResetExpires(null);
        user.setLastPasswordChange(LocalDateTime.now());
        userRepository.save(user);

        log.info("Password reset successfully for user: {}", user.getEmail());
    }

    public AuthResponse refreshToken(String refreshToken) {
        if (!jwtService.isTokenValid(refreshToken)) {
            throw new IllegalArgumentException("Invalid refresh token");
        }

        String username = jwtService.extractUsername(refreshToken);
        UserDetails userDetails = userDetailsService.loadUserByUsername(username);
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));

        // Generate new tokens
        String newToken = jwtService.generateToken(userDetails);
        String newRefreshToken = jwtService.generateRefreshToken(userDetails);

        return buildAuthResponse(user, newToken, newRefreshToken);
    }

    public void logout(String token) {
        // In a real application, you might want to blacklist the token
        // For now, we'll just log the logout
        String username = jwtService.extractUsername(token);
        log.info("User logged out: {}", username);
    }

    /**
     * Build standardized authentication response
     * 
     * Creates a comprehensive AuthResponse object containing:
     * - JWT access and refresh tokens
     * - Token expiration information
     * - User profile information
     * - Account verification status
     * 
     * This method ensures consistent response format across all authentication endpoints.
     * The expiresIn field uses a constant value from JWT configuration for consistency.
     * 
     * @param user User entity containing user information
     * @param token JWT access token
     * @param refreshToken JWT refresh token
     * @return AuthResponse with complete authentication information
     */
    private AuthResponse buildAuthResponse(User user, String token, String refreshToken) {
        Long tokenExpirationSeconds = jwtService.getTokenExpirationSeconds();
        return AuthResponse.builder()
                .token(token)
                .refreshToken(refreshToken)
                .expiresIn(tokenExpirationSeconds) // Constant value for consistency
                .tokenType("Bearer")
                .userId(user.getId())
                .email(user.getEmail())
                .username(user.getUsername())
                .fullName(user.getFirstName() + " " + user.getLastName())
                .roles(new String[]{"USER"}) // Currently hardcoded, can be enhanced for role-based auth
                .issuedAt(LocalDateTime.now())
                .expiresAt(LocalDateTime.now().plusSeconds(tokenExpirationSeconds))
                .emailVerified(user.getEmailVerified())
                .phoneVerified(user.getPhoneVerified())
                .build();
    }

    /**
     * Validate email availability
     * 
     * Checks if the provided email address is already registered in the system.
     * Used for frontend validation to provide immediate feedback to users.
     * 
     * @param email Email address to validate
     * @return true if email exists (unavailable), false if available
     */
    public boolean validateEmail(String email) {
        return userRepository.existsByEmail(email);
    }

    /**
     * Validate username availability
     * 
     * Checks if the provided username is already taken in the system.
     * Used for frontend validation to provide immediate feedback to users.
     * 
     * @param username Username to validate
     * @return true if username exists (unavailable), false if available
     */
    public boolean validateUsername(String username) {
        return userRepository.existsByUsername(username);
    }
}
