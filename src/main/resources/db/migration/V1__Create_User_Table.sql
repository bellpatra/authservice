-- Migration V1: Create User Table with UUID primary keys
-- This migration creates the complete users table structure

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create User table for authentication service
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    phone_number VARCHAR(20),
    date_of_birth VARCHAR(20),
    gender VARCHAR(10),
    profile_picture TEXT,
    email_verified BOOLEAN DEFAULT false,
    phone_verified BOOLEAN DEFAULT false,
    two_factor_enabled BOOLEAN DEFAULT false,
    two_factor_secret VARCHAR(255),
    marketing_consent BOOLEAN DEFAULT false,
    terms_accepted BOOLEAN DEFAULT false,
    referral_code VARCHAR(50),
    preferred_language VARCHAR(10) DEFAULT 'en',
    timezone VARCHAR(50) DEFAULT 'UTC',
    enabled BOOLEAN DEFAULT true,
    account_non_expired BOOLEAN DEFAULT true,
    account_non_locked BOOLEAN DEFAULT true,
    credentials_non_expired BOOLEAN DEFAULT true,
    last_login TIMESTAMP,
    last_password_change TIMESTAMP,
    failed_login_attempts INTEGER DEFAULT 0,
    account_locked_until TIMESTAMP,
    password_reset_token VARCHAR(255),
    password_reset_expires TIMESTAMP,
    email_verification_token VARCHAR(255),
    email_verification_expires TIMESTAMP,
    deleted BOOLEAN DEFAULT false,
    deleted_at TIMESTAMP,
    deleted_by UUID,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create audit table for user actions
CREATE TABLE user_audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    action VARCHAR(50) NOT NULL,
    details TEXT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone_number ON users(phone_number);
CREATE INDEX idx_users_email_verified ON users(email_verified);
CREATE INDEX idx_users_phone_verified ON users(phone_verified);
CREATE INDEX idx_users_two_factor_enabled ON users(two_factor_enabled);
CREATE INDEX idx_users_marketing_consent ON users(marketing_consent);
CREATE INDEX idx_users_terms_accepted ON users(terms_accepted);
CREATE INDEX idx_users_referral_code ON users(referral_code);
CREATE INDEX idx_users_preferred_language ON users(preferred_language);
CREATE INDEX idx_users_timezone ON users(timezone);
CREATE INDEX idx_users_last_login ON users(last_login);
CREATE INDEX idx_users_last_password_change ON users(last_password_change);
CREATE INDEX idx_users_failed_login_attempts ON users(failed_login_attempts);
CREATE INDEX idx_users_account_locked_until ON users(account_locked_until);
CREATE INDEX idx_users_password_reset_token ON users(password_reset_token);
CREATE INDEX idx_users_email_verification_token ON users(email_verification_token);
CREATE INDEX idx_users_deleted ON users(deleted);
CREATE INDEX idx_users_deleted_at ON users(deleted_at);
CREATE INDEX idx_users_created_at ON users(created_at);
CREATE INDEX idx_users_updated_at ON users(updated_at);

-- Create indexes for audit log
CREATE INDEX idx_user_audit_log_user_id ON user_audit_log(user_id);
CREATE INDEX idx_user_audit_log_created_at ON user_audit_log(created_at);
CREATE INDEX idx_user_audit_log_action ON user_audit_log(action);

-- Add comments for documentation
COMMENT ON TABLE users IS 'User accounts for authentication service';
COMMENT ON TABLE user_audit_log IS 'Audit trail for user actions and security events';
COMMENT ON COLUMN users.id IS 'Unique identifier for the user';
COMMENT ON COLUMN users.username IS 'Unique username for login';
COMMENT ON COLUMN users.email IS 'Unique email address for login and communication';
COMMENT ON COLUMN users.password IS 'Hashed password for authentication';
COMMENT ON COLUMN users.two_factor_secret IS 'Secret key for 2FA authentication';
COMMENT ON COLUMN users.referral_code IS 'Referral code for user acquisition tracking';
COMMENT ON COLUMN users.deleted IS 'Soft delete flag';
COMMENT ON COLUMN users.deleted_by IS 'User who performed the deletion';
