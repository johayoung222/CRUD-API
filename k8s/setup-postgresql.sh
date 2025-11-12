#!/bin/bash
# PostgreSQL 데이터베이스 및 테이블 생성 스크립트
# 192.168.1.55 서버에서 실행하세요

set -e

DB_NAME="cruddb"
DB_USER="cruduser"
DB_PASS="crudpass123"

echo "=========================================="
echo "PostgreSQL 데이터베이스 설정 시작"
echo "=========================================="

# PostgreSQL이 설치되어 있는지 확인
if ! command -v psql &> /dev/null; then
    echo "오류: PostgreSQL이 설치되어 있지 않습니다."
    echo "다음 명령어로 설치하세요:"
    echo "  yum install -y postgresql-server postgresql-contrib"
    echo "  postgresql-setup --initdb"
    echo "  systemctl start postgresql"
    echo "  systemctl enable postgresql"
    exit 1
fi

echo "1. 데이터베이스 및 사용자 생성..."
sudo -u postgres psql <<EOF
-- 데이터베이스 생성
CREATE DATABASE ${DB_NAME};

-- 사용자 생성
CREATE USER ${DB_USER} WITH PASSWORD '${DB_PASS}';

-- 권한 부여
GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} TO ${DB_USER};

-- 연결 확인
\c ${DB_NAME}
GRANT ALL ON SCHEMA public TO ${DB_USER};
EOF

echo ""
echo "2. 테이블 생성..."
PGPASSWORD=${DB_PASS} psql -U ${DB_USER} -d ${DB_NAME} <<'EOF'
-- products 테이블 생성
CREATE TABLE IF NOT EXISTS products (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DOUBLE PRECISION NOT NULL,
    quantity INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_products_name ON products(name);
CREATE INDEX IF NOT EXISTS idx_products_created_at ON products(created_at);

-- 샘플 데이터 삽입
INSERT INTO products (name, description, price, quantity, created_at, updated_at) VALUES
('노트북', '고성능 노트북', 1500000.00, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('마우스', '무선 마우스', 35000.00, 50, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('키보드', '기계식 키보드', 120000.00, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT DO NOTHING;

-- 생성된 테이블 확인
\dt
SELECT * FROM products;
EOF

echo ""
echo "3. PostgreSQL 외부 접근 설정 확인..."
PG_HBA_FILE=$(sudo -u postgres psql -t -P format=unaligned -c 'SHOW hba_file;')
echo "pg_hba.conf 위치: $PG_HBA_FILE"
echo ""
echo "다음 설정이 있는지 확인하세요:"
echo "  host    all             all             192.168.1.0/24          md5"
echo ""
echo "설정이 없다면 추가 후 PostgreSQL을 재시작하세요:"
echo "  sudo systemctl restart postgresql"

echo ""
echo "4. 연결 테스트..."
echo "다음 명령어로 연결을 테스트할 수 있습니다:"
echo "  PGPASSWORD=${DB_PASS} psql -h 192.168.1.55 -U ${DB_USER} -d ${DB_NAME} -c 'SELECT COUNT(*) FROM products;'"

echo ""
echo "=========================================="
echo "PostgreSQL 설정 완료!"
echo "=========================================="
echo ""
echo "데이터베이스 정보:"
echo "  호스트: 192.168.1.55"
echo "  포트: 5432"
echo "  데이터베이스: ${DB_NAME}"
echo "  사용자: ${DB_USER}"
echo "  비밀번호: ${DB_PASS}"
