#!/bin/bash
set -euo pipefail
echo "====================================="
echo "🌍 安装 Nginx 边缘网关"
echo "====================================="

apt update -y
apt install -y nginx

systemctl enable --now nginx
sleep 2

if systemctl is-active --quiet nginx; then
  echo "✅ Nginx 启动成功"
else
  echo "❌ Nginx 启动失败"
  exit 1
fi
