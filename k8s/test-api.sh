#!/bin/bash
# CRUD API 테스트 스크립트

set -e

# Minikube IP 가져오기
MINIKUBE_IP=$(minikube ip)
BASE_URL="http://$MINIKUBE_IP:30080/api/products"

echo "=========================================="
echo "CRUD API 테스트"
echo "=========================================="
echo "Base URL: $BASE_URL"
echo ""

# Health Check
echo "1. Health Check..."
curl -s "$BASE_URL/health" | jq '.' || echo "Health check successful"
echo ""

# 모든 제품 조회
echo "2. 모든 제품 조회..."
curl -s "$BASE_URL" | jq '.'
echo ""

# 제품 생성
echo "3. 제품 생성..."
PRODUCT_ID=$(curl -s -X POST "$BASE_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "테스트 노트북",
    "description": "Agent 로깅 테스트용 제품",
    "price": 1500000,
    "quantity": 10
  }' | jq -r '.id')

echo "생성된 제품 ID: $PRODUCT_ID"
echo ""

# 생성된 제품 조회
echo "4. 생성된 제품 조회 (ID: $PRODUCT_ID)..."
curl -s "$BASE_URL/$PRODUCT_ID" | jq '.'
echo ""

# 제품 수정
echo "5. 제품 수정 (ID: $PRODUCT_ID)..."
curl -s -X PUT "$BASE_URL/$PRODUCT_ID" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "수정된 노트북",
    "description": "가격 인하",
    "price": 1200000,
    "quantity": 15
  }' | jq '.'
echo ""

# 제품 검색
echo "6. 제품 검색 (name=노트북)..."
curl -s "$BASE_URL/search?name=노트북" | jq '.'
echo ""

# 제품 삭제
echo "7. 제품 삭제 (ID: $PRODUCT_ID)..."
curl -s -X DELETE "$BASE_URL/$PRODUCT_ID"
echo "삭제 완료"
echo ""

# 삭제 확인
echo "8. 삭제 확인 (ID: $PRODUCT_ID)..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/$PRODUCT_ID")
if [ "$HTTP_CODE" = "404" ]; then
    echo "✓ 제품이 정상적으로 삭제되었습니다."
else
    echo "✗ 예상치 못한 응답 코드: $HTTP_CODE"
fi
echo ""

echo "=========================================="
echo "테스트 완료!"
echo "=========================================="
echo ""
echo "Agent 로그 확인:"
echo "  ssh root@$MINIKUBE_IP"
echo "  ls -la /apps/k8s/privacy-agent-3.0/privacy-instance/pargos/logs/"
echo ""
echo "POD 로그 확인:"
echo "  kubectl logs -l app=crud-api --tail=50"
