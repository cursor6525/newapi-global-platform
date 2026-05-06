#!/bin/bash
set -euo pipefail

echo "====================================="
echo "✅ NewAPI 认证版 K3s Server 安装脚本"
echo "====================================="

# 1. 验证 containerd（NewAPI 强制要求）
if ! command -v containerd &>/dev/null; then
  echo "❌ Fatal: containerd 未安装！请先运行 'sudo apt install -y containerd'"
  exit 1
fi
if ! sudo systemctl is-active --quiet containerd; then
  echo "❌ Fatal: containerd 未运行！请运行 'sudo systemctl start containerd'"
  exit 1
fi

# 2. 检查端口占用（NewAPI 标准端口）
for port in 6443 10250 8080; do
  if ss -tuln | grep -q ":$port"; then
    echo "❌ Port $port 已被占用，请释放后重试"
    exit 1
  fi
done

# 3. 直接安装 K3s（无 Docker、无 swap、纯 containerd）
curl -sfL https://get.k3s.io | \
  INSTALL_K3S_VERSION=v1.31.3+k3s2 \
  INSTALL_K3S_EXEC="server \
    --disable servicelb,traefik,local-storage,metrics-server \
    --tls-san 10.138.0.2 \
    --tls-san free-tier-vm \
    --write-kubeconfig-mode 644 \
    --node-label role.kubernetes.io/control-plane=true \
    --node-taint CriticalAddonsOnly=true:NoExecute" \
  sh -

# 4. 等待就绪（带超时保护）
timeout 120s bash -c '
  while ! sudo k3s kubectl get nodes >/dev/null 2>&1; do
    echo "⏳ 等待 K3s 就绪... (max 120s)"
    sleep 5
  done
  echo "✅ K3s 控制面已就绪！"
'

# 5. 输出关键信息（NewAPI 资产清单格式）
echo ""
echo "📋 NewAPI 资产摘要："
echo "- API Server: https://10.138.0.2:6443"
echo "- Kubeconfig: /etc/rancher/k3s/k3s.yaml (mode 644)"
echo "- Node Name: $(sudo k3s kubectl get node -o jsonpath='{.items[0].metadata.name}')"
echo "- Version: $(sudo k3s --version)"
