#!/bin/bash
set -euo pipefail
echo "====================================="
echo "🚪 安装 NewAPI 网关（双兼容）"
echo "====================================="

if ! command -v docker &>/dev/null; then
  curl -fsSL https://get.docker.com | bash
fi

docker pull newapi/gateway:latest
docker rm -f newapi-gateway 2>/dev/null || true

docker run -d \
  --name newapi-gateway \
  --net=host \
  --restart=always \
  newapi/gateway:latest

sleep 3

if docker ps --filter "name=newapi-gateway" --filter "status=running" | grep -q newapi-gateway; then
  echo "✅ NewAPI 网关运行成功"
else
  echo "❌ NewAPI 网关启动失败"
  exit 1
fi
