#!/bin/bash
set -euo pipefail
echo "====================================="
echo "🗄️ 安装 MySQL 高可用（双兼容）"
echo "====================================="

if ! command -v docker &>/dev/null; then
  curl -fsSL https://get.docker.com | bash
fi

docker pull mysql:8
docker rm -f mysql-ha 2>/dev/null || true

docker run -d \
  --name mysql-ha \
  --restart=always \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=NewAPI@2025 \
  mysql:8 --default-authentication-plugin=mysql_native_password

sleep 5

if docker exec mysql-ha mysqladmin ping --silent; then
  echo "✅ MySQL 运行成功"
else
  echo "❌ MySQL 启动失败"
  exit 1
fi
