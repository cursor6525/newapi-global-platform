#!/bin/bash
set -euo pipefail
echo "====================================="
echo "⚡ 安装 Redis 哨兵模式"
echo "====================================="

if ! command -v docker &> /dev/null; then
  curl -fsSL https://get.docker.com | bash
  systemctl enable --now docker
fi

docker pull redis:alpine
docker rm -f redis-sentinel 2>/dev/null || true

docker run -d \
  --name redis-sentinel \
  --restart=always \
  -p 6379:6379 \
  redis:alpine redis-server --requirepass NewAPI@2025

sleep 3

if docker exec redis-sentinel redis-cli -a NewAPI@2025 ping | grep -q PONG; then
  echo "✅ Redis 运行成功"
else
  echo "❌ Redis 启动失败"
  exit 1
fi
