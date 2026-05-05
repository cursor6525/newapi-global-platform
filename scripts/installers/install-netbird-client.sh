#!/bin/bash
set -euo pipefail
echo "====================================="
echo "🔗 安装 NetBird 客户端（双兼容）"
echo "====================================="

curl -fsSL https://pkgs.netbird.io/install.sh | bash

# 替换成你自己的 Setup Key
NETBIRD_SETUP_KEY="YOUR_SETUP_KEY"

nohup netbird up --setup-key $NETBIRD_SETUP_KEY >/dev/null 2>&1 &
sleep 5

if ip a show wt0 >/dev/null 2>&1; then
  echo "✅ NetBird 客户端已接入组网"
else
  echo "❌ NetBird 客户端启动失败"
  exit 1
fi
