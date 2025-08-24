package com.josam.authservice.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * User Entity
 * 
 * Comprehensive user entity representing a user account in the authentication system.
 * This entity includes all necessary fields for modern authentication and user management:
 * 
 * Core Identity:
 * - UUID primary key for security and scalability
 * - Username and email (both unique)
 * - Encrypted password storage
 * - Personal information (name, phone, date of birth, gender)
 * 
 * Security Features:
 * - Account status flags (enabled, expired, locked, credentials expired)
 * - Email and phone verification tracking
 * - Two-factor authentication support
 * - Failed login attempt tracking with account lockout
 * - Password reset token management
 * - Email verification token management
 * 
 * User Preferences:
 * - Marketing consent and terms acceptance
 * - Preferred language and timezone
 * - Profile picture URL
 * - Referral code tracking
 * 
 * Audit and Compliance:
 * - Automatic timestamp management (created_at, updated_at)
 * - Soft delete functionality for data retention
 * - Activity tracking (last login, password changes)
 * 
 * The entity uses JPA auditing for automatic timestamp management and follows
 * best practices for user data storage and security.
 * 
 * @author Josam Team
 * @version 1.0.0
 * @since 2024-08-24
 */
@Entity
@Table(name = "users")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class User {
    
    /**
     * Unique identifier for the user
     * Generated automatically using UUID
     */
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", nullable = false, updatable = false)
    private UUID id;
    
    /**
     * Unique username for the user
     * Must be unique across the system
     */
    @Column(unique = true, nullable = false, length = 50)
    private String username;
    
    /**
     * User's email address
     * Must be unique across the system
     */
    @Column(unique = true, nullable = false, length = 100)
    private String email;
    
    /**
     * User's encrypted password
     * Never stored in plain text
     */
    @Column(nullable = false)
    private String password;
    
    /**
     * User's first name
     */
    @Column(name = "first_name", nullable = false, length = 50)
    private String firstName;
    
    /**
     * User's last name
     */
    @Column(name = "last_name", nullable = false, length = 50)
    private String lastName;
    
    /**
     * User's phone number
     * Optional field
     */
    @Column(name = "phone_number", length = 20)
    private String phoneNumber;
    
    /**
     * User's date of birth
     * Optional field
     */
    @Column(name = "date_of_birth")
    private String dateOfBirth;
    
    /**
     * User's gender
     * Optional field
     */
    @Column(length = 10)
    private String gender;
    
    /**
     * User's profile picture URL
     * Optional field
     */
    @Column(name = "profile_picture")
    private String profilePicture;
    
    /**
     * User's account status
     * Controls whether the user can access the system
     */
    @Column(nullable = false)
    private Boolean enabled = true;
    
    /**
     * Account non-expired flag
     * Part of Spring Security account status
     */
    @Column(name = "account_non_expired", nullable = false)
    private Boolean accountNonExpired = true;
    
    /**
     * Account non-locked flag
     * Part of Spring Security account status
     */
    @Column(name = "account_non_locked", nullable = false)
    private Boolean accountNonLocked = true;
    
    /**
     * Credentials non-expired flag
     * Part of Spring Security account status
     */
    @Column(name = "credentials_non_expired", nullable = false)
    private Boolean credentialsNonExpired = true;
    
    /**
     * Email verification status
     * Tracks whether the user has verified their email
     */
    @Column(name = "email_verified", nullable = false)
    private Boolean emailVerified = false;
    
    /**
     * Phone verification status
     * Tracks whether the user has verified their phone
     */
    @Column(name = "phone_verified", nullable = false)
    private Boolean phoneVerified = false;
    
    /**
     * Two-factor authentication enabled
     * Security feature flag
     */
    @Column(name = "two_factor_enabled", nullable = false)
    private Boolean twoFactorEnabled = false;
    
    /**
     * Two-factor authentication secret
     * Used for TOTP generation
     */
    @Column(name = "two_factor_secret")
    private String twoFactorSecret;
    
    /**
     * Marketing communications consent
     * User preference for marketing emails
     */
    @Column(name = "marketing_consent", nullable = false)
    private Boolean marketingConsent = false;
    
    /**
     * Terms and conditions acceptance
     * Required for account creation
     */
    @Column(name = "terms_accepted", nullable = false)
    private Boolean termsAccepted = false;
    
    /**
     * Referral code used during registration
     * Optional field for referral tracking
     */
    @Column(name = "referral_code")
    private String referralCode;
    
    /**
     * User's preferred language
     * For internationalization support
     */
    @Column(name = "preferred_language", length = 10)
    private String preferredLanguage = "en";
    
    /**
     * User's timezone
     * For proper time display
     */
    @Column(name = "timezone", length = 50)
    private String timezone = "UTC";
    
    /**
     * Last login timestamp
     * Tracks user activity
     */
    @Column(name = "last_login")
    private LocalDateTime lastLogin;
    
    /**
     * Last password change timestamp
     * For password expiration tracking
     */
    @Column(name = "last_password_change")
    private LocalDateTime lastPasswordChange;
    
    /**
     * Failed login attempts count
     * For account lockout mechanism
     */
    @Column(name = "failed_login_attempts", nullable = false)
    private Integer failedLoginAttempts = 0;
    
    /**
     * Account lockout timestamp
     * When the account was locked due to failed attempts
     */
    @Column(name = "account_locked_until")
    private LocalDateTime accountLockedUntil;
    
    /**
     * Password reset token
     * For password reset functionality
     */
    @Column(name = "password_reset_token")
    private String passwordResetToken;
    
    /**
     * Password reset token expiration
     * When the reset token expires
     */
    @Column(name = "password_reset_expires")
    private LocalDateTime passwordResetExpires;
    
    /**
     * Email verification token
     * For email verification process
     */
    @Column(name = "email_verification_token")
    private String emailVerificationToken;
    
    /**
     * Email verification token expiration
     * When the verification token expires
     */
    @Column(name = "email_verification_expires")
    private LocalDateTime emailVerificationExpires;
    
    /**
     * Account creation timestamp
     * Automatically set when user is created
     */
    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    /**
     * Last modification timestamp
     * Automatically updated when user is modified
     */
    @LastModifiedDate
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    /**
     * Soft delete flag
     * For data retention compliance
     */
    @Column(name = "deleted", nullable = false)
    private Boolean deleted = false;
    
    /**
     * Deletion timestamp
     * When the user was soft deleted
     */
    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;
    
    /**
     * Deleted by user ID
     * Who performed the deletion
     */
    @Column(name = "deleted_by")
    private UUID deletedBy;
}
