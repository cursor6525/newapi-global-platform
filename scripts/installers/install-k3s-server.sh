#!/bin/bash
set -euo pipefail
echo "====================================="
echo "🚀 安装 K3s Server（双兼容自动模式）"
echo "====================================="

swapoff -a 2>/dev/null
mkdir -p /var/log

# 自动检测是否有 systemd
HAS_SYSTEMD=1
if ! pidof systemd >/dev/null 2>&1; then
  HAS_SYSTEMD=0
fi

# 安装 Docker（必备）
if ! command -v docker &>/dev/null; then
  curl -fsSL https://get.docker.com | bash
fi

# 安装 K3s
curl -sfL https://get.k3s.io | sh -s server \
  --docker \
  --write-kubeconfig-mode 644 \
  --disable traefik \
  --disable local-storage \
  --disable servicelb

# 无 systemd 则手动后台启动
if [ $HAS_SYSTEMD -eq 0 ]; then
  nohup k3s server > /var/log/k3s.log 2>&1 &
  sleep 10
fi

# 验证
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
if kubectl get nodes >/dev/null 2>&1; then
  echo "✅ K3s 启动成功！"
else
  echo "❌ K3s 启动失败"
  cat /var/log/k3s.log 2>/dev/null
  exit 1
fi
