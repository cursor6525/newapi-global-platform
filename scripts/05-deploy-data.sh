#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/../.env"

REGION="${1:-cn}"; REGION_ID=$(echo "$REGION" | sed 's/cn/1/;s/us/2/;s/eu/3/;s/ap/4/')
BASE_IP="100.64.${REGION_ID}"; GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $*"; }; error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }
log "🚀 部署 ${REGION^^} 数据层 (MySQL + Redis)..."

# MySQL 主从 (Docker)
docker run -d --name mysql-master -p 3306:3306 -v /opt/mysql/master:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=$DB_ROOT_PASS mysql:8.0 --server-id=1 --log-bin=mysql-bin --gtid-mode=ON >/dev/null
docker run -d --name mysql-slave -p 3307:3306 -v /opt/mysql/slave:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=$DB_ROOT_PASS mysql:8.0 --server-id=2 --relay-log=mysql-relay-bin --read-only=ON >/dev/null

# Redis 哨兵
docker run -d --name redis-master -p 6379:6379 -e REDIS_PASSWORD=$REDIS_PASS redis:7-alpine --appendonly yes >/dev/null
docker run -d --name redis-sentinel -p 26379:26379 redis:7-alpine redis-sentinel /usr/local/etc/redis/sentinel.conf \
  --sentinel monitor mymaster 127.0.0.1 6379 2 >/dev/null

# Orchestrator 自动故障转移
docker run -d --name orchestrator --net=host \
  -e ORCHESTRATOR_USER=root -e ORCHESTRATOR_PASSWORD=$DB_ROOT_PASS openark/orchestrator:latest >/dev/null

log "✅ ${REGION^^} 数据层部署完成！主库: $BASE_IP.10, 从库: $BASE_IP.11"
