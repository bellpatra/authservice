package com.josam.authservice.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import java.util.concurrent.CompletableFuture;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;

@RestController
@RequestMapping("/api/health")
public class HealthController {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired(required = false)
    private RedisTemplate<String, Object> redisTemplate;

    @Autowired(required = false)
    private KafkaTemplate<String, String> kafkaTemplate;

    @GetMapping
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> health = new HashMap<>();
        health.put("status", "UP");
        health.put("timestamp", LocalDateTime.now().toString());
        health.put("service", "Auth Service");
        health.put("version", "1.0.0");
        
        // Check infrastructure services
        Map<String, Object> infrastructure = new HashMap<>();
        infrastructure.put("postgresql", checkPostgreSQL());
        infrastructure.put("redis", checkRedis());
        infrastructure.put("kafka", checkKafka());
        
        health.put("infrastructure", infrastructure);
        
        return ResponseEntity.ok(health);
    }

    @GetMapping("/infrastructure")
    public ResponseEntity<Map<String, Object>> infrastructureHealth() {
        Map<String, Object> infrastructure = new HashMap<>();
        infrastructure.put("postgresql", checkPostgreSQL());
        infrastructure.put("redis", checkRedis());
        infrastructure.put("kafka", checkKafka());
        
        return ResponseEntity.ok(infrastructure);
    }

    private Map<String, Object> checkPostgreSQL() {
        Map<String, Object> status = new HashMap<>();
        try {
            jdbcTemplate.queryForObject("SELECT 1", Integer.class);
            status.put("status", "UP");
            status.put("message", "Connected successfully");
            status.put("timestamp", LocalDateTime.now().toString());
        } catch (Exception e) {
            status.put("status", "DOWN");
            status.put("message", "Connection failed: " + e.getMessage());
            status.put("timestamp", LocalDateTime.now().toString());
        }
        return status;
    }

    private Map<String, Object> checkRedis() {
        Map<String, Object> status = new HashMap<>();
        if (redisTemplate == null) {
            status.put("status", "DISABLED");
            status.put("message", "Redis not configured");
            status.put("timestamp", LocalDateTime.now().toString());
            return status;
        }
        
        try {
            redisTemplate.opsForValue().set("health_check", "test", 10, TimeUnit.SECONDS);
            String result = (String) redisTemplate.opsForValue().get("health_check");
            if ("test".equals(result)) {
                status.put("status", "UP");
                status.put("message", "Connected successfully");
            } else {
                status.put("status", "DOWN");
                status.put("message", "Read/write test failed");
            }
            status.put("timestamp", LocalDateTime.now().toString());
        } catch (Exception e) {
            status.put("status", "DOWN");
            status.put("message", "Connection failed: " + e.getMessage());
            status.put("timestamp", LocalDateTime.now().toString());
            }
        return status;
    }

    private Map<String, Object> checkKafka() {
        Map<String, Object> status = new HashMap<>();
        if (kafkaTemplate == null) {
            status.put("status", "DISABLED");
            status.put("message", "Kafka not configured");
            status.put("timestamp", LocalDateTime.now().toString());
            return status;
        }
        
        try {
            // Try to send a test message to a test topic
            CompletableFuture<SendResult<String, String>> future = kafkaTemplate.send("health-check-topic", "test-message");
            // Wait for a short time to see if it succeeds
            SendResult<String, String> result = future.get(2, TimeUnit.SECONDS);
            status.put("status", "UP");
            status.put("message", "Connected successfully");
            status.put("timestamp", LocalDateTime.now().toString());
        } catch (Exception e) {
            status.put("status", "DOWN");
            status.put("message", "Connection failed: " + e.getMessage());
            status.put("timestamp", LocalDateTime.now().toString());
        }
        return status;
    }
}
