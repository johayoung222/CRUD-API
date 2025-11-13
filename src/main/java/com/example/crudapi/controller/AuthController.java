package com.example.crudapi.controller;

import com.example.crudapi.dto.LoginRequest;
import com.example.crudapi.dto.LoginResponse;
import com.example.crudapi.service.RedisAuthService;
import com.example.crudapi.service.SessionAuthService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final SessionAuthService sessionAuthService;
    private final RedisAuthService redisAuthService;

    // ========================================
    // 세션 기반 인증 API
    // ========================================

    /**
     * 세션 기반 로그인
     */
    @PostMapping("/session/login")
    public ResponseEntity<LoginResponse> sessionLogin(
            @Valid @RequestBody LoginRequest request,
            HttpServletRequest httpRequest) {
        log.info("Session login request for user: {}", request.getUsername());
        LoginResponse response = sessionAuthService.login(request, httpRequest);
        return ResponseEntity.ok(response);
    }

    /**
     * 세션 기반 로그아웃
     */
    @PostMapping("/session/logout")
    public ResponseEntity<Map<String, String>> sessionLogout(HttpServletRequest httpRequest) {
        log.info("Session logout request");
        sessionAuthService.logout(httpRequest);
        return ResponseEntity.ok(Map.of("message", "Logout successful"));
    }

    /**
     * 세션 기반 현재 사용자 정보 조회
     */
    @GetMapping("/session/me")
    public ResponseEntity<?> sessionCurrentUser(HttpServletRequest httpRequest) {
        LoginResponse.UserInfo userInfo = sessionAuthService.getCurrentUser(httpRequest);
        if (userInfo == null) {
            return ResponseEntity.status(401).body(Map.of("message", "Not authenticated"));
        }
        return ResponseEntity.ok(userInfo);
    }

    /**
     * 세션 기반 인증 확인
     */
    @GetMapping("/session/check")
    public ResponseEntity<Map<String, Boolean>> sessionCheck(HttpServletRequest httpRequest) {
        boolean authenticated = sessionAuthService.isAuthenticated(httpRequest);
        return ResponseEntity.ok(Map.of("authenticated", authenticated));
    }

    // ========================================
    // Redis 기반 인증 API
    // ========================================

    /**
     * Redis 기반 로그인
     */
    @PostMapping("/redis/login")
    public ResponseEntity<LoginResponse> redisLogin(@Valid @RequestBody LoginRequest request) {
        log.info("Redis login request for user: {}", request.getUsername());
        LoginResponse response = redisAuthService.login(request);
        return ResponseEntity.ok(response);
    }

    /**
     * Redis 기반 로그아웃
     */
    @PostMapping("/redis/logout")
    public ResponseEntity<Map<String, String>> redisLogout(
            @RequestHeader(value = "X-Session-Token", required = false) String sessionToken) {
        log.info("Redis logout request");
        redisAuthService.logout(sessionToken);
        return ResponseEntity.ok(Map.of("message", "Logout successful"));
    }

    /**
     * Redis 기반 현재 사용자 정보 조회
     */
    @GetMapping("/redis/me")
    public ResponseEntity<?> redisCurrentUser(
            @RequestHeader(value = "X-Session-Token", required = false) String sessionToken) {
        LoginResponse.UserInfo userInfo = redisAuthService.getCurrentUser(sessionToken);
        if (userInfo == null) {
            return ResponseEntity.status(401).body(Map.of("message", "Not authenticated"));
        }
        return ResponseEntity.ok(userInfo);
    }

    /**
     * Redis 기반 인증 확인
     */
    @GetMapping("/redis/check")
    public ResponseEntity<Map<String, Boolean>> redisCheck(
            @RequestHeader(value = "X-Session-Token", required = false) String sessionToken) {
        boolean authenticated = redisAuthService.isAuthenticated(sessionToken);
        return ResponseEntity.ok(Map.of("authenticated", authenticated));
    }

    /**
     * Redis 세션 연장
     */
    @PostMapping("/redis/extend")
    public ResponseEntity<Map<String, Object>> redisExtendSession(
            @RequestHeader(value = "X-Session-Token", required = false) String sessionToken) {
        boolean extended = redisAuthService.extendSession(sessionToken);
        return ResponseEntity.ok(Map.of(
                "success", extended,
                "message", extended ? "Session extended" : "Session not found or expired"
        ));
    }

    // ========================================
    // 공통 API
    // ========================================

    /**
     * Health Check
     */
    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> health() {
        return ResponseEntity.ok(Map.of(
                "status", "UP",
                "service", "Auth Service"
        ));
    }
}
