#!/bin/bash
set -euo pipefail
echo "====================================="
echo "🚀 安装 K3s Server（无 systemd 容器专用版）"
echo "====================================="

# 1. 环境准备
swapoff -a 2>/dev/null || true
mkdir -p /var/log /etc/rancher/k3s
rm -f /var/run/k3s/*.pid /var/lib/rancher/k3s/server/lock 2>/dev/null || true

# 2. 安装 Docker（容器必备）
if ! command -v docker &>/dev/null; then
  echo "安装 Docker..."
  curl -fsSL https://get.docker.com | bash
fi

# 3. 安装 K3s 二进制（不依赖 systemd）
echo "下载 K3s..."
curl -sfL https://get.k3s.io | INSTALL_K3S_SKIP_ENABLE=true INSTALL_K3S_SKIP_START=true sh -s server \
  --docker \
  --write-kubeconfig-mode 644 \
  --disable traefik \
  --disable local-storage \
  --disable servicelb

# 4. 手动后台启动（关键！绕过 systemd）
echo "启动 K3s 服务..."
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
nohup k3s server \
  --docker \
  --write-kubeconfig-mode 644 \
  --disable traefik \
  --disable local-storage \
  --disable servicelb \
  > /var/log/k3s.log 2>&1 &

# 5. 强制等待并验证（解决假成功问题）
echo "等待服务启动（最长 30 秒）..."
for i in {1..30}; do
  if kubectl get nodes --request-timeout=1s >/dev/null 2>&1; then
    echo "✅ K3s 启动成功！"
    kubectl get nodes
    exit 0
  fi
  sleep 1
done

# 超时失败处理
echo "❌ K3s 启动失败！"
echo "日志输出："
cat /var/log/k3s.log
exit 1
