#!/bin/bash
set -euo pipefail
echo "====================================="
echo "🌐 安装 NetBird 服务端（双兼容）"
echo "====================================="

curl -fsSL https://pkgs.netbird.io/install.sh | bash

nohup netbird up >/dev/null 2>&1 &
sleep 5

if ip a show wt0 >/dev/null 2>&1; then
  echo "✅ NetBird 服务端运行正常"
else
  echo "❌ NetBird 启动失败"
  exit 1
fi
