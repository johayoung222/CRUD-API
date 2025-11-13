#!/bin/bash
# Auth API 테스트 스크립트

set -e

# Minikube IP 가져오기
MINIKUBE_IP=$(minikube ip)
BASE_URL="http://$MINIKUBE_IP:30080/api/auth"

echo "=========================================="
echo "Auth API 테스트"
echo "=========================================="
echo "Base URL: $BASE_URL"
echo ""

# ========================================
# 세션 기반 인증 테스트
# ========================================

echo "=========================================="
echo "1. 세션 기반 인증 테스트"
echo "=========================================="
echo ""

# Health Check
echo "1-1. Health Check..."
curl -s "$BASE_URL/health" | jq '.'
echo ""

# 세션 로그인
echo "1-2. 세션 로그인 (admin)..."
SESSION_RESPONSE=$(curl -s -c cookies.txt -X POST "$BASE_URL/session/login" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "admin123"
  }')
echo "$SESSION_RESPONSE" | jq '.'
echo ""

# 세션으로 현재 사용자 정보 조회
echo "1-3. 세션 기반 현재 사용자 정보 조회..."
curl -s -b cookies.txt "$BASE_URL/session/me" | jq '.'
echo ""

# 세션 인증 확인
echo "1-4. 세션 인증 확인..."
curl -s -b cookies.txt "$BASE_URL/session/check" | jq '.'
echo ""

# 세션 로그아웃
echo "1-5. 세션 로그아웃..."
curl -s -b cookies.txt -X POST "$BASE_URL/session/logout" | jq '.'
echo ""

# 로그아웃 후 인증 확인
echo "1-6. 로그아웃 후 인증 확인..."
curl -s -b cookies.txt "$BASE_URL/session/check" | jq '.'
echo ""

# 쿠키 파일 삭제
rm -f cookies.txt

# ========================================
# Redis 기반 인증 테스트
# ========================================

echo "=========================================="
echo "2. Redis 기반 인증 테스트"
echo "=========================================="
echo ""

# Redis 로그인
echo "2-1. Redis 로그인 (testuser)..."
REDIS_RESPONSE=$(curl -s -X POST "$BASE_URL/redis/login" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "test123"
  }')
echo "$REDIS_RESPONSE" | jq '.'

# 세션 토큰 추출
SESSION_TOKEN=$(echo "$REDIS_RESPONSE" | jq -r '.sessionId')
echo "Session Token: $SESSION_TOKEN"
echo ""

# Redis 세션으로 현재 사용자 정보 조회
echo "2-2. Redis 기반 현재 사용자 정보 조회..."
curl -s -H "X-Session-Token: $SESSION_TOKEN" "$BASE_URL/redis/me" | jq '.'
echo ""

# Redis 인증 확인
echo "2-3. Redis 인증 확인..."
curl -s -H "X-Session-Token: $SESSION_TOKEN" "$BASE_URL/redis/check" | jq '.'
echo ""

# Redis 세션 연장
echo "2-4. Redis 세션 연장..."
curl -s -H "X-Session-Token: $SESSION_TOKEN" -X POST "$BASE_URL/redis/extend" | jq '.'
echo ""

# Redis 로그아웃
echo "2-5. Redis 로그아웃..."
curl -s -H "X-Session-Token: $SESSION_TOKEN" -X POST "$BASE_URL/redis/logout" | jq '.'
echo ""

# 로그아웃 후 인증 확인
echo "2-6. 로그아웃 후 인증 확인..."
curl -s -H "X-Session-Token: $SESSION_TOKEN" "$BASE_URL/redis/check" | jq '.'
echo ""

# ========================================
# 인증 실패 테스트
# ========================================

echo "=========================================="
echo "3. 인증 실패 테스트"
echo "=========================================="
echo ""

# 잘못된 비밀번호로 로그인 시도
echo "3-1. 세션 로그인 실패 (잘못된 비밀번호)..."
curl -s -X POST "$BASE_URL/session/login" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "wrongpassword"
  }' | jq '.'
echo ""

# 존재하지 않는 사용자로 로그인 시도
echo "3-2. Redis 로그인 실패 (존재하지 않는 사용자)..."
curl -s -X POST "$BASE_URL/redis/login" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "nonexistent",
    "password": "test123"
  }' | jq '.'
echo ""

# 유효하지 않은 세션 토큰
echo "3-3. Redis 인증 실패 (유효하지 않은 토큰)..."
curl -s -H "X-Session-Token: invalid-token-12345" "$BASE_URL/redis/me"
echo ""

echo "=========================================="
echo "테스트 완료!"
echo "=========================================="
echo ""
echo "Redis 데이터 확인 (192.168.1.55 서버에서):"
echo "  redis-cli"
echo "  KEYS session:*"
echo "  TTL session:<token>"
echo ""
echo "Agent 로그 확인:"
echo "  ls -la /apps/k8s/privacy-agent-3.0/privacy-instance/pargos/logs/"
echo ""
echo "POD 로그 확인:"
echo "  kubectl logs -l app=crud-api --tail=50"
