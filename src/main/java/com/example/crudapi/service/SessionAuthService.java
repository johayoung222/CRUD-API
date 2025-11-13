package com.example.crudapi.service;

import com.example.crudapi.dto.LoginRequest;
import com.example.crudapi.dto.LoginResponse;
import com.example.crudapi.entity.User;
import com.example.crudapi.repository.UserRepository;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class SessionAuthService {

    private static final String USER_SESSION_KEY = "USER_SESSION";

    private final UserRepository userRepository;

    /**
     * 세션 기반 로그인
     */
    public LoginResponse login(LoginRequest request, HttpServletRequest httpRequest) {
        log.info("Session-based login attempt for user: {}", request.getUsername());

        // 사용자 조회
        User user = userRepository.findByUsername(request.getUsername())
                .orElse(null);

        // 인증 실패
        if (user == null || !user.getPassword().equals(request.getPassword())) {
            log.warn("Login failed for user: {}", request.getUsername());
            return LoginResponse.failure("Invalid username or password");
        }

        // 세션 생성
        HttpSession session = httpRequest.getSession(true);
        session.setAttribute(USER_SESSION_KEY, user.getId());

        log.info("Login successful for user: {}, session ID: {}", user.getUsername(), session.getId());

        // 응답 생성
        LoginResponse.UserInfo userInfo = new LoginResponse.UserInfo(
                user.getId(),
                user.getUsername(),
                user.getEmail(),
                user.getName()
        );

        return LoginResponse.success(session.getId(), userInfo);
    }

    /**
     * 로그아웃
     */
    public void logout(HttpServletRequest httpRequest) {
        HttpSession session = httpRequest.getSession(false);
        if (session != null) {
            log.info("Logout for session ID: {}", session.getId());
            session.invalidate();
        }
    }

    /**
     * 현재 로그인한 사용자 정보 조회
     */
    public LoginResponse.UserInfo getCurrentUser(HttpServletRequest httpRequest) {
        HttpSession session = httpRequest.getSession(false);
        if (session == null) {
            return null;
        }

        Long userId = (Long) session.getAttribute(USER_SESSION_KEY);
        if (userId == null) {
            return null;
        }

        User user = userRepository.findById(userId).orElse(null);
        if (user == null) {
            return null;
        }

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
    public boolean isAuthenticated(HttpServletRequest httpRequest) {
        return getCurrentUser(httpRequest) != null;
    }
}
