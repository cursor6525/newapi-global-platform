#!/bin/bash
set -euo pipefail
echo "====================================="
echo "🌐 安装 NetBird 服务端（避坑离线版）"
echo "====================================="

# 只装依赖，不挂外部镜像
apt update -y
apt install -y ca-certificates gnupg2 curl -y

# 官方源直连，不用国内镜像
curl -fsSL https://pkgs.netbird.io/install.sh | bash -s -- --no-ui

# 后台拉起
nohup netbird up >/dev/null 2>&1 &
sleep 4

# 验证网卡 wt0
if ip link show wt0 2>/dev/null; then
  echo "✅ NetBird 服务端安装 & 组网网卡就绪"
else
  echo "❌ NetBird 启动后无 wt0 网卡"
  exit 1
fi
