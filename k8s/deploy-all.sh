#!/bin/bash
# ================================================================================
# CRUD-API Kubernetes 전체 배포 스크립트
# 192.168.1.55 서버에서 실행
# ================================================================================

set -e

PROJECT_DIR="/root/CRUD-API"
IMAGE_NAME="crud-api"
IMAGE_TAG="v1.0.0"

echo "=========================================="
echo "CRUD-API Kubernetes 배포 시작"
echo "=========================================="
echo ""

# 1. Git 저장소 업데이트
echo "1. Git 저장소 업데이트..."
if [ -d "$PROJECT_DIR" ]; then
    cd $PROJECT_DIR
    git fetch origin
    git checkout feature/authentication-redis
    git pull origin feature/authentication-redis
else
    cd /root
    git clone https://github.com/johayoung222/CRUD-API.git
    cd $PROJECT_DIR
    git checkout feature/authentication-redis
fi
echo "✓ Git 저장소 업데이트 완료"
echo ""

# 2. Gradle 빌드
echo "2. Gradle 빌드 시작..."
cd $PROJECT_DIR
chmod +x gradlew
./gradlew clean build -x test
echo "✓ Gradle 빌드 완료"
echo ""

# 3. Minikube 시작 (Privacy Agent 마운트 포함)
echo "3. Minikube 시작..."
if minikube status | grep -q "Running"; then
    echo "Minikube가 이미 실행 중입니다."
else
    minikube start \
        --mount=true \
        --mount-string="/apps/k8s/privacy-agent-3.0:/agent" \
        --cpus=2 \
        --memory=4096 \
        --disk-size=20g
fi
echo "✓ Minikube 실행 중"
echo ""

# 4. Minikube Docker 환경으로 전환
echo "4. Minikube Docker 환경 설정..."
eval $(minikube docker-env)
echo "✓ Docker 환경 전환 완료"
echo ""

# 5. Docker 이미지 빌드
echo "5. Docker 이미지 빌드..."
cd $PROJECT_DIR
docker build -t $IMAGE_NAME:$IMAGE_TAG .
docker tag $IMAGE_NAME:$IMAGE_TAG $IMAGE_NAME:latest
echo "✓ Docker 이미지 빌드 완료"
echo ""

# 6. 기존 배포 삭제 (있는 경우)
echo "6. 기존 배포 확인 및 삭제..."
if kubectl get deployment crud-api-deployment &> /dev/null; then
    echo "기존 배포를 삭제합니다..."
    kubectl delete -f k8s/crud-deployment.yaml || true
    kubectl delete -f k8s/crud-service.yaml || true
    kubectl delete -f k8s/crud-configmap.yaml || true
    sleep 5
fi
echo "✓ 기존 리소스 정리 완료"
echo ""

# 7. Kubernetes 리소스 배포
echo "7. Kubernetes 리소스 배포..."
kubectl apply -f k8s/crud-configmap.yaml
kubectl apply -f k8s/crud-deployment.yaml
kubectl apply -f k8s/crud-service.yaml
echo "✓ Kubernetes 리소스 배포 완료"
echo ""

# 8. Pod 상태 확인
echo "8. Pod 배포 상태 확인..."
echo "Pod가 준비될 때까지 대기 중... (최대 5분)"
kubectl wait --for=condition=ready pod -l app=crud-api --timeout=300s || {
    echo "경고: Pod 준비가 완료되지 않았습니다. 상태를 확인하세요."
    kubectl get pods -l app=crud-api
    kubectl describe pods -l app=crud-api
}
echo ""

# 9. 배포 결과 확인
echo "=========================================="
echo "배포 완료!"
echo "=========================================="
echo ""
echo "📦 배포된 리소스:"
kubectl get all -l app=crud-api
echo ""

# 10. Service URL 확인
echo "🌐 서비스 접근 정보:"
MINIKUBE_IP=$(minikube ip)
NODE_PORT=$(kubectl get svc crud-api-service -o jsonpath='{.spec.ports[0].nodePort}')
echo "  - Minikube IP: $MINIKUBE_IP"
echo "  - NodePort: $NODE_PORT"
echo "  - Service URL: http://$MINIKUBE_IP:$NODE_PORT"
echo ""
echo "📝 API 엔드포인트:"
echo "  - Products: http://$MINIKUBE_IP:$NODE_PORT/api/products"
echo "  - Health: http://$MINIKUBE_IP:$NODE_PORT/actuator/health"
echo "  - Auth (Redis): http://$MINIKUBE_IP:$NODE_PORT/api/auth/redis/login"
echo "  - Auth (Session): http://$MINIKUBE_IP:$NODE_PORT/api/auth/session/login"
echo ""

# 11. Pod 로그 확인
echo "📊 Pod 목록 및 상태:"
kubectl get pods -l app=crud-api -o wide
echo ""
echo "💡 유용한 명령어:"
echo "  - Pod 로그 보기: kubectl logs -f <pod-name>"
echo "  - Pod 상태 확인: kubectl describe pod <pod-name>"
echo "  - Privacy Agent 로그 확인: kubectl exec <pod-name> -- ls -la /agent/privacy-instance/pargos/logs/"
echo "  - 서비스 포트 포워딩: kubectl port-forward svc/crud-api-service 8080:80"
echo ""
echo "=========================================="
