#!/bin/bash
set -euo pipefail
echo "====================================="
echo "🌐 安装 NetBird 服务端（国内加速版）"
echo "====================================="

# 国内加速安装（不卡死）
curl -fsSL https://mirror.ghproxy.com/https://pkgs.netbird.io/install.sh | bash

nohup netbird up >/dev/null 2>&1 &
sleep 3

if ip a show wt0 >/dev/null 2>&1; then
  echo "✅ NetBird 启动成功"
else
  echo "❌ NetBird 启动失败"
  exit 1
fi
