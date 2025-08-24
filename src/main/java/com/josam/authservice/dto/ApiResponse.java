package com.josam.authservice.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * Standard API Response Structure
 * Provides a consistent response format across all API endpoints
 * Supports localization for messages
 * 
 * @author Josam Team
 * @version 1.0.0
 * @since 2024-08-23
 * 
 * @param <T> Type of data payload
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ApiResponse<T> {
    
    /**
     * Response status (success, error, warning, info)
     */
    @JsonProperty("status")
    private String status;
    
    /**
     * HTTP status code
     */
    @JsonProperty("statusCode")
    private Integer statusCode;
    
    /**
     * Localized message for the response
     * This is the actual message in the user's language
     */
    @JsonProperty("message")
    private String message;
    
    /**
     * Message key for localization
     * Used to identify which message to display in different languages
     */
    @JsonProperty("messageKey")
    private String messageKey;
    
    /**
     * Response data payload
     */
    @JsonProperty("data")
    private T data;
    
    /**
     * Additional metadata about the response
     */
    @JsonProperty("meta")
    private MetaData meta;
    
    /**
     * Timestamp when the response was generated
     */
    @JsonProperty("timestamp")
    private LocalDateTime timestamp;
    
    /**
     * Localized messages in multiple languages
     * Key: language code (e.g., "en", "hi", "es")
     * Value: message in that language
     */
    @JsonProperty("localizedMessages")
    private Map<String, String> localizedMessages;
    
    /**
     * Validation errors if any
     * Used for form validation responses
     */
    @JsonProperty("errors")
    private List<ValidationError> errors;
    
    /**
     * Metadata class containing additional response information
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonInclude(JsonInclude.Include.NON_NULL)
    public static class MetaData {
        
        /**
         * Pagination information
         */
        @JsonProperty("pagination")
        private Pagination pagination;
        
        /**
         * Request processing time in milliseconds
         */
        @JsonProperty("processingTime")
        private Long processingTime;
        
        /**
         * Unique request identifier for tracking
         */
        @JsonProperty("requestId")
        private String requestId;
        
        /**
         * Additional metadata fields
         */
        @JsonProperty("additional")
        private Map<String, Object> additional;
        
        /**
         * API version information
         */
        @JsonProperty("apiVersion")
        private String apiVersion;
        
        /**
         * Server information
         */
        @JsonProperty("serverInfo")
        private ServerInfo serverInfo;
    }
    
    /**
     * Pagination information for paginated responses
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonInclude(JsonInclude.Include.NON_NULL)
    public static class Pagination {
        
        /**
         * Current page number
         */
        @JsonProperty("page")
        private Integer page;
        
        /**
         * Number of items per page
         */
        @JsonProperty("size")
        private Integer size;
        
        /**
         * Total number of items
         */
        @JsonProperty("total")
        private Long total;
        
        /**
         * Total number of pages
         */
        @JsonProperty("totalPages")
        private Integer totalPages;
        
        /**
         * Whether there is a next page
         */
        @JsonProperty("hasNext")
        private Boolean hasNext;
        
        /**
         * Whether there is a previous page
         */
        @JsonProperty("hasPrevious")
        private Boolean hasPrevious;
    }
    
    /**
     * Validation error details
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonInclude(JsonInclude.Include.NON_NULL)
    public static class ValidationError {
        
        /**
         * Field name that has validation error
         */
        @JsonProperty("field")
        private String field;
        
        /**
         * Error message key for localization
         */
        @JsonProperty("messageKey")
        private String messageKey;
        
        /**
         * Localized error message
         */
        @JsonProperty("message")
        private String message;
        
        /**
         * Error code for programmatic handling
         */
        @JsonProperty("code")
        private String code;
        
        /**
         * Rejected value that caused the error
         */
        @JsonProperty("rejectedValue")
        private Object rejectedValue;
    }
    
    /**
     * Server information
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonInclude(JsonInclude.Include.NON_NULL)
    public static class ServerInfo {
        
        /**
         * Server name
         */
        @JsonProperty("name")
        private String name;
        
        /**
         * Server version
         */
        @JsonProperty("version")
        private String version;
        
        /**
         * Environment (dev, staging, prod)
         */
        @JsonProperty("environment")
        private String environment;
        
        /**
         * Server timestamp
         */
        @JsonProperty("timestamp")
        private LocalDateTime timestamp;
    }
    
    // Static helper methods for creating responses
    
    /**
     * Create a success response
     * 
     * @param data Response data
     * @param messageKey Message key for localization
     * @param message Default message (usually in English)
     * @param <T> Type of data
     * @return ApiResponse with success status
     */
    public static <T> ApiResponse<T> success(T data, String messageKey, String message) {
        return ApiResponse.<T>builder()
                .status("success")
                .statusCode(200)
                .messageKey(messageKey)
                .message(message)
                .data(data)
                .timestamp(LocalDateTime.now())
                .build();
    }
    
    /**
     * Create a success response with localized messages
     * 
     * @param data Response data
     * @param messageKey Message key for localization
     * @param localizedMessages Map of language codes to localized messages
     * @param <T> Type of data
     * @return ApiResponse with success status and localization
     */
    public static <T> ApiResponse<T> success(T data, String messageKey, Map<String, String> localizedMessages) {
        return ApiResponse.<T>builder()
                .status("success")
                .statusCode(200)
                .messageKey(messageKey)
                .localizedMessages(localizedMessages)
                .data(data)
                .timestamp(LocalDateTime.now())
                .build();
    }
    
    /**
     * Create an error response
     * 
     * @param statusCode HTTP status code
     * @param messageKey Message key for localization
     * @param message Default error message
     * @param <T> Type of data
     * @return ApiResponse with error status
     */
    public static <T> ApiResponse<T> error(Integer statusCode, String messageKey, String message) {
        return ApiResponse.<T>builder()
                .status("error")
                .statusCode(statusCode)
                .messageKey(messageKey)
                .message(message)
                .timestamp(LocalDateTime.now())
                .build();
    }
    
    /**
     * Create an error response with localized messages
     * 
     * @param statusCode HTTP status code
     * @param messageKey Message key for localization
     * @param localizedMessages Map of language codes to localized error messages
     * @param <T> Type of data
     * @return ApiResponse with error status and localization
     */
    public static <T> ApiResponse<T> error(Integer statusCode, String messageKey, Map<String, String> localizedMessages) {
        return ApiResponse.<T>builder()
                .status("error")
                .statusCode(statusCode)
                .messageKey(messageKey)
                .localizedMessages(localizedMessages)
                .timestamp(LocalDateTime.now())
                .build();
    }
    
    /**
     * Create a warning response
     * 
     * @param messageKey Message key for localization
     * @param message Default warning message
     * @param <T> Type of data
     * @return ApiResponse with warning status
     */
    public static <T> ApiResponse<T> warning(String messageKey, String message) {
        return ApiResponse.<T>builder()
                .status("warning")
                .statusCode(200)
                .messageKey(messageKey)
                .message(message)
                .timestamp(LocalDateTime.now())
                .build();
    }
    
    /**
     * Create an info response
     * 
     * @param messageKey Message key for localization
     * @param message Default info message
     * @param <T> Type of data
     * @return ApiResponse with info status
     */
    public static <T> ApiResponse<T> info(String messageKey, String message) {
        return ApiResponse.<T>builder()
                .status("info")
                .statusCode(200)
                .messageKey(messageKey)
                .message(message)
                .timestamp(LocalDateTime.now())
                .build();
    }
    
    /**
     * Create a validation error response
     * 
     * @param errors List of validation errors
     * @param messageKey Message key for localization
     * @param message Default validation message
     * @param <T> Type of data
     * @return ApiResponse with validation errors
     */
    public static <T> ApiResponse<T> validationError(List<ValidationError> errors, String messageKey, String message) {
        return ApiResponse.<T>builder()
                .status("error")
                .statusCode(400)
                .messageKey(messageKey)
                .message(message)
                .errors(errors)
                .timestamp(LocalDateTime.now())
                .build();
    }
    
    /**
     * Create a paginated response
     * 
     * @param data Response data
     * @param pagination Pagination information
     * @param messageKey Message key for localization
     * @param message Default message
     * @param <T> Type of data
     * @return ApiResponse with pagination metadata
     */
    public static <T> ApiResponse<T> paginated(T data, Pagination pagination, String messageKey, String message) {
        MetaData meta = MetaData.builder()
                .pagination(pagination)
                .build();
        
        return ApiResponse.<T>builder()
                .status("success")
                .statusCode(200)
                .messageKey(messageKey)
                .message(message)
                .data(data)
                .meta(meta)
                .timestamp(LocalDateTime.now())
                .build();
    }
}
