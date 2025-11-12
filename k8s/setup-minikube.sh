#!/bin/bash
# Minikube 시작 및 환경 설정 스크립트

set -e

echo "=========================================="
echo "Minikube 환경 설정 시작"
echo "=========================================="

# Minikube 시작 (호스트 디렉토리 마운트 포함)
echo "1. Minikube 시작 중..."
minikube start \
  --mount=true \
  --mount-string="/apps/k8s/privacy-agent-3.0:/agent" \
  --cpus=2 \
  --memory=4096 \
  --disk-size=20g

echo ""
echo "2. Minikube 상태 확인..."
minikube status

echo ""
echo "3. Docker 환경 설정..."
eval $(minikube docker-env)

echo ""
echo "4. 마운트 확인..."
minikube ssh "ls -la /agent"

echo ""
echo "=========================================="
echo "Minikube 환경 설정 완료!"
echo "=========================================="
echo ""
echo "다음 명령어를 실행하여 Docker 환경을 설정하세요:"
echo "  eval \$(minikube docker-env)"
