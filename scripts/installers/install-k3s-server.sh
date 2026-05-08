cat > /opt/newapi-global-platform/scripts/installers/install-k3s-server.sh << 'EOF'
#!/bin/bash
set -euo pipefail

echo "====================================="
echo "🚀 安装 K3s Server（语法修复版）"
echo "====================================="

# 1. 自动获取本机IP和主机名
NODE_IP=$(hostname -I | awk '{print $1}')
NODE_HOSTNAME=$(hostname)

# 2. 端口检查
check_port() {
  local port=$1
  if ss -tuln | grep -Eq ":$port\s"; then
    echo "❌ Port $port 已被占用"
    exit 1
  fi
}
for port in 6443 10250; do
  check_port $port
done

# 3. 使用国内镜像安装K3s（无语法错误）
curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | \
  INSTALL_K3S_MIRROR=cn \
  INSTALL_K3S_EXEC="server \
    --disable traefik,metrics-server,servicelb,local-storage \
    --tls-san $NODE_IP \
    --tls-san $NODE_HOSTNAME \
    --write-kubeconfig-mode 644" \
  sh -

# 4. 等待就绪
timeout 120s bash -c '
  while ! kubectl get nodes >/dev/null 2>&1; do
    echo "⏳ 等待K3s就绪..."
    sleep 5
  done
'

echo "✅ K3s安装成功！"
kubectl get nodes
EOF
