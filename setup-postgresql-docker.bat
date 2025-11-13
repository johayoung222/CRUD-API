@echo off
REM ================================================================================
REM PostgreSQL Docker 환경 설정 스크립트 (Windows용)
REM ================================================================================
echo ==========================================
echo PostgreSQL 데이터베이스 설정 시작
echo ==========================================
echo.

REM Docker 컨테이너 확인
echo 1. Docker 컨테이너 상태 확인...
docker ps -f name=postgres
if %ERRORLEVEL% NEQ 0 (
    echo 오류: Docker 컨테이너 'postgres'를 찾을 수 없습니다.
    echo Docker Compose로 PostgreSQL을 먼저 시작해주세요.
    pause
    exit /b 1
)
echo.

REM SQL 스크립트 실행
echo 2. 데이터베이스 및 테이블 생성...
docker exec -i postgres psql -U postgres < setup-postgresql-docker.sql
if %ERRORLEVEL% NEQ 0 (
    echo 오류: SQL 스크립트 실행에 실패했습니다.
    pause
    exit /b 1
)
echo.

echo 3. 연결 테스트...
docker exec -i postgres psql -U cruduser -d cruddb -c "SELECT COUNT(*) as product_count FROM products;"
echo.

echo ==========================================
echo PostgreSQL 설정 완료!
echo ==========================================
echo.
echo 데이터베이스 정보:
echo   호스트: 192.168.1.55
echo   포트: 5432
echo   데이터베이스: cruddb
echo   사용자: cruduser
echo   비밀번호: crudpass123
echo.
echo Spring Boot 애플리케이션을 실행할 준비가 되었습니다!
echo.
pause
