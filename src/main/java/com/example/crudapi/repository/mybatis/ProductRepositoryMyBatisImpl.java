package com.example.crudapi.repository.mybatis;

import com.example.crudapi.entity.Product;
import com.example.crudapi.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * MyBatis 기반 Product Repository 구현체
 */
@Repository
@ConditionalOnProperty(name = "app.data-access.type", havingValue = "MYBATIS")
public class ProductRepositoryMyBatisImpl implements ProductRepository {

    private final ProductMapper productMapper;

    @Autowired
    public ProductRepositoryMyBatisImpl(ProductMapper productMapper) {
        this.productMapper = productMapper;
    }

    @Override
    public List<Product> findAll() {
        return productMapper.findAll();
    }

    @Override
    public Optional<Product> findById(Long id) {
        Product product = productMapper.findById(id);
        return Optional.ofNullable(product);
    }

    @Override
    public List<Product> findByNameContainingIgnoreCase(String name) {
        return productMapper.findByNameContainingIgnoreCase(name);
    }

    @Override
    public Product save(Product product) {
        if (product.getId() == null) {
            // Insert
            product.setCreatedAt(LocalDateTime.now());
            product.setUpdatedAt(LocalDateTime.now());
            productMapper.insert(product);
        } else {
            // Update
            product.setUpdatedAt(LocalDateTime.now());
            productMapper.update(product);
        }
        return product;
    }

    @Override
    public void delete(Product product) {
        productMapper.delete(product.getId());
    }
}
