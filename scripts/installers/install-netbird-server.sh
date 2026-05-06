#!/bin/bash
set -euo pipefail
echo "====================================="
echo "🚀 安装 K3s Server（腾讯云专用版）"
echo "====================================="

# 关闭防火墙、关闭交换分区
ufw disable 2>/dev/null || true
systemctl stop firewalld 2>/dev/null || true
swapoff -a
sed -i '/swap/s/^/#/' /etc/fstab 2>/dev/null

# 安装 K3s（标准服务器模式）
curl -sfL https://get.k3s.io | sh -s server \
  --write-kubeconfig-mode 644 \
  --disable traefik \
  --disable servicelb \
  --disable local-storage

# 等待启动
sleep 10

# 验证
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
if kubectl get nodes >/dev/null 2>&1; then
  echo "✅ K3s 安装成功！"
  kubectl get nodes
else
  echo "❌ K3s 启动失败"
  exit 1
fi
