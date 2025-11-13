# 데이터베이스 설정 가이드

이 문서는 CRUD API 프로젝트에서 사용할 데이터베이스별 테이블 생성 스크립트를 제공합니다.

---

## 📋 테이블 구조

### products 테이블

| 컬럼명 | 데이터 타입 | 제약 조건 | 설명 |
|--------|------------|----------|------|
| id | BIGINT/NUMBER | PRIMARY KEY, AUTO_INCREMENT | 상품 ID (자동 증가) |
| name | VARCHAR(255) | NOT NULL | 상품명 |
| description | TEXT/CLOB | NULL | 상품 설명 |
| price | DOUBLE/NUMBER | NOT NULL | 가격 |
| quantity | INTEGER/NUMBER | NOT NULL | 수량 |
| created_at | TIMESTAMP/DATE | NOT NULL | 생성 일시 |
| updated_at | TIMESTAMP/DATE | NULL | 수정 일시 |

### users 테이블

| 컬럼명 | 데이터 타입 | 제약 조건 | 설명 |
|--------|------------|----------|------|
| id | BIGINT/NUMBER | PRIMARY KEY, AUTO_INCREMENT | 사용자 ID (자동 증가) |
| username | VARCHAR(50) | NOT NULL, UNIQUE | 사용자명 |
| password | VARCHAR(255) | NOT NULL | 비밀번호 |
| email | VARCHAR(100) | NULL | 이메일 |
| name | VARCHAR(50) | NULL | 이름 |
| created_at | TIMESTAMP/DATE | NOT NULL | 생성 일시 |
| updated_at | TIMESTAMP/DATE | NULL | 수정 일시 |

---

## 🗄️ 데이터베이스별 DDL 스크립트

### 1. PostgreSQL

```sql
-- products 테이블 생성
CREATE TABLE products (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DOUBLE PRECISION NOT NULL,
    quantity INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- users 테이블 생성
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100),
    name VARCHAR(50),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 인덱스 생성 (선택사항)
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_products_created_at ON products(created_at);
CREATE INDEX idx_users_username ON users(username);

-- products 샘플 데이터 삽입
INSERT INTO products (name, description, price, quantity, created_at, updated_at) VALUES
('노트북', '고성능 노트북', 1500000.00, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('마우스', '무선 마우스', 35000.00, 50, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('키보드', '기계식 키보드', 120000.00, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- users 샘플 데이터 삽입 (비밀번호는 실제로는 암호화해야 함)
INSERT INTO users (username, password, email, name, created_at, updated_at) VALUES
('admin', 'admin123', 'admin@example.com', '관리자', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('testuser', 'test123', 'test@example.com', '테스트유저', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('demo', 'demo123', 'demo@example.com', '데모', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
```

---

### 2. MySQL

```sql
-- 테이블 생성
CREATE TABLE products (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DOUBLE NOT NULL,
    quantity INT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 인덱스 생성 (선택사항)
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_products_created_at ON products(created_at);

-- 샘플 데이터 삽입
INSERT INTO products (name, description, price, quantity, created_at, updated_at) VALUES
('노트북', '고성능 노트북', 1500000.00, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('마우스', '무선 마우스', 35000.00, 50, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('키보드', '기계식 키보드', 120000.00, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
```

---

### 3. MariaDB

```sql
-- 테이블 생성
CREATE TABLE products (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DOUBLE NOT NULL,
    quantity INT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 인덱스 생성 (선택사항)
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_products_created_at ON products(created_at);

-- 샘플 데이터 삽입
INSERT INTO products (name, description, price, quantity, created_at, updated_at) VALUES
('노트북', '고성능 노트북', 1500000.00, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('마우스', '무선 마우스', 35000.00, 50, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('키보드', '기계식 키보드', 120000.00, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
```

---

### 4. Oracle

```sql
-- 시퀀스 생성 (ID 자동 증가용)
CREATE SEQUENCE products_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- 테이블 생성
CREATE TABLE products (
    id NUMBER(19) PRIMARY KEY,
    name VARCHAR2(255) NOT NULL,
    description CLOB,
    price NUMBER(19,2) NOT NULL,
    quantity NUMBER(10) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 트리거 생성 (ID 자동 증가)
CREATE OR REPLACE TRIGGER products_bi
BEFORE INSERT ON products
FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN
        SELECT products_seq.NEXTVAL INTO :NEW.id FROM DUAL;
    END IF;
END;
/

-- 인덱스 생성 (선택사항)
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_products_created_at ON products(created_at);

-- 샘플 데이터 삽입
INSERT INTO products (id, name, description, price, quantity, created_at, updated_at)
VALUES (products_seq.NEXTVAL, '노트북', '고성능 노트북', 1500000.00, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO products (id, name, description, price, quantity, created_at, updated_at)
VALUES (products_seq.NEXTVAL, '마우스', '무선 마우스', 35000.00, 50, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO products (id, name, description, price, quantity, created_at, updated_at)
VALUES (products_seq.NEXTVAL, '키보드', '기계식 키보드', 120000.00, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

COMMIT;
```

---

### 5. MS SQL Server

```sql
-- 테이블 생성
CREATE TABLE products (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX),
    price FLOAT NOT NULL,
    quantity INT NOT NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);

-- 인덱스 생성 (선택사항)
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_products_created_at ON products(created_at);

-- 샘플 데이터 삽입
INSERT INTO products (name, description, price, quantity, created_at, updated_at) VALUES
(N'노트북', N'고성능 노트북', 1500000.00, 10, GETDATE(), GETDATE()),
(N'마우스', N'무선 마우스', 35000.00, 50, GETDATE(), GETDATE()),
(N'키보드', N'기계식 키보드', 120000.00, 30, GETDATE(), GETDATE());
```

---

### 6. Tibero

```sql
-- 시퀀스 생성 (ID 자동 증가용)
CREATE SEQUENCE products_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- 테이블 생성
CREATE TABLE products (
    id NUMBER(19) PRIMARY KEY,
    name VARCHAR2(255) NOT NULL,
    description CLOB,
    price NUMBER(19,2) NOT NULL,
    quantity NUMBER(10) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 트리거 생성 (ID 자동 증가)
CREATE OR REPLACE TRIGGER products_bi
BEFORE INSERT ON products
FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN
        SELECT products_seq.NEXTVAL INTO :NEW.id FROM DUAL;
    END IF;
END;
/

-- 인덱스 생성 (선택사항)
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_products_created_at ON products(created_at);

-- 샘플 데이터 삽입
INSERT INTO products (id, name, description, price, quantity, created_at, updated_at)
VALUES (products_seq.NEXTVAL, '노트북', '고성능 노트북', 1500000.00, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO products (id, name, description, price, quantity, created_at, updated_at)
VALUES (products_seq.NEXTVAL, '마우스', '무선 마우스', 35000.00, 50, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO products (id, name, description, price, quantity, created_at, updated_at)
VALUES (products_seq.NEXTVAL, '키보드', '기계식 키보드', 120000.00, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

COMMIT;
```

---

## 🔧 설정 방법

### 1. 데이터베이스 서버 준비
사용할 데이터베이스 서버를 설치하고 실행합니다.

### 2. 데이터베이스 및 사용자 생성

#### PostgreSQL 예시:
```sql
CREATE DATABASE testdb;
CREATE USER dbuser WITH PASSWORD 'dbpassword';
GRANT ALL PRIVILEGES ON DATABASE testdb TO dbuser;
```

#### MySQL/MariaDB 예시:
```sql
CREATE DATABASE testdb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'dbuser'@'%' IDENTIFIED BY 'dbpassword';
GRANT ALL PRIVILEGES ON testdb.* TO 'dbuser'@'%';
FLUSH PRIVILEGES;
```

### 3. 테이블 생성
위의 DB별 DDL 스크립트를 실행하여 테이블을 생성합니다.

### 4. application.properties 설정
프로젝트의 `src/main/resources/application.properties` 파일에서:
- 해당 DB 설정의 주석을 해제
- DB 연결 정보(HOST, PORT, DB_NAME, USERNAME, PASSWORD) 수정

### 5. 애플리케이션 실행
```bash
./gradlew bootRun
```

---

## 📝 주의사항

1. **운영 환경에서는 `spring.jpa.hibernate.ddl-auto=none`을 사용하세요.**
   - 자동 테이블 생성/수정은 개발 환경에서만 사용하는 것이 안전합니다.

2. **Tibero의 경우 JDBC 드라이버를 수동으로 설치해야 합니다.**
   ```bash
   # libs 디렉토리 생성
   mkdir -p libs
   # Tibero JDBC 드라이버를 libs 디렉토리에 복사
   cp /path/to/tibero-jdbc.jar libs/
   ```
   그리고 `build.gradle`에서 해당 라인의 주석을 해제하세요:
   ```gradle
   implementation files('libs/tibero-jdbc.jar')
   ```

3. **Oracle의 경우 JDBC 드라이버 라이센스를 확인하세요.**
   - Maven Central에서 제공되지 않는 경우 수동 설치가 필요할 수 있습니다.

4. **데이터베이스 포트 번호**
   - PostgreSQL: 5432 (기본)
   - MySQL/MariaDB: 3306 (기본)
   - Oracle: 1521 (기본)
   - MS SQL Server: 1433 (기본)
   - Tibero: 8629 (기본)

---

## 🧪 API 테스트

테이블 생성 후 다음 API 엔드포인트로 테스트할 수 있습니다:

```bash
# Health Check
curl http://localhost:8080/api/products/health

# 모든 상품 조회
curl http://localhost:8080/api/products

# 특정 상품 조회
curl http://localhost:8080/api/products/1

# 상품 생성
curl -X POST http://localhost:8080/api/products \
  -H "Content-Type: application/json" \
  -d '{"name":"테스트 상품","description":"설명","price":10000,"quantity":5}'

# 상품 수정
curl -X PUT http://localhost:8080/api/products/1 \
  -H "Content-Type: application/json" \
  -d '{"name":"수정된 상품","description":"수정 설명","price":20000,"quantity":10}'

# 상품 삭제
curl -X DELETE http://localhost:8080/api/products/1

# 상품 검색
curl "http://localhost:8080/api/products/search?name=노트북"
```
