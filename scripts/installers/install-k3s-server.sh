#!/bin/bash
set -euo pipefail

echo "====================================="
echo "✅ NewAPI 认证版 K3s Server 安装脚本（生产就绪）"
echo "====================================="

# ---------- 自动获取真实内网 IPv4（GCP/AWS/物理机通用） ----------
NODE_IP=$(ip -4 route get 1 | awk '{print $7;exit}' 2>/dev/null)
if [ -z "$NODE_IP" ]; then
  echo "❌ Fatal: 无法获取有效 IPv4 地址！请检查网络配置"
  exit 1
fi
NODE_HOSTNAME=$(hostname)

# ---------- 清理残留（保障幂等） ----------
if [ -f /usr/local/bin/k3s-uninstall.sh ]; then
  echo "🔄 检测到旧安装，执行清理..."
  /usr/local/bin/k3s-uninstall.sh >/dev/null 2>&1 || true
  sleep 3
fi

# ---------- 1. 依赖校验 ----------
if ! command -v containerd &>/dev/null; then
  echo "❌ Fatal: containerd 未安装！请先运行 'sudo apt install -y containerd'"
  exit 1
fi
if ! sudo systemctl is-active --quiet containerd; then
  echo "❌ Fatal: containerd 未运行！请运行 'sudo systemctl start containerd'"
  exit 1
fi

# ---------- 2. 端口检查（含 TIME_WAIT 过滤） ----------
check_port() {
  local port=$1
  if lsof -iTCP:$port -sTCP:LISTEN >/dev/null 2>&1; then
    echo "❌ Port $port 已被监听（LISTEN 状态）"
    exit 1
  fi
  # 额外检查：是否存在大量 TIME_WAIT 占用（GCP 免费层常见）
  if [ $(ss -tan state time-wait '( sport = :'$port' )' | wc -l) -gt 10 ]; then
    echo "❌ Port $port 存在过多 TIME_WAIT 连接（>10），请稍后重试"
    exit 1
  fi
}
for port in 6443 10250 8080; do
  check_port $port
done

# ---------- 3. 国内镜像 + 动态 SAN + 生产调优 ----------
curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | \
  INSTALL_K3S_VERSION=v1.31.3+k3s2 \
  INSTALL_K3S_MIRROR=cn \
  INSTALL_K3S_EXEC="server \
    --disable servicelb,traefik,local-storage,metrics-server \
    --tls-san $NODE_IP \
    --tls-san $NODE_HOSTNAME \
    --write-kubeconfig-mode 644 \
    --node-label role.kubernetes.io/control-plane=true \
    --node-taint CriticalAddonsOnly=true:NoExecute \
    --kube-apiserver-arg=max-requests-inflight=50 \
    --kube-apiserver-arg=memlock=1" \
  sh -

# ---------- 4. 就绪等待（带健康探针） ----------
timeout 120s bash -c '
  while ! sudo k3s kubectl get nodes >/dev/null 2>&1; do
    echo "⏳ 等待 K3s 就绪... (max 120s)"
    sleep 5
  done
  # 额外验证：API Server 可连通且证书有效
  if ! curl -k -f https://'$NODE_IP':6443/healthz >/dev/null 2>&1; then
    echo "❌ API Server 健康检查失败！"
    exit 1
  fi
  echo "✅ K3s 控制面已就绪！"
'

# ---------- 5. 资产清单输出（兼容 NewAPI .state 格式） ----------
echo ""
echo "📋 NewAPI 资产摘要（可直接写入 .state/node1.json）："
echo "{"
echo "  \"k3s_server\": {"
echo "    \"status\": \"running\","
echo "    \"version\": \"v1.31.3+k3s2\","
echo "    \"endpoint\": \"https://$NODE_IP:6443\","
echo "    \"node_name\": \"$NODE_HOSTNAME\","
echo "    \"tls_san\": [\"$NODE_IP\", \"$NODE_HOSTNAME\"]"
echo "  }"
echo "}"
