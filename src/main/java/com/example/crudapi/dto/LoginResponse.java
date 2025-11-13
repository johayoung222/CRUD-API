package com.example.crudapi.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class LoginResponse {

    private boolean success;
    private String message;
    private String sessionId;
    private UserInfo userInfo;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class UserInfo {
        private Long id;
        private String username;
        private String email;
        private String name;
    }

    public static LoginResponse success(String sessionId, UserInfo userInfo) {
        return new LoginResponse(true, "Login successful", sessionId, userInfo);
    }

    public static LoginResponse failure(String message) {
        return new LoginResponse(false, message, null, null);
    }
}
