#!/bin/bash
set -euo pipefail
echo "====================================="
echo "🌐 安装 NetBird 服务端"
echo "====================================="

curl -fsSL https://pkgs.netbird.io/install.sh | bash

nohup netbird up >/dev/null 2>&1 &
sleep 5

ip a show wt0 >/dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "✅ NetBird 服务端运行成功"
else
  echo "❌ NetBird 启动失败"
  exit 1
fi
