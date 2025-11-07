package com.example.crudapi.repository;

import com.example.crudapi.entity.Product;

import java.util.List;
import java.util.Optional;

/**
 * Product \uc800\uc7a5\uc18c \uacf5\ud1b5 \uc778\ud130\ud398\uc774\uc2a4
 * JPA \ub610\ub294 MyBatis \uad6c\ud604\uccb4\uac00 \uc774 \uc778\ud130\ud398\uc774\uc2a4\ub97c \uad6c\ud604\ud569\ub2c8\ub2e4.
 */
public interface ProductRepository {

    /**
     * \ubaa8\ub4e0 \uc0c1\ud488 \uc870\ud68c
     */
    List<Product> findAll();

    /**
     * ID\ub85c \uc0c1\ud488 \uc870\ud68c
     */
    Optional<Product> findById(Long id);

    /**
     * \uc774\ub984\uc73c\ub85c \uc0c1\ud488 \uac80\uc0c9 (\ub300\uc18c\ubb38\uc790 \ubb34\uc2dc, \ubd80\ubd84 \uc77c\uce58)
     */
    List<Product> findByNameContainingIgnoreCase(String name);

    /**
     * \uc0c1\ud488 \uc800\uc7a5
     */
    Product save(Product product);

    /**
     * \uc0c1\ud488 \uc0ad\uc81c
     */
    void delete(Product product);
}
