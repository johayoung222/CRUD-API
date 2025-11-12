# Kubernetes 환경에 Privacy Agent 적용 배포 가이드

이 문서는 CRUD API 프로젝트를 Privacy Agent와 함께 Minikube Kubernetes 환경에 배포하는 방법을 설명합니다.

## 📋 목차

1. [사전 준비사항](#사전-준비사항)
2. [아키텍처 개요](#아키텍처-개요)
3. [배포 단계](#배포-단계)
4. [테스트 및 확인](#테스트-및-확인)
5. [로그 확인](#로그-확인)
6. [트러블슈팅](#트러블슈팅)

---

## 사전 준비사항

### 1. 필수 소프트웨어
- Docker
- Minikube
- kubectl
- PostgreSQL 서버 (192.168.1.55)
- Privacy Agent 3.0 (`/apps/k8s/privacy-agent-3.0` 디렉토리)

### 2. Privacy Agent 설치 확인

```bash
# 192.168.1.55 서버에서 확인
ls -la /apps/k8s/privacy-agent-3.0/

# 필수 디렉토리 및 파일 구조
# ├── bin/
# ├── lib/
# │   ├── privacy-agent.jar
# │   └── privacy-agent-bootstrap.jar
# ├── privacy-instance/
# │   └── pargos/
# │       ├── conf/
# │       └── logs/
# └── tracelog/
```

Agent가 설치되지 않았다면:
```bash
cd /apps/k8s/privacy-agent-3.0/bin
./install.sh
# 시스템 코드 입력 시: pargos
```

---

## 아키텍처 개요

### 컴포넌트 구성

```
┌─────────────────────────────────────────────────────────────┐
│                    Minikube Cluster                          │
│                                                               │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐   │
│  │  crud-api-1   │  │  crud-api-2   │  │  crud-api-3   │   │
│  │               │  │               │  │               │   │
│  │  Spring Boot  │  │  Spring Boot  │  │  Spring Boot  │   │
│  │  + Agent      │  │  + Agent      │  │  + Agent      │   │
│  └───────┬───────┘  └───────┬───────┘  └───────┬───────┘   │
│          │                  │                  │            │
│          └──────────────────┴──────────────────┘            │
│                             │                                │
│                    NodePort 30080                            │
└─────────────────────────────┼────────────────────────────────┘
                              │
                    ┌─────────┴─────────┐
                    │                   │
            ┌───────▼────────┐  ┌──────▼──────┐
            │  PostgreSQL    │  │  Agent Logs │
            │  192.168.1.55  │  │  /apps/k8s/ │
            └────────────────┘  └─────────────┘
```

### 주요 특징

1. **POD별 로그 분리**: Downward API를 통해 POD 이름을 주입하여 각 POD의 로그를 별도 디렉토리에 저장
   ```
   /apps/k8s/privacy-agent-3.0/privacy-instance/pargos/logs/crud-api-xxxxx1/
   /apps/k8s/privacy-agent-3.0/privacy-instance/pargos/logs/crud-api-xxxxx2/
   /apps/k8s/privacy-agent-3.0/privacy-instance/pargos/logs/crud-api-xxxxx3/
   ```

2. **HostPath 마운트**: Agent는 호스트 파일시스템에 있으며, 모든 POD가 공유

3. **외부 접근**: NodePort(30080)를 통해 `http://192.168.1.55:30080`으로 접근 가능

---

## 배포 단계

### 1단계: PostgreSQL 설정

```bash
# 192.168.1.55 서버에서 실행
cd /path/to/CRUD-API/k8s
chmod +x setup-postgresql.sh
./setup-postgresql.sh
```

데이터베이스 정보:
- 호스트: 192.168.1.55
- 포트: 5432
- 데이터베이스: cruddb
- 사용자: cruduser
- 비밀번호: crudpass123

### 2단계: Minikube 시작 및 설정

```bash
# 192.168.1.55 서버에서 실행
cd /path/to/CRUD-API/k8s
chmod +x setup-minikube.sh
./setup-minikube.sh
```

**중요**: 스크립트 실행 후 다음 명령어를 실행하여 Docker 환경을 설정하세요:
```bash
eval $(minikube docker-env)
```

마운트 확인:
```bash
minikube ssh
ls -la /agent
# privacy-agent-3.0의 내용이 보여야 함
exit
```

### 3단계: 애플리케이션 배포

```bash
# 192.168.1.55 서버에서 실행
cd /path/to/CRUD-API/k8s
chmod +x deploy.sh
./deploy.sh
```

배포 스크립트는 다음 작업을 수행합니다:
1. Docker 이미지 빌드
2. Kubernetes 리소스 배포 (ConfigMap, Deployment, Service)
3. POD 상태 확인
4. 접근 정보 출력

---

## 테스트 및 확인

### 1. POD 상태 확인

```bash
# POD 목록 조회
kubectl get pods -l app=crud-api

# 출력 예시:
# NAME                        READY   STATUS    RESTARTS   AGE
# crud-api-xxxxxxxxx-xxxxx    1/1     Running   0          2m
# crud-api-xxxxxxxxx-xxxxx    1/1     Running   0          2m
# crud-api-xxxxxxxxx-xxxxx    1/1     Running   0          2m
```

### 2. Service 확인

```bash
kubectl get svc crud-api-service

# 출력 예시:
# NAME               TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
# crud-api-service   NodePort   10.96.xxx.xxx   <none>        80:30080/TCP   2m
```

### 3. API 테스트

```bash
# Minikube IP 확인
MINIKUBE_IP=$(minikube ip)

# Health Check
curl http://$MINIKUBE_IP:30080/api/products/health

# 모든 제품 조회
curl http://$MINIKUBE_IP:30080/api/products

# 제품 생성 (Agent 로그 생성 트리거)
curl -X POST http://$MINIKUBE_IP:30080/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "테스트 상품",
    "description": "Agent 로깅 테스트용",
    "price": 10000,
    "quantity": 5
  }'

# 제품 조회 (Agent 로그 생성 트리거)
curl http://$MINIKUBE_IP:30080/api/products/1

# 제품 수정
curl -X PUT http://$MINIKUBE_IP:30080/api/products/1 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "수정된 상품",
    "description": "수정 테스트",
    "price": 20000,
    "quantity": 10
  }'

# 제품 삭제
curl -X DELETE http://$MINIKUBE_IP:30080/api/products/1
```

---

## 로그 확인

### 1. 애플리케이션 로그

```bash
# 모든 POD의 로그 확인 (실시간)
kubectl logs -l app=crud-api -f

# 특정 POD의 로그 확인
kubectl logs <pod-name> -f

# 최근 100줄만 확인
kubectl logs <pod-name> --tail=100
```

### 2. Agent 로그 확인

```bash
# 192.168.1.55 서버에서 확인

# POD별 로그 디렉토리 확인
ls -la /apps/k8s/privacy-agent-3.0/privacy-instance/pargos/logs/

# 출력 예시:
# drwxr-xr-x 2 root root 4096 Jan 12 10:00 crud-api-xxxxxxxxx-xxxxx/
# drwxr-xr-x 2 root root 4096 Jan 12 10:00 crud-api-xxxxxxxxx-yyyyy/
# drwxr-xr-x 2 root root 4096 Jan 12 10:00 crud-api-xxxxxxxxx-zzzzz/

# 특정 POD의 로그 파일 확인
ls -la /apps/k8s/privacy-agent-3.0/privacy-instance/pargos/logs/crud-api-xxxxxxxxx-xxxxx/

# 출력 예시:
# AL_WAS1_ACC_LOG_2025011210.dat
# AL_WAS1_SQL_INFO_2025011210.dat
# AL_WAS1_SQL_RESULT_2025011210.dat

# 로그 내용 확인 (예시)
tail -f /apps/k8s/privacy-agent-3.0/privacy-instance/pargos/logs/crud-api-*/AL_WAS*_ACC_LOG_*.dat
```

### 3. POD별 로그 분석

```bash
# 각 POD의 이름과 IP 확인
kubectl get pods -l app=crud-api -o custom-columns=NAME:.metadata.name,IP:.status.podIP

# 특정 POD의 Agent 로그 디렉토리 확인
POD_NAME=$(kubectl get pods -l app=crud-api -o jsonpath='{.items[0].metadata.name}')
ls -la /apps/k8s/privacy-agent-3.0/privacy-instance/pargos/logs/$POD_NAME/
```

---

## 트러블슈팅

### 문제 1: POD가 CrashLoopBackOff 상태

**증상:**
```bash
kubectl get pods
# NAME                        READY   STATUS             RESTARTS   AGE
# crud-api-xxx                0/1     CrashLoopBackOff   3          2m
```

**해결 방법:**

1. 로그 확인:
```bash
kubectl logs <pod-name>
```

2. 일반적인 원인:
   - Agent JAR 파일이 없거나 경로가 잘못됨
   - 데이터베이스 연결 실패
   - JVM 메모리 부족

3. Agent 파일 확인:
```bash
minikube ssh
ls -la /agent/lib/
# privacy-agent.jar와 privacy-agent-bootstrap.jar가 있어야 함
exit
```

4. 데이터베이스 연결 확인:
```bash
# 192.168.1.55에서
PGPASSWORD=crudpass123 psql -h 192.168.1.55 -U cruduser -d cruddb -c "SELECT 1;"
```

### 문제 2: Agent 로그가 생성되지 않음

**해결 방법:**

1. Agent 디렉토리 권한 확인:
```bash
ls -la /apps/k8s/privacy-agent-3.0/privacy-instance/pargos/logs/
# 쓰기 권한이 있어야 함
```

2. JVM 옵션 확인:
```bash
kubectl exec -it <pod-name> -- env | grep JAVA_TOOL_OPTIONS
```

3. Agent 설정 파일 확인:
```bash
cat /apps/k8s/privacy-agent-3.0/privacy-instance/pargos/conf/privacy-agent.properties
```

### 문제 3: 외부에서 접근 불가

**해결 방법:**

1. Service 확인:
```bash
kubectl get svc crud-api-service
# TYPE이 NodePort인지 확인
```

2. Minikube IP 확인:
```bash
minikube ip
```

3. 방화벽 확인:
```bash
# 192.168.1.55에서
firewall-cmd --list-ports
# 30080/tcp가 열려 있어야 함

# 열려있지 않다면:
sudo firewall-cmd --add-port=30080/tcp --permanent
sudo firewall-cmd --reload
```

### 문제 4: POD별 로그 디렉토리가 생성되지 않음

**해결 방법:**

1. POD 이름 환경변수 확인:
```bash
kubectl exec -it <pod-name> -- env | grep POD_NAME
```

2. JVM 옵션에서 POD_NAME 사용 확인:
```bash
kubectl describe pod <pod-name> | grep JAVA_TOOL_OPTIONS
```

3. 로그 디렉토리 생성 권한 확인:
```bash
ls -ld /apps/k8s/privacy-agent-3.0/privacy-instance/pargos/logs/
# drwxrwxrwx 또는 충분한 쓰기 권한이 있어야 함
```

---

## 유용한 명령어 모음

### Kubernetes 관리

```bash
# POD 재시작
kubectl rollout restart deployment crud-api

# POD 스케일 조정
kubectl scale deployment crud-api --replicas=5

# 특정 POD 삭제 (자동으로 재생성됨)
kubectl delete pod <pod-name>

# Deployment 상세 정보
kubectl describe deployment crud-api

# Service 상세 정보
kubectl describe svc crud-api-service

# ConfigMap 확인
kubectl get configmap crud-api-config -o yaml
```

### 로그 및 디버깅

```bash
# 모든 리소스 확인
kubectl get all -l app=crud-api

# POD 이벤트 확인
kubectl get events --sort-by=.metadata.creationTimestamp

# POD 내부 쉘 접속
kubectl exec -it <pod-name> -- /bin/sh

# POD 리소스 사용량 확인
kubectl top pods -l app=crud-api
```

### Agent 로그 관리

```bash
# 모든 POD의 Agent 로그 디렉토리 크기 확인
du -sh /apps/k8s/privacy-agent-3.0/privacy-instance/pargos/logs/*/

# 오래된 로그 파일 삭제 (30일 이상)
find /apps/k8s/privacy-agent-3.0/privacy-instance/pargos/logs/ -name "*.dat" -mtime +30 -delete

# 로그 파일 개수 확인
find /apps/k8s/privacy-agent-3.0/privacy-instance/pargos/logs/ -name "*.dat" | wc -l
```

---

## 배포 제거

전체 리소스를 제거하려면:

```bash
# Kubernetes 리소스 제거
kubectl delete -f k8s/crud-service.yaml
kubectl delete -f k8s/crud-deployment.yaml
kubectl delete -f k8s/crud-configmap.yaml

# 또는 라벨로 일괄 제거
kubectl delete all -l app=crud-api

# Minikube 중지
minikube stop

# Minikube 완전 제거
minikube delete
```

---

## 참고 자료

- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [Downward API](https://kubernetes.io/docs/tasks/inject-data-application/downward-api-volume-expose-pod-information/)

---

## 문의

문제가 발생하거나 질문이 있으면 다음 정보와 함께 문의하세요:

1. POD 상태: `kubectl get pods -l app=crud-api`
2. POD 로그: `kubectl logs <pod-name>`
3. POD 상세 정보: `kubectl describe pod <pod-name>`
4. Agent 로그 디렉토리 상태: `ls -la /apps/k8s/privacy-agent-3.0/privacy-instance/pargos/logs/`
