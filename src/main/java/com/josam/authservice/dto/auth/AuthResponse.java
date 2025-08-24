package com.josam.authservice.dto.auth;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponse {

    private String token;

    private String refreshToken;

    private Long expiresIn;

    private String tokenType = "Bearer";

    private UUID userId;

    private String email;

    private String username;

    private String fullName;

    private String[] roles;

    private LocalDateTime issuedAt;

    private LocalDateTime expiresAt;

    private Boolean emailVerified;

    private Boolean phoneVerified;
}
