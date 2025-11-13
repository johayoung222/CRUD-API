package com.example.crudapi.service;

import com.example.crudapi.dto.LoginRequest;
import com.example.crudapi.dto.LoginResponse;
import com.example.crudapi.entity.User;
import com.example.crudapi.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.util.UUID;
import java.util.concurrent.TimeUnit;

@Slf4j
@Service
@RequiredArgsConstructor
public class RedisAuthService {

    private static final String SESSION_PREFIX = "session:";
    private static final long SESSION_TIMEOUT_MINUTES = 30;

    private final UserRepository userRepository;
    private final RedisTemplate<String, Object> redisTemplate;

    /**
     * Redis 기반 로그인
     */
    public LoginResponse login(LoginRequest request) {
        log.info("Redis-based login attempt for user: {}", request.getUsername());

        // 사용자 조회
        User user = userRepository.findByUsername(request.getUsername())
                .orElse(null);

        // 인증 실패
        if (user == null || !user.getPassword().equals(request.getPassword())) {
            log.warn("Login failed for user: {}", request.getUsername());
            return LoginResponse.failure("Invalid username or password");
        }

        // 세션 토큰 생성
        String sessionToken = UUID.randomUUID().toString();
        String sessionKey = SESSION_PREFIX + sessionToken;

        // Redis에 사용자 정보 저장 (30분 TTL)
        redisTemplate.opsForValue().set(sessionKey, user.getId(), SESSION_TIMEOUT_MINUTES, TimeUnit.MINUTES);

        log.info("Login successful for user: {}, session token: {}", user.getUsername(), sessionToken);

        // 응답 생성
        LoginResponse.UserInfo userInfo = new LoginResponse.UserInfo(
                user.getId(),
                user.getUsername(),
                user.getEmail(),
                user.getName()
        );

        return LoginResponse.success(sessionToken, userInfo);
    }

    /**
     * 로그아웃 (Redis 세션 삭제)
     */
    public void logout(String sessionToken) {
        if (sessionToken != null && !sessionToken.isEmpty()) {
            String sessionKey = SESSION_PREFIX + sessionToken;
            redisTemplate.delete(sessionKey);
            log.info("Logout for session token: {}", sessionToken);
        }
    }

    /**
     * 세션 토큰으로 사용자 정보 조회
     */
    public LoginResponse.UserInfo getCurrentUser(String sessionToken) {
        if (sessionToken == null || sessionToken.isEmpty()) {
            return null;
        }

        String sessionKey = SESSION_PREFIX + sessionToken;
        Object userIdObj = redisTemplate.opsForValue().get(sessionKey);

        if (userIdObj == null) {
            log.debug("Session not found or expired: {}", sessionToken);
            return null;
        }

        Long userId;
        if (userIdObj instanceof Integer) {
            userId = ((Integer) userIdObj).longValue();
        } else if (userIdObj instanceof Long) {
            userId = (Long) userIdObj;
        } else {
            log.warn("Invalid user ID type in Redis: {}", userIdObj.getClass());
            return null;
        }

        User user = userRepository.findById(userId).orElse(null);
        if (user == null) {
            log.warn("User not found for ID: {}", userId);
            return null;
        }

        // TTL 연장 (활동 시 세션 갱신)
        redisTemplate.expire(sessionKey, SESSION_TIMEOUT_MINUTES, TimeUnit.MINUTES);

        return new LoginResponse.UserInfo(
                user.getId(),
                user.getUsername(),
                user.getEmail(),
                user.getName()
        );
    }

    /**
     * 로그인 여부 확인
     */
    public boolean isAuthenticated(String sessionToken) {
        return getCurrentUser(sessionToken) != null;
    }

    /**
     * 세션 연장
     */
    public boolean extendSession(String sessionToken) {
        if (sessionToken == null || sessionToken.isEmpty()) {
            return false;
        }

        String sessionKey = SESSION_PREFIX + sessionToken;
        return Boolean.TRUE.equals(redisTemplate.expire(sessionKey, SESSION_TIMEOUT_MINUTES, TimeUnit.MINUTES));
    }
}
