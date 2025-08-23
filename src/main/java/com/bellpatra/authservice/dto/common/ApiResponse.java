package com.bellpatra.authservice.dto.common;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Standardized API Response Wrapper
 * 
 * Generic response wrapper that provides consistent structure for all API responses
 * throughout the authentication microservice. This ensures uniform client experience
 * and predictable response handling.
 * 
 * Response Structure:
 * {
 *   "status": "success" | "error",
 *   "statusCode": HTTP_STATUS_CODE,
 *   "data": RESPONSE_PAYLOAD,
 *   "message": "Human readable message",
 *   "meta": {
 *     "timestamp": "2024-08-24T12:00:00",
 *     "fileName": "ControllerName.java",
 *     "functionName": "methodName"
 *   }
 * }
 * 
 * Features:
 * - Generic type support for any response data
 * - Consistent status indication (success/error)
 * - HTTP status code inclusion
 * - Human-readable messages
 * - Metadata for debugging and tracing
 * - Null field exclusion from JSON serialization
 * 
 * Usage:
 * - Success: ApiResponse.success(data, message, fileName, functionName)
 * - Error: ApiResponse.error(message, statusCode, fileName, functionName)
 * 
 * @param <T> Type of the response data payload
 * @author Bellpatra Team
 * @version 1.0.0
 * @since 2024-08-24
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ApiResponse<T> {

    /**
     * Response status indicator
     * Values: "success" for successful operations, "error" for failed operations
     */
    private String status;
    
    /**
     * HTTP status code
     * Standard HTTP status codes (200, 201, 400, 401, 404, 500, etc.)
     */
    private Integer statusCode;
    
    /**
     * Response payload data
     * Generic type allows for any response data structure
     */
    private T data;
    
    /**
     * Human-readable response message
     * Provides context about the operation result
     */
    private String message;
    
    /**
     * Response metadata for debugging and tracing
     */
    private MetaInfo meta;

    /**
     * Metadata Information for API Response
     * 
     * Contains additional information about the API response for debugging,
     * logging, and tracing purposes. This helps with troubleshooting and
     * monitoring API usage patterns.
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonInclude(JsonInclude.Include.NON_NULL)
    public static class MetaInfo {
        
        /**
         * Timestamp when the response was generated
         * Automatically set to current time when creating responses
         */
        private LocalDateTime timestamp;
        
        /**
         * Source file name where the response was generated
         * Helps identify the controller or service that handled the request
         */
        private String fileName;
        
        /**
         * Function/method name that generated the response
         * Provides specific context about which operation was performed
         */
        private String functionName;
    }

    /**
     * Create a successful API response with metadata
     * 
     * Factory method for creating standardized success responses with
     * data payload, message, and debugging metadata.
     * 
     * @param data Response data payload
     * @param message Success message
     * @param fileName Source file name
     * @param functionName Source function name
     * @param <T> Type of response data
     * @return ApiResponse with success status and 200 status code
     */
    public static <T> ApiResponse<T> success(T data, String message, String fileName, String functionName) {
        return ApiResponse.<T>builder()
                .status("success")
                .statusCode(200)
                .data(data)
                .message(message)
                .meta(MetaInfo.builder()
                        .timestamp(LocalDateTime.now())
                        .fileName(fileName)
                        .functionName(functionName)
                        .build())
                .build();
    }

    /**
     * Create a successful API response without metadata
     * 
     * Simplified factory method for success responses when metadata
     * is not required or available.
     * 
     * @param data Response data payload
     * @param message Success message
     * @param <T> Type of response data
     * @return ApiResponse with success status and 200 status code
     */
    public static <T> ApiResponse<T> success(T data, String message) {
        return success(data, message, null, null);
    }

    /**
     * Create an error API response with metadata
     * 
     * Factory method for creating standardized error responses with
     * error message, status code, and debugging metadata.
     * 
     * @param message Error message
     * @param statusCode HTTP status code (400, 401, 404, 500, etc.)
     * @param fileName Source file name
     * @param functionName Source function name
     * @param <T> Type of response data (usually Void for errors)
     * @return ApiResponse with error status and specified status code
     */
    public static <T> ApiResponse<T> error(String message, Integer statusCode, String fileName, String functionName) {
        return ApiResponse.<T>builder()
                .status("error")
                .statusCode(statusCode)
                .message(message)
                .meta(MetaInfo.builder()
                        .timestamp(LocalDateTime.now())
                        .fileName(fileName)
                        .functionName(functionName)
                        .build())
                .build();
    }

    /**
     * Create an error API response without metadata
     * 
     * Simplified factory method for error responses when metadata
     * is not required or available.
     * 
     * @param message Error message
     * @param statusCode HTTP status code
     * @param <T> Type of response data (usually Void for errors)
     * @return ApiResponse with error status and specified status code
     */
    public static <T> ApiResponse<T> error(String message, Integer statusCode) {
        return error(message, statusCode, null, null);
    }
}
