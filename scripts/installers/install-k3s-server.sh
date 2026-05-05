#!/bin/bash
set -euo pipefail
echo "====================================="
echo "🚀 K3s 安装（容器终极稳定版）"
echo "====================================="

# 杀死旧进程
pkill -9 k3s 2>/dev/null || true
rm -rf /var/lib/rancher/k3s /etc/rancher/k3s 2>/dev/null || true
mkdir -p /etc/rancher/k3s

# 安装 Docker（必须）
if ! command -v docker &>/dev/null; then
  curl -fsSL https://get.docker.com | bash
fi

# 直接安装二进制（不装服务）
curl -sfL https://get.k3s.io | INSTALL_K3S_SKIP_ENABLE=true INSTALL_K3S_SKIP_START=true sh -

# 前台启动（容器唯一稳定方式）
echo "✅ 启动 K3s (前台运行，不会崩溃)"
k3s server \
  --docker \
  --write-kubeconfig-mode 644 \
  --https-listen-port=6443 \
  --disable traefik \
  --disable servicelb \
  --disable local-storage \
  --node-name=node-1
