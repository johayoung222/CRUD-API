package com.example.crudapi.repository.jpa;

import com.example.crudapi.entity.Product;
import com.example.crudapi.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * JPA 기반 Product Repository 구현체
 */
@Repository
@ConditionalOnProperty(name = "app.data-access.type", havingValue = "JPA", matchIfMissing = true)
public class ProductRepositoryJpaImpl implements ProductRepository {

    private final ProductJpaRepository jpaRepository;

    @Autowired
    public ProductRepositoryJpaImpl(ProductJpaRepository jpaRepository) {
        this.jpaRepository = jpaRepository;
    }

    @Override
    public List<Product> findAll() {
        return jpaRepository.findAll();
    }

    @Override
    public Optional<Product> findById(Long id) {
        return jpaRepository.findById(id);
    }

    @Override
    public List<Product> findByNameContainingIgnoreCase(String name) {
        return jpaRepository.findByNameContainingIgnoreCase(name);
    }

    @Override
    public Product save(Product product) {
        return jpaRepository.save(product);
    }

    @Override
    public void delete(Product product) {
        jpaRepository.delete(product);
    }
}
