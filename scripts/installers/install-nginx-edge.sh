#!/bin/bash
set -euo pipefail
echo "====================================="
echo "🌍 安装 Nginx 边缘网关（双兼容）"
echo "====================================="

if command -v apt &>/dev/null; then
  apt update -y
  apt install -y nginx
elif command -v yum &>/dev/null; then
  yum install -y nginx
fi

# 后台启动（兼容无systemd）
nohup nginx >/dev/null 2>&1 &
sleep 2

if pgrep nginx >/dev/null 2>&1; then
  echo "✅ Nginx 启动成功"
else
  echo "❌ Nginx 启动失败"
  exit 1
fi
