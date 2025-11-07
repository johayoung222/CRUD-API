package com.example.crudapi.repository.mybatis;

import com.example.crudapi.entity.Product;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * MyBatis Product Mapper 인터페이스
 */
@Mapper
public interface ProductMapper {

    /**
     * 모든 상품 조회
     */
    List<Product> findAll();

    /**
     * ID로 상품 조회
     */
    Product findById(@Param("id") Long id);

    /**
     * 이름으로 상품 검색 (대소문자 무시, 부분 일치)
     */
    List<Product> findByNameContainingIgnoreCase(@Param("name") String name);

    /**
     * 상품 삽입
     */
    void insert(Product product);

    /**
     * 상품 업데이트
     */
    void update(Product product);

    /**
     * 상품 삭제
     */
    void delete(@Param("id") Long id);
}
