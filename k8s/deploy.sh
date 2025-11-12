#!/bin/bash
# CRUD API with Privacy Agent 배포 스크립트

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
K8S_DIR="$PROJECT_DIR/k8s"

echo "=========================================="
echo "CRUD API with Privacy Agent 배포"
echo "=========================================="

# 1. Docker 환경 설정
echo ""
echo "1. Minikube Docker 환경 설정..."
eval $(minikube docker-env)

# 2. 이미지 빌드
echo ""
echo "2. Docker 이미지 빌드 중..."
cd "$PROJECT_DIR"
docker build -t crud-api:latest .

echo ""
echo "3. 빌드된 이미지 확인..."
docker images | grep crud-api

# 4. Kubernetes 리소스 배포
echo ""
echo "4. Kubernetes 리소스 배포 중..."

# ConfigMap 배포
echo "  - ConfigMap 배포..."
kubectl apply -f "$K8S_DIR/crud-configmap.yaml"

# Deployment 배포
echo "  - Deployment 배포..."
kubectl apply -f "$K8S_DIR/crud-deployment.yaml"

# Service 배포
echo "  - Service 배포..."
kubectl apply -f "$K8S_DIR/crud-service.yaml"

# 5. 배포 상태 확인
echo ""
echo "5. 배포 상태 확인 중..."
echo ""
echo "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=crud-api --timeout=300s || true

echo ""
echo "=========================================="
echo "배포 완료!"
echo "=========================================="

# 6. 배포 정보 출력
echo ""
echo "📊 배포 정보:"
echo ""
echo "Pods:"
kubectl get pods -l app=crud-api -o wide

echo ""
echo "Services:"
kubectl get svc crud-api-service

echo ""
echo "Minikube IP:"
MINIKUBE_IP=$(minikube ip)
echo "$MINIKUBE_IP"

echo ""
echo "=========================================="
echo "🚀 접근 URL:"
echo "  http://$MINIKUBE_IP:30080/api/products"
echo "  http://$MINIKUBE_IP:30080/api/products/health"
echo "=========================================="

echo ""
echo "📝 유용한 명령어:"
echo "  # Pod 로그 확인"
echo "  kubectl logs -l app=crud-api -f"
echo ""
echo "  # 특정 Pod 로그 확인"
echo "  kubectl logs <pod-name> -f"
echo ""
echo "  # Agent 로그 확인 (호스트에서)"
echo "  ls -la /apps/k8s/privacy-agent-3.0/privacy-instance/pargos/logs/"
echo ""
echo "  # Pod 상태 확인"
echo "  kubectl get pods -l app=crud-api -o wide"
echo ""
echo "  # Pod 내부 접속"
echo "  kubectl exec -it <pod-name> -- /bin/sh"
