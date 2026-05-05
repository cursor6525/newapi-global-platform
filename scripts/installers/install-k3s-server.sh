#!/bin/bash
set -euo pipefail
echo "====================================="
echo "🚀 安装 K3s Server 集群控制面"
echo "====================================="

systemctl stop firewalld ufw 2>/dev/null || true
swapoff -a 2>/dev/null

curl -sfL https://get.k3s.io | sh -s server \
  --write-kubeconfig-mode 644 \
  --disable traefik \
  --disable local-storage \
  --disable servicelb

sleep 3
systemctl restart k3s
sleep 2

if k3s ctr version >/dev/null 2>&1; then
  echo "✅ K3s 服务端安装成功"
else
  echo "❌ K3s 安装失败"
  exit 1
fi
