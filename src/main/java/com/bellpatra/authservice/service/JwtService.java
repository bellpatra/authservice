package com.bellpatra.authservice.service;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

/**
 * JWT (JSON Web Token) Service
 * 
 * Comprehensive service for handling JWT token operations including:
 * - Token generation (access and refresh tokens)
 * - Token validation and verification
 * - Claims extraction and parsing
 * - Token expiration management
 * 
 * Security Features:
 * - Uses HMAC SHA-512 algorithm for token signing
 * - Configurable token expiration times
 * - Secure secret key management
 * - Comprehensive error handling for various JWT exceptions
 * 
 * Token Types:
 * - Access Token: Short-lived (default 1 hour) for API access
 * - Refresh Token: Long-lived (default 24 hours) for token renewal
 * 
 * Configuration Properties:
 * - jwt.secret: Secret key for token signing
 * - jwt.expiration: Access token expiration in seconds (default: 3600)
 * - jwt.refresh-expiration: Refresh token expiration in seconds (default: 86400)
 * 
 * @author Bellpatra Team
 * @version 1.0.0
 * @since 2024-08-24
 */
@Service
@Slf4j
public class JwtService {

    /**
     * Secret key for JWT token signing and verification
     * Should be a long, complex string in production
     */
    @Value("${jwt.secret:defaultSecretKeyForDevelopmentOnly}")
    private String secret;

    /**
     * Access token expiration time in seconds (default: 1 hour)
     */
    @Value("${jwt.expiration:3600}")
    private Long expiration;

    /**
     * Refresh token expiration time in seconds (default: 24 hours)
     */
    @Value("${jwt.refresh-expiration:86400}")
    private Long refreshExpiration;

    /**
     * Generate cryptographic signing key from secret
     * 
     * Creates a secure HMAC SHA key from the configured secret string.
     * This key is used for both token signing and verification.
     * 
     * @return SecretKey for JWT operations
     */
    private SecretKey getSigningKey() {
        return Keys.hmacShaKeyFor(secret.getBytes());
    }

    /**
     * Extract username from JWT token
     * 
     * Retrieves the subject claim from the token, which contains the username.
     * 
     * @param token JWT token to extract username from
     * @return Username stored in token subject
     * @throws JwtException if token is invalid or expired
     */
    public String extractUsername(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    /**
     * Extract expiration date from JWT token
     * 
     * Retrieves the expiration claim from the token.
     * 
     * @param token JWT token to extract expiration from
     * @return Expiration date of the token
     * @throws JwtException if token is invalid
     */
    public Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }

    /**
     * Extract specific claim from JWT token
     * 
     * Generic method to extract any claim from the token using a resolver function.
     * 
     * @param token JWT token to extract claim from
     * @param claimsResolver Function to resolve the specific claim
     * @return Extracted claim value
     * @throws JwtException if token is invalid
     */
    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    private Claims extractAllClaims(String token) {
        try {
            return Jwts.parser()
                    .verifyWith(getSigningKey())
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();
        } catch (ExpiredJwtException e) {
            log.warn("JWT token expired: {}", e.getMessage());
            throw e;
        } catch (UnsupportedJwtException e) {
            log.error("Unsupported JWT token: {}", e.getMessage());
            throw e;
        } catch (MalformedJwtException e) {
            log.error("Malformed JWT token: {}", e.getMessage());
            throw e;
        } catch (SecurityException e) {
            log.error("JWT signature validation failed: {}", e.getMessage());
            throw e;
        } catch (IllegalArgumentException e) {
            log.error("JWT token is empty: {}", e.getMessage());
            throw e;
        }
    }

    /**
     * Generate JWT access token for user
     * 
     * Creates a standard access token with default claims and configured expiration.
     * The token contains the username as the subject and standard JWT claims.
     * 
     * @param userDetails Spring Security UserDetails containing user information
     * @return JWT access token string
     */
    public String generateToken(UserDetails userDetails) {
        Map<String, Object> claims = new HashMap<>();
        return createToken(claims, userDetails.getUsername(), expiration);
    }

    /**
     * Generate JWT access token with custom claims
     * 
     * Creates an access token with additional custom claims beyond the standard ones.
     * Useful for including additional user information in the token.
     * 
     * @param extraClaims Additional claims to include in the token
     * @param userDetails Spring Security UserDetails containing user information
     * @return JWT access token string with custom claims
     */
    public String generateToken(Map<String, Object> extraClaims, UserDetails userDetails) {
        return createToken(extraClaims, userDetails.getUsername(), expiration);
    }

    /**
     * Generate JWT refresh token for user
     * 
     * Creates a refresh token with longer expiration time for token renewal.
     * Refresh tokens are used to obtain new access tokens without re-authentication.
     * 
     * @param userDetails Spring Security UserDetails containing user information
     * @return JWT refresh token string
     */
    public String generateRefreshToken(UserDetails userDetails) {
        return createToken(new HashMap<>(), userDetails.getUsername(), refreshExpiration);
    }

    private String createToken(Map<String, Object> claims, String subject, Long expirationTime) {
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + expirationTime * 1000);

        return Jwts.builder()
                .claims(claims)
                .subject(subject)
                .issuedAt(now)
                .expiration(expiryDate)
                .signWith(getSigningKey())
                .compact();
    }

    public Boolean isTokenExpired(String token) {
        try {
            return extractExpiration(token).before(new Date());
        } catch (ExpiredJwtException e) {
            return true;
        }
    }

    public Boolean validateToken(String token, UserDetails userDetails) {
        try {
            final String username = extractUsername(token);
            return (username.equals(userDetails.getUsername()) && !isTokenExpired(token));
        } catch (Exception e) {
            log.error("Token validation failed: {}", e.getMessage());
            return false;
        }
    }

    public Boolean isTokenValid(String token) {
        try {
            Jwts.parser()
                    .verifyWith(getSigningKey())
                    .build()
                    .parseSignedClaims(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public Date getTokenExpiration(String token) {
        try {
            return extractExpiration(token);
        } catch (Exception e) {
            return null;
        }
    }

    public Long getTimeUntilExpiration(String token) {
        try {
            Date expiration = extractExpiration(token);
            Date now = new Date();
            return (expiration.getTime() - now.getTime()) / 1000;
        } catch (Exception e) {
            return 0L;
        }
    }

    /**
     * Get configured token expiration time
     * 
     * Returns the configured access token expiration time in seconds.
     * Used for consistent expiresIn values in API responses.
     * 
     * @return Token expiration time in seconds
     */
    public Long getTokenExpirationSeconds() {
        return expiration;
    }
}
