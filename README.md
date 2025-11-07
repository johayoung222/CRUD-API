# CRUD API - Spring Boot Application

Java 17 기반의 간단한 Product CRUD REST API입니다. Kubernetes 환경에 배포 가능하도록 설계되었습니다.

## 기술 스택

- Java 17
- Spring Boot 3.2.0
- Spring Data JPA
- H2 Database (In-Memory)
- Lombok
- Gradle 8.5

## 주요 기능

- Product CRUD 작업 (생성, 조회, 수정, 삭제)
- Product 이름 검색
- Health Check 엔드포인트
- 입력 유효성 검사
- RESTful API 설계

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

### 실행 방법

1. 프로젝트 클론

```bash
git clone <repository-url>
cd CRUD-API
```

2. 애플리케이션 빌드

```bash
./gradlew build
```

3. 애플리케이션 실행

```bash
./gradlew bootRun
```

또는 빌드된 JAR 파일 실행:

```bash
java -jar build/libs/crud-api-0.0.1-SNAPSHOT.jar
```

4. 애플리케이션 접속

- API: http://localhost:8080/api/products
- H2 Console: http://localhost:8080/h2-console
  - JDBC URL: `jdbc:h2:mem:testdb`
  - Username: `sa`
  - Password: (비워둠)

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
│   │   │   ├── controller/
│   │   │   │   └── ProductController.java
│   │   │   ├── entity/
│   │   │   │   └── Product.java
│   │   │   ├── repository/
│   │   │   │   └── ProductRepository.java
│   │   │   └── service/
│   │   │       └── ProductService.java
│   │   └── resources/
│   │       └── application.properties
│   └── test/
├── k8s/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   └── hpa.yaml
├── Dockerfile
├── .dockerignore
├── build.gradle
└── README.md
```

## 설정

### application.properties 주요 설정

```properties
# 서버 포트
server.port=8080

# H2 데이터베이스 (개발용)
spring.datasource.url=jdbc:h2:mem:testdb
spring.jpa.hibernate.ddl-auto=update

# H2 콘솔 활성화
spring.h2.console.enabled=true
```

## 테스트

```bash
# 모든 테스트 실행
./gradlew test

# 테스트 리포트 확인
open build/reports/tests/test/index.html
```

## API 테스트 예시 (curl)

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

## 라이센스

MIT License
