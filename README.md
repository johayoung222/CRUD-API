# CRUD API - Spring Boot Application

Java 17 기반의 Product CRUD REST API입니다. 다양한 데이터베이스와 데이터 액세스 계층을 지원하며, Kubernetes 환경에 배포 가능하도록 설계되었습니다.

## 기술 스택

- Java 17
- Spring Boot 3.2.0
- 데이터 액세스 계층
  - Spring Data JPA
  - MyBatis 3.0.3
- 지원 데이터베이스
  - PostgreSQL
  - MySQL
  - MariaDB
  - Oracle
  - MS SQL Server
  - Tibero
- 인증 & 세션
  - Spring Session
  - Redis (세션 스토리지)
- Lombok
- Gradle 8.5

## 주요 기능

### Product 관리
- Product CRUD 작업 (생성, 조회, 수정, 삭제)
- Product 이름 검색
- Health Check 엔드포인트
- 입력 유효성 검사
- RESTful API 설계

### 인증 & 세션
- 세션 기반 인증 (HTTP Session + Redis)
- Redis 토큰 기반 인증 (UUID 토큰)
- 쿠키 기반 및 헤더 기반 인증 지원
- 자동 세션 만료 (30분 TTL)

### 데이터베이스
- 다중 데이터베이스 지원 (PostgreSQL, MySQL, MariaDB, Oracle, MS SQL Server, Tibero)
- 데이터 액세스 계층 선택 가능 (JPA / MyBatis)
- 설정 기반 DB 및 데이터 액세스 전환

## API 엔드포인트

### Product 관리

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/products` | 모든 제품 조회 |
| GET | `/api/products/{id}` | 특정 제품 조회 |
| GET | `/api/products/search?name={name}` | 이름으로 제품 검색 |
| POST | `/api/products` | 새 제품 생성 |
| PUT | `/api/products/{id}` | 제품 정보 수정 |
| DELETE | `/api/products/{id}` | 제품 삭제 |
| GET | `/api/products/health` | 헬스 체크 |

### 인증 (세션 기반)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/session/login` | 세션 로그인 |
| POST | `/api/auth/session/logout` | 세션 로그아웃 |
| GET | `/api/auth/session/me` | 현재 사용자 정보 조회 |
| GET | `/api/auth/session/check` | 인증 상태 확인 |

### 인증 (Redis 토큰 기반)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/redis/login` | Redis 토큰 로그인 |
| POST | `/api/auth/redis/logout` | Redis 토큰 로그아웃 |
| GET | `/api/auth/redis/me` | 현재 사용자 정보 조회 |
| GET | `/api/auth/redis/check` | 인증 상태 확인 |
| POST | `/api/auth/redis/extend` | 세션 연장 |
| GET | `/api/auth/health` | Auth 서비스 헬스 체크 |

### 요청/응답 예시

#### 제품 생성 (POST /api/products)

```json
{
  "name": "Laptop",
  "description": "High performance laptop",
  "price": 1299.99,
  "quantity": 10
}
```

#### 응답

```json
{
  "id": 1,
  "name": "Laptop",
  "description": "High performance laptop",
  "price": 1299.99,
  "quantity": 10,
  "createdAt": "2024-01-01T10:00:00",
  "updatedAt": "2024-01-01T10:00:00"
}
```

## 로컬 개발 환경 실행

### 필수 요구사항

- JDK 17 이상
- Gradle 8.5 이상 (또는 포함된 Gradle Wrapper 사용)
- 데이터베이스 서버 (PostgreSQL, MySQL, MariaDB, Oracle, MS SQL Server, 또는 Tibero 중 하나)

### 실행 방법

1. 프로젝트 클론

```bash
git clone <repository-url>
cd CRUD-API
```

2. 데이터베이스 설정

**자세한 DB 설정 방법은 [DATABASE_SETUP.md](DATABASE_SETUP.md) 파일을 참조하세요.**

- 데이터베이스 서버 설치 및 실행
- 데이터베이스 및 사용자 생성
- `DATABASE_SETUP.md`에서 해당 DB의 DDL 스크립트 실행하여 테이블 생성 (products, users)

2-1. Redis 설정 (선택사항 - 인증 기능 사용 시 필요)

- Redis 서버 설치 및 실행 (기본 포트 6379)
- 인증 기능을 사용하지 않으면 생략 가능

3. application.properties 설정

`src/main/resources/application.properties` 파일 수정:

```properties
# DB 연결 정보 수정
DB_HOST=localhost
DB_PORT=5432  # 사용하는 DB의 포트
DB_NAME=testdb
DB_USERNAME=dbuser
DB_PASSWORD=dbpassword

# 사용할 DB에 맞게 주석 해제
# 예: PostgreSQL 사용 시
spring.datasource.url=jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME}
spring.datasource.driver-class-name=org.postgresql.Driver
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect

# 데이터 액세스 계층 선택 (JPA 또는 MYBATIS)
app.data-access.type=JPA
```

4. 애플리케이션 빌드

```bash
./gradlew build
```

5. 애플리케이션 실행

```bash
./gradlew bootRun
```

또는 빌드된 JAR 파일 실행:

```bash
java -jar build/libs/crud-api-0.0.1-SNAPSHOT.jar
```

6. 애플리케이션 접속

- Product API: http://localhost:8080/api/products
- Auth API (Session): http://localhost:8080/api/auth/session/login
- Auth API (Redis): http://localhost:8080/api/auth/redis/login
- Health Check: http://localhost:8080/actuator/health

## Docker 빌드 및 실행

### Docker 이미지 빌드

```bash
docker build -t crud-api:latest .
```

### Docker 컨테이너 실행

```bash
docker run -p 8080:8080 crud-api:latest
```

## Kubernetes 배포

### 이미지 준비

1. Docker 이미지 빌드

```bash
docker build -t your-registry/crud-api:v1.0.0 .
```

2. 이미지를 레지스트리에 푸시

```bash
docker push your-registry/crud-api:v1.0.0
```

3. `k8s/deployment.yaml` 파일의 이미지 경로 수정

```yaml
image: your-registry/crud-api:v1.0.0
```

### Kubernetes 리소스 배포

```bash
# ConfigMap 배포
kubectl apply -f k8s/configmap.yaml

# Deployment 배포
kubectl apply -f k8s/deployment.yaml

# Service 배포
kubectl apply -f k8s/service.yaml

# HPA (선택사항)
kubectl apply -f k8s/hpa.yaml
```

### 배포 확인

```bash
# Pod 상태 확인
kubectl get pods -l app=crud-api

# Service 확인
kubectl get svc crud-api-service

# Logs 확인
kubectl logs -l app=crud-api
```

### 서비스 접근

```bash
# ClusterIP 서비스인 경우 포트 포워딩
kubectl port-forward svc/crud-api-service 8080:80

# 이후 http://localhost:8080/api/products 접근
```

## 프로젝트 구조

```
CRUD-API/
├── src/
│   ├── main/
│   │   ├── java/com/example/crudapi/
│   │   │   ├── CrudApiApplication.java
│   │   │   ├── config/
│   │   │   │   └── DataAccessConfiguration.java
│   │   │   ├── controller/
│   │   │   │   └── ProductController.java
│   │   │   ├── entity/
│   │   │   │   └── Product.java
│   │   │   ├── repository/
│   │   │   │   ├── ProductRepository.java (공통 인터페이스)
│   │   │   │   ├── jpa/
│   │   │   │   │   ├── ProductJpaRepository.java
│   │   │   │   │   └── ProductRepositoryJpaImpl.java
│   │   │   │   └── mybatis/
│   │   │   │       ├── ProductMapper.java
│   │   │   │       └── ProductRepositoryMyBatisImpl.java
│   │   │   └── service/
│   │   │       └── ProductService.java
│   │   └── resources/
│   │       ├── application.properties
│   │       └── mapper/
│   │           └── ProductMapper.xml
│   └── test/
├── k8s/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   └── hpa.yaml
├── Dockerfile
├── .dockerignore
├── build.gradle
├── DATABASE_SETUP.md
└── README.md
```

## 설정

### application.properties 주요 설정

```properties
# 서버 포트
server.port=8080

# 데이터베이스 연결 정보 (공통)
DB_HOST=localhost
DB_PORT=5432
DB_NAME=testdb
DB_USERNAME=dbuser
DB_PASSWORD=dbpassword

spring.datasource.username=${DB_USERNAME}
spring.datasource.password=${DB_PASSWORD}

# 데이터베이스별 드라이버 설정 (하나를 선택하여 주석 해제)
# PostgreSQL
spring.datasource.url=jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME}
spring.datasource.driver-class-name=org.postgresql.Driver
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect

# MySQL
# spring.datasource.url=jdbc:mysql://${DB_HOST}:${DB_PORT}/${DB_NAME}
# spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
# spring.jpa.database-platform=org.hibernate.dialect.MySQLDialect

# 데이터 액세스 계층 선택
app.data-access.type=JPA  # 또는 MYBATIS

# JPA 설정
spring.jpa.hibernate.ddl-auto=none  # 운영 환경에서는 none 또는 validate 사용
spring.jpa.show-sql=true

# MyBatis 설정
mybatis.mapper-locations=classpath:mapper/**/*.xml
mybatis.configuration.map-underscore-to-camel-case=true
```

자세한 설정 방법은 [DATABASE_SETUP.md](DATABASE_SETUP.md)를 참조하세요.

## 테스트

```bash
# 모든 테스트 실행
./gradlew test

# 테스트 리포트 확인
open build/reports/tests/test/index.html
```

## API 테스트 예시 (curl)

### Product API

```bash
# 제품 생성
curl -X POST http://localhost:8080/api/products \
  -H "Content-Type: application/json" \
  -d '{"name":"Laptop","description":"High performance","price":1299.99,"quantity":10}'

# 모든 제품 조회
curl http://localhost:8080/api/products

# 특정 제품 조회
curl http://localhost:8080/api/products/1

# 제품 수정
curl -X PUT http://localhost:8080/api/products/1 \
  -H "Content-Type: application/json" \
  -d '{"name":"Updated Laptop","description":"Updated","price":1499.99,"quantity":5}'

# 제품 삭제
curl -X DELETE http://localhost:8080/api/products/1

# Health Check
curl http://localhost:8080/api/products/health
```

### 인증 API (세션 기반)

```bash
# 세션 로그인
curl -c cookies.txt -X POST http://localhost:8080/api/auth/session/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'

# 현재 사용자 정보 조회 (쿠키 사용)
curl -b cookies.txt http://localhost:8080/api/auth/session/me

# 인증 상태 확인
curl -b cookies.txt http://localhost:8080/api/auth/session/check

# 로그아웃
curl -b cookies.txt -X POST http://localhost:8080/api/auth/session/logout
```

### 인증 API (Redis 토큰 기반)

```bash
# Redis 로그인 (토큰 발급)
RESPONSE=$(curl -s -X POST http://localhost:8080/api/auth/redis/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"test123"}')
echo $RESPONSE

# 토큰 추출
TOKEN=$(echo $RESPONSE | jq -r '.sessionId')

# 현재 사용자 정보 조회 (헤더에 토큰 포함)
curl -H "X-Session-Token: $TOKEN" http://localhost:8080/api/auth/redis/me

# 인증 상태 확인
curl -H "X-Session-Token: $TOKEN" http://localhost:8080/api/auth/redis/check

# 세션 연장
curl -H "X-Session-Token: $TOKEN" -X POST http://localhost:8080/api/auth/redis/extend

# 로그아웃
curl -H "X-Session-Token: $TOKEN" -X POST http://localhost:8080/api/auth/redis/logout
```

**샘플 사용자 계정:**
- admin / admin123
- testuser / test123
- demo / demo123

## 라이센스

MIT License
