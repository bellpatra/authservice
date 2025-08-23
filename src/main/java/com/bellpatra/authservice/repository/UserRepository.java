package com.bellpatra.authservice.repository;

import com.bellpatra.authservice.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * User Repository Interface
 * Provides data access methods for User entity
 * 
 * @author Bellpatra Team
 * @version 1.0.0
 * @since 2024-08-23
 */
@Repository
public interface UserRepository extends JpaRepository<User, UUID> {
    
    /**
     * Find user by username
     * 
     * @param username Username to search for
     * @return Optional containing user if found
     */
    Optional<User> findByUsername(String username);
    
    /**
     * Find user by email
     * 
     * @param email Email to search for
     * @return Optional containing user if found
     */
    Optional<User> findByEmail(String email);

    /**
     * Find user by username or email
     * 
     * @param username Username to search for
     * @param email Email to search for
     * @return Optional containing user if found
     */
    Optional<User> findByUsernameOrEmail(String username, String email);
    
    /**
     * Find user by phone number
     * 
     * @param phoneNumber Phone number to search for
     * @return Optional containing user if found
     */
    Optional<User> findByPhoneNumber(String phoneNumber);
    
    /**
     * Find user by password reset token
     * 
     * @param passwordResetToken Password reset token to search for
     * @return Optional containing user if found
     */
    Optional<User> findByPasswordResetToken(String passwordResetToken);
    
    /**
     * Find user by email verification token
     * 
     * @param emailVerificationToken Email verification token to search for
     * @return Optional containing user if found
     */
    Optional<User> findByEmailVerificationToken(String emailVerificationToken);
    
    /**
     * Find user by referral code
     * 
     * @param referralCode Referral code to search for
     * @return Optional containing user if found
     */
    Optional<User> findByReferralCode(String referralCode);
    
    /**
     * Check if username exists
     * 
     * @param username Username to check
     * @return true if username exists, false otherwise
     */
    boolean existsByUsername(String username);
    
    /**
     * Check if email exists
     * 
     * @param email Email to check
     * @return true if email exists, false otherwise
     */
    boolean existsByEmail(String email);
    
    /**
     * Check if phone number exists
     * 
     * @param phoneNumber Phone number to check
     * @return true if phone number exists, false otherwise
     */
    boolean existsByPhoneNumber(String phoneNumber);
    
    /**
     * Find users by enabled status
     * 
     * @param enabled Enabled status to filter by
     * @return List of users with specified enabled status
     */
    List<User> findByEnabled(Boolean enabled);
    
    /**
     * Find users by email verified status
     * 
     * @param emailVerified Email verified status to filter by
     * @return List of users with specified email verified status
     */
    List<User> findByEmailVerified(Boolean emailVerified);
    
    /**
     * Find users by phone verified status
     * 
     * @param phoneVerified Phone verified status to filter by
     * @return List of users with specified phone verified status
     */
    List<User> findByPhoneVerified(Boolean phoneVerified);
    
    /**
     * Find users by two-factor authentication status
     * 
     * @param twoFactorEnabled Two-factor authentication status to filter by
     * @return List of users with specified two-factor authentication status
     */
    List<User> findByTwoFactorEnabled(Boolean twoFactorEnabled);
    
    /**
     * Find users by marketing consent status
     * 
     * @param marketingConsent Marketing consent status to filter by
     * @return List of users with specified marketing consent status
     */
    List<User> findByMarketingConsent(Boolean marketingConsent);
    
    /**
     * Find users by terms acceptance status
     * 
     * @param termsAccepted Terms acceptance status to filter by
     * @return List of users with specified terms acceptance status
     */
    List<User> findByTermsAccepted(Boolean termsAccepted);
    
    /**
     * Find users by deletion status
     * 
     * @param deleted Deletion status to filter by
     * @return List of users with specified deletion status
     */
    List<User> findByDeleted(Boolean deleted);
    
    /**
     * Find users created after specified date
     * 
     * @param date Date to filter by
     * @return List of users created after specified date
     */
    List<User> findByCreatedAtAfter(LocalDateTime date);
    
    /**
     * Find users created before specified date
     * 
     * @param date Date to filter by
     * @return List of users created before specified date
     */
    List<User> findByCreatedAtBefore(LocalDateTime date);
    
    /**
     * Find users by last login after specified date
     * 
     * @param date Date to filter by
     * @return List of users with last login after specified date
     */
    List<User> findByLastLoginAfter(LocalDateTime date);
    
    /**
     * Find users by last password change after specified date
     * 
     * @param date Date to filter by
     * @return List of users with last password change after specified date
     */
    List<User> findByLastPasswordChangeAfter(LocalDateTime date);
    
    /**
     * Find users with failed login attempts greater than specified count
     * 
     * @param failedAttempts Failed login attempts count to filter by
     * @return List of users with failed login attempts greater than specified count
     */
    List<User> findByFailedLoginAttemptsGreaterThan(Integer failedAttempts);
    
    /**
     * Find users with account locked until after specified date
     * 
     * @param date Date to filter by
     * @return List of users with account locked until after specified date
     */
    List<User> findByAccountLockedUntilAfter(LocalDateTime date);
    
    /**
     * Find users by preferred language
     * 
     * @param preferredLanguage Preferred language to filter by
     * @return List of users with specified preferred language
     */
    List<User> findByPreferredLanguage(String preferredLanguage);
    
    /**
     * Find users by timezone
     * 
     * @param timezone Timezone to filter by
     * @return List of users with specified timezone
     */
    List<User> findByTimezone(String timezone);
    
    /**
     * Find users by gender
     * 
     * @param gender Gender to filter by
     * @return List of users with specified gender
     */
    List<User> findByGender(String gender);
    
    /**
     * Update user's last login timestamp
     * 
     * @param userId User ID to update
     * @param lastLogin Last login timestamp
     */
    @Modifying
    @Query("UPDATE User u SET u.lastLogin = :lastLogin WHERE u.id = :userId")
    void updateLastLogin(@Param("userId") UUID userId, @Param("lastLogin") LocalDateTime lastLogin);
    
    /**
     * Update user's failed login attempts count
     * 
     * @param userId User ID to update
     * @param failedAttempts Failed login attempts count
     */
    @Modifying
    @Query("UPDATE User u SET u.failedLoginAttempts = :failedAttempts WHERE u.id = :userId")
    void updateFailedLoginAttempts(@Param("userId") UUID userId, @Param("failedAttempts") Integer failedAttempts);
    
    /**
     * Update user's account lockout status
     * 
     * @param userId User ID to update
     * @param accountLockedUntil Account lockout timestamp
     */
    @Modifying
    @Query("UPDATE User u SET u.accountLockedUntil = :accountLockedUntil WHERE u.id = :userId")
    void updateAccountLockout(@Param("userId") UUID userId, @Param("accountLockedUntil") LocalDateTime accountLockedUntil);
    
    /**
     * Update user's password reset token
     * 
     * @param userId User ID to update
     * @param passwordResetToken Password reset token
     * @param passwordResetExpires Password reset token expiration
     */
    @Modifying
    @Query("UPDATE User u SET u.passwordResetToken = :passwordResetToken, u.passwordResetExpires = :passwordResetExpires WHERE u.id = :userId")
    void updatePasswordResetToken(@Param("userId") UUID userId, 
                                  @Param("passwordResetToken") String passwordResetToken,
                                  @Param("passwordResetExpires") LocalDateTime passwordResetExpires);
    
    /**
     * Update user's email verification token
     * 
     * @param userId User ID to update
     * @param emailVerificationToken Email verification token
     * @param emailVerificationExpires Email verification token expiration
     */
    @Modifying
    @Query("UPDATE User u SET u.emailVerificationToken = :emailVerificationToken, u.emailVerificationExpires = :emailVerificationExpires WHERE u.id = :userId")
    void updateEmailVerificationToken(@Param("userId") UUID userId,
                                      @Param("emailVerificationToken") String emailVerificationToken,
                                      @Param("emailVerificationExpires") LocalDateTime emailVerificationExpires);
    
    /**
     * Soft delete user
     * 
     * @param userId User ID to delete
     * @param deletedBy User ID who performed the deletion
     */
    @Modifying
    @Query("UPDATE User u SET u.deleted = true, u.deletedAt = :deletedAt, u.deletedBy = :deletedBy WHERE u.id = :userId")
    void softDeleteUser(@Param("userId") UUID userId, 
                        @Param("deletedAt") LocalDateTime deletedAt,
                        @Param("deletedBy") UUID deletedBy);
    
    /**
     * Restore soft deleted user
     * 
     * @param userId User ID to restore
     */
    @Modifying
    @Query("UPDATE User u SET u.deleted = false, u.deletedAt = null, u.deletedBy = null WHERE u.id = :userId")
    void restoreUser(@Param("userId") UUID userId);
    
    /**
     * Count users by enabled status
     * 
     * @param enabled Enabled status to count
     * @return Count of users with specified enabled status
     */
    long countByEnabled(Boolean enabled);
    
    /**
     * Count users by email verified status
     * 
     * @param emailVerified Email verified status to count
     * @return Count of users with specified email verified status
     */
    long countByEmailVerified(Boolean emailVerified);
    
    /**
     * Count users by phone verified status
     * 
     * @param phoneVerified Phone verified status to count
     * @return Count of users with specified phone verified status
     */
    long countByPhoneVerified(Boolean phoneVerified);
    
    /**
     * Count users by two-factor authentication status
     * 
     * @param twoFactorEnabled Two-factor authentication status to count
     * @return Count of users with specified two-factor authentication status
     */
    long countByTwoFactorEnabled(Boolean twoFactorEnabled);
    
    /**
     * Count users by marketing consent status
     * 
     * @param marketingConsent Marketing consent status to count
     * @return Count of users with specified marketing consent status
     */
    long countByMarketingConsent(Boolean marketingConsent);
    
    /**
     * Count users by terms acceptance status
     * 
     * @param termsAccepted Terms acceptance status to count
     * @return Count of users with specified terms acceptance status
     */
    long countByTermsAccepted(Boolean termsAccepted);
    
    /**
     * Count users by deletion status
     * 
     * @param deleted Deletion status to count
     * @return Count of users with specified deletion status
     */
    long countByDeleted(Boolean deleted);
}
