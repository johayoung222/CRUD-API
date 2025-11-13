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
- Lombok
- Gradle 8.5

## 주요 기능

- Product CRUD 작업 (생성, 조회, 수정, 삭제)
- Product 이름 검색
- Health Check 엔드포인트
- 입력 유효성 검사
- RESTful API 설계
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
- `DATABASE_SETUP.md`에서 해당 DB의 DDL 스크립트 실행하여 테이블 생성

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

- API: http://localhost:8080/api/products
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

## Kubernetes 배포 (Privacy Agent 통합)

이 프로젝트는 **BCI 기반 Privacy Agent**와 통합되어 POD별 접속 로그를 자동으로 생성합니다.

### 주요 특징

- 🔒 **Privacy Agent 통합**: Javassist 기반 BCI Agent가 모든 API 호출을 로깅
- 📊 **POD별 로그 분리**: Kubernetes Downward API를 활용한 POD별 독립 로그 디렉토리
- 🚀 **자동화 스크립트**: Minikube 환경 구축부터 배포까지 원클릭 자동화
- 🔄 **3-POD 구성**: 로드밸런싱 및 고가용성 테스트 환경

### 사전 준비사항

1. **Privacy Agent 설치**
   - Agent가 `/apps/k8s/privacy-agent-3.0` 경로에 설치되어 있어야 함
   - `install.sh`로 시스템 코드 "pargos" 설치 완료

2. **PostgreSQL 데이터베이스**
   - 192.168.1.55 서버에 PostgreSQL 설치 및 실행

3. **Minikube 환경**
   - Minikube, kubectl 설치

### 빠른 시작 (자동화 스크립트 사용)

#### 1단계: PostgreSQL 설정

```bash
cd k8s
chmod +x setup-postgresql.sh
./setup-postgresql.sh
```

이 스크립트는 다음 작업을 자동으로 수행합니다:
- cruddb 데이터베이스 생성
- cruduser 사용자 생성 및 권한 부여
- products 테이블 생성 및 샘플 데이터 삽입

#### 2단계: Minikube 시작 및 Agent 마운트

```bash
chmod +x setup-minikube.sh
./setup-minikube.sh

# Docker 환경 설정 (중요!)
eval $(minikube docker-env)
```

이 스크립트는 다음 작업을 자동으로 수행합니다:
- Minikube 시작
- Privacy Agent 디렉토리를 Minikube 내부로 마운트 (`/apps/k8s/privacy-agent-3.0` → `/agent`)
- 마운트 확인

#### 3단계: 애플리케이션 배포

```bash
chmod +x deploy.sh
./deploy.sh
```

이 스크립트는 다음 작업을 자동으로 수행합니다:
- Docker 이미지 빌드 (Minikube 내부 레지스트리 사용)
- ConfigMap, Deployment, Service 배포
- POD 상태 확인 및 접근 URL 출력

#### 4단계: API 테스트

```bash
chmod +x test-api.sh
./test-api.sh
```

### POD별 로그 확인

Privacy Agent는 각 POD마다 독립적인 로그를 생성합니다:

```bash
# 192.168.1.55 서버에서 확인
ls -la /apps/k8s/privacy-agent-3.0/privacy-instance/pargos/logs/

# 출력 예시:
# drwxr-xr-x 2 root root 4096 Jan 12 10:00 crud-api-xxxxxxxxx-xxxxx/
# drwxr-xr-x 2 root root 4096 Jan 12 10:00 crud-api-xxxxxxxxx-yyyyy/
# drwxr-xr-x 2 root root 4096 Jan 12 10:00 crud-api-xxxxxxxxx-zzzzz/

# 각 POD의 로그 파일 확인
ls -la /apps/k8s/privacy-agent-3.0/privacy-instance/pargos/logs/crud-api-*/

# Agent 로그 실시간 모니터링
tail -f /apps/k8s/privacy-agent-3.0/privacy-instance/pargos/logs/crud-api-*/AL_WAS*_ACC_LOG_*.dat
```

### 수동 배포 (고급 사용자용)

#### 이미지 준비

1. Docker 이미지 빌드

```bash
# Minikube Docker 환경 사용
eval $(minikube docker-env)
docker build -t crud-api:latest .
```

2. 레지스트리 사용 시

```bash
docker build -t your-registry/crud-api:v1.0.0 .
docker push your-registry/crud-api:v1.0.0
```

3. `k8s/crud-deployment.yaml` 파일의 이미지 경로 수정

```yaml
image: your-registry/crud-api:v1.0.0
```

#### Kubernetes 리소스 배포

```bash
# ConfigMap 배포
kubectl apply -f k8s/crud-configmap.yaml

# Deployment 배포 (Privacy Agent JVM 옵션 포함)
kubectl apply -f k8s/crud-deployment.yaml

# Service 배포 (NodePort 30080)
kubectl apply -f k8s/crud-service.yaml
```

#### 배포 확인

```bash
# Pod 상태 확인
kubectl get pods -l app=crud-api -o wide

# Service 확인
kubectl get svc crud-api-service

# 애플리케이션 로그 확인
kubectl logs -l app=crud-api -f

# 특정 POD 로그 확인
kubectl logs <pod-name> -f
```

#### 서비스 접근

```bash
# Minikube IP 확인
minikube ip

# NodePort로 접근 (30080)
curl http://$(minikube ip):30080/api/products/health

# API 테스트
curl http://$(minikube ip):30080/api/products
```

### 상세 배포 가이드

Privacy Agent 통합, 트러블슈팅, POD별 로그 분리 등 상세한 내용은 **[KUBERNETES_DEPLOYMENT.md](KUBERNETES_DEPLOYMENT.md)** 문서를 참조하세요.

이 문서에는 다음 내용이 포함되어 있습니다:
- 아키텍처 상세 설명
- Agent JVM 옵션 설정 방법
- POD별 로그 분리 메커니즘 (Kubernetes Downward API)
- 트러블슈팅 가이드
- 유용한 Kubernetes 명령어 모음

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
│   ├── crud-deployment.yaml      # Privacy Agent 통합 Deployment
│   ├── crud-service.yaml         # NodePort Service (30080)
│   ├── crud-configmap.yaml       # 환경 설정
│   ├── setup-minikube.sh         # Minikube 초기 설정 스크립트
│   ├── setup-postgresql.sh       # PostgreSQL 설정 스크립트
│   ├── deploy.sh                 # 전체 배포 자동화 스크립트
│   └── test-api.sh               # API 테스트 스크립트
├── Dockerfile
├── .dockerignore
├── build.gradle
├── DATABASE_SETUP.md             # 데이터베이스 설정 가이드
├── KUBERNETES_DEPLOYMENT.md      # Kubernetes 배포 상세 가이드
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
