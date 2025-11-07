package com.example.crudapi.config;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Configuration;

/**
 * 데이터 액세스 계층 설정
 */
@Configuration
public class DataAccessConfiguration {

    /**
     * MyBatis 설정
     */
    @Configuration
    @ConditionalOnProperty(name = "app.data-access.type", havingValue = "MYBATIS")
    @MapperScan("com.example.crudapi.repository.mybatis")
    public static class MyBatisConfiguration {
        // MyBatis Mapper 스캔 설정
    }

    /**
     * JPA 설정
     */
    @Configuration
    @ConditionalOnProperty(name = "app.data-access.type", havingValue = "JPA", matchIfMissing = true)
    public static class JpaConfiguration {
        // JPA 설정 (필요시 추가)
    }
}
