#!/bin/bash
set -euo pipefail
echo "====================================="
echo "🚀 安装 K3s Server（容器/云IDE专用极简版）"
echo "====================================="

# 清理残留
pkill -9 k3s || true
rm -rf /var/lib/rancher/k3s /etc/rancher/k3s 2>/dev/null || true

# 官方安装（跳过所有额外配置，仅核心组件）
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644 --disable traefik --disable servicelb --disable local-storage" sh -

# 等待服务启动
sleep 15

# 验证
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
if kubectl get nodes --request-timeout=5s >/dev/null 2>&1; then
  echo "✅ K3s 安装成功！"
  kubectl get nodes
else
  echo "❌ K3s 启动失败"
  exit 1
fi
