-- ================================================================================
-- PostgreSQL Docker 환경 설정 스크립트
-- ================================================================================
-- 실행 방법:
-- docker exec -i postgres psql -U postgres < setup-postgresql-docker.sql
-- ================================================================================

-- 1. 데이터베이스 생성
CREATE DATABASE cruddb;

-- 2. 사용자 생성
CREATE USER cruduser WITH PASSWORD 'crudpass123';

-- 3. 데이터베이스 권한 부여
GRANT ALL PRIVILEGES ON DATABASE cruddb TO cruduser;

-- cruddb로 연결
\c cruddb

-- 4. 스키마 권한 부여
GRANT ALL ON SCHEMA public TO cruduser;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO cruduser;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO cruduser;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO cruduser;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO cruduser;

-- 5. products 테이블 생성
CREATE TABLE IF NOT EXISTS products (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DOUBLE PRECISION NOT NULL,
    quantity INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. users 테이블 생성
CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100),
    name VARCHAR(50),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 7. 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_products_name ON products(name);
CREATE INDEX IF NOT EXISTS idx_products_created_at ON products(created_at);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);

-- 8. 테이블 소유자 변경
ALTER TABLE products OWNER TO cruduser;
ALTER TABLE users OWNER TO cruduser;

-- 9. 시퀀스 소유자 변경
ALTER SEQUENCE products_id_seq OWNER TO cruduser;
ALTER SEQUENCE users_id_seq OWNER TO cruduser;

-- 10. products 샘플 데이터 삽입
INSERT INTO products (name, description, price, quantity, created_at, updated_at) VALUES
('노트북', '고성능 노트북', 1500000.00, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('마우스', '무선 마우스', 35000.00, 50, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('키보드', '기계식 키보드', 120000.00, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('모니터', '27인치 4K 모니터', 450000.00, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('헤드셋', '게이밍 헤드셋', 89000.00, 25, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT DO NOTHING;

-- 11. users 샘플 데이터 삽입
INSERT INTO users (username, password, email, name, created_at, updated_at) VALUES
('admin', 'admin123', 'admin@example.com', '관리자', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('testuser', 'test123', 'test@example.com', '테스트유저', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('demo', 'demo123', 'demo@example.com', '데모', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT DO NOTHING;

-- 12. 생성 확인
\dt
SELECT 'Products count:' AS info, COUNT(*) AS count FROM products;
SELECT 'Users count:' AS info, COUNT(*) AS count FROM users;

-- 완료 메시지
SELECT '========================================' AS message;
SELECT 'PostgreSQL 설정 완료!' AS message;
SELECT '========================================' AS message;
SELECT 'Database: cruddb' AS info;
SELECT 'User: cruduser' AS info;
SELECT 'Password: crudpass123' AS info;
