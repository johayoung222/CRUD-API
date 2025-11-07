package com.example.crudapi.repository.jpa;

import com.example.crudapi.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

/**
 * JPA 기반 Product Repository
 */
public interface ProductJpaRepository extends JpaRepository<Product, Long> {

    List<Product> findByNameContainingIgnoreCase(String name);

}
