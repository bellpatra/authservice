package com.bellpatra.authservice.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;

/**
 * Spring Security Configuration
 * 
 * Configures the security settings for the authentication microservice including:
 * - HTTP security filter chain with permitted endpoints
 * - Password encoding using BCrypt
 * - Authentication manager setup
 * - Custom authentication provider configuration
 * 
 * Security Features:
 * - CSRF protection disabled (suitable for stateless API)
 * - Public access to authentication endpoints
 * - Public access to health checks and actuator endpoints
 * - Public access to static resources (CSS, JS, images)
 * - BCrypt password encoding for secure password storage
 * - Custom user details service integration
 * 
 * Permitted Endpoints:
 * - / and /index.html: Landing page
 * - /css/**, /js/**, /images/**: Static resources
 * - /api/health/**: Health check endpoints
 * - /api/auth/**: All authentication endpoints
 * - /actuator/**: Spring Boot actuator endpoints
 * 
 * Authentication:
 * - Uses DaoAuthenticationProvider with custom UserDetailsService
 * - BCrypt password encoder for secure password verification
 * - All other endpoints require authentication
 * 
 * @author Bellpatra Team
 * @version 1.0.0
 * @since 2024-08-24
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    
    /**
     * Configure HTTP Security Filter Chain
     * 
     * Defines the security configuration for HTTP requests including:
     * - Disabling CSRF protection for stateless API
     * - Setting up custom authentication provider
     * - Configuring permitted endpoints for public access
     * - Requiring authentication for all other endpoints
     * 
     * Public Endpoints:
     * - Landing page and static resources
     * - Authentication endpoints (/api/auth/**)
     * - Health check endpoints (/api/health/**)
     * - Actuator endpoints for monitoring
     * 
     * @param http HttpSecurity configuration object
     * @param authenticationProvider Custom authentication provider
     * @return Configured SecurityFilterChain
     * @throws Exception if configuration fails
     */
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http, 
            DaoAuthenticationProvider authenticationProvider) throws Exception {
        http
            // Disable CSRF for stateless API
            .csrf(AbstractHttpConfigurer::disable)
            // Set custom authentication provider
            .authenticationProvider(authenticationProvider)
            // Configure endpoint access rules
            .authorizeHttpRequests(authz -> authz
                // Public access to landing page
                .requestMatchers("/").permitAll()
                .requestMatchers("/index.html").permitAll()
                // Public access to static resources
                .requestMatchers("/css/**", "/js/**", "/images/**").permitAll()
                // Public access to health checks
                .requestMatchers("/api/health/**").permitAll()
                .requestMatchers("/api/test/**").permitAll() // Development test endpoints
                .requestMatchers("/api/minimal/**").permitAll() // Development minimal endpoints
                // Public access to monitoring
                .requestMatchers("/actuator/**").permitAll()
                // Public access to all authentication endpoints
                .requestMatchers("/api/auth/**").permitAll()
                // Legacy Swagger endpoints (kept for compatibility)
                .requestMatchers("/swagger-ui/**", "/v3/api-docs/**", "/swagger-ui.html").permitAll()
                // All other endpoints require authentication
                .anyRequest().authenticated()
            );
        
        return http.build();
    }
    
    /**
     * Password Encoder Bean
     * 
     * Configures BCrypt password encoder for secure password hashing.
     * BCrypt is a secure hashing algorithm that includes salt generation
     * and is resistant to rainbow table attacks.
     * 
     * @return BCryptPasswordEncoder instance
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    /**
     * Authentication Manager Bean
     * 
     * Provides the authentication manager from Spring Security's
     * authentication configuration. Used by authentication services
     * to authenticate user credentials.
     * 
     * @param config Authentication configuration
     * @return AuthenticationManager instance
     * @throws Exception if authentication manager creation fails
     */
    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }

    /**
     * DAO Authentication Provider Bean
     * 
     * Configures a custom authentication provider that uses:
     * - CustomUserDetailsService for loading user details
     * - BCrypt password encoder for password verification
     * 
     * This provider handles the authentication process by loading
     * user details and verifying passwords against stored hashes.
     * 
     * @param userDetailsService Custom service for loading user details
     * @param passwordEncoder Password encoder for verification
     * @return Configured DaoAuthenticationProvider
     */
    @Bean
    public DaoAuthenticationProvider authenticationProvider(
            com.bellpatra.authservice.service.CustomUserDetailsService userDetailsService,
            PasswordEncoder passwordEncoder) {
        DaoAuthenticationProvider provider = new DaoAuthenticationProvider();
        provider.setUserDetailsService(userDetailsService);
        provider.setPasswordEncoder(passwordEncoder);
        return provider;
    }
}
