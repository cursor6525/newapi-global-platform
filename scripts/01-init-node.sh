#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/../.env"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
HOSTNAME="${HOSTNAME:-$(hostname)}"; IS_HOME="${IS_HOME:-false}"

log() { echo -e "${GREEN}[INFO]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# 幂等检查
if [[ -f /etc/newapi-node-initialized ]]; then
  log "节点 $HOSTNAME 已初始化，跳过重复执行"
  exit 0
fi

log "🚀 开始初始化节点: $HOSTNAME (家宽模式: $IS_HOME)"

# 1. 系统基础配置
log "🔧 配置系统基础环境..."
systemctl stop firewalld 2>/dev/null || true; setenforce 0 2>/dev/null || true
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config 2>/dev/null || true

# 时间同步
if command -v apt-get &>/dev/null; then apt update -qq >/dev/null && apt install -y -qq ntpdate >/dev/null
else yum install -y -q ntpdate >/dev/null; fi
ntpdate ntp.aliyun.com 2>/dev/null || warn "时间同步失败"
echo "*/30 * * * * root ntpdate ntp.aliyun.com >/dev/null 2>&1" >> /etc/crontab

# 2. 安装基础依赖
log "📦 安装基础依赖..."
if command -v apt-get &>/dev/null; then
  apt install -y -qq git ansible docker.io wget curl net-tools apt-transport-https ca-certificates gnupg lsb-release >/dev/null
  mkdir -p /etc/containerd; containerd config default > /etc/containerd/config.toml 2>/dev/null || true
  sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml; systemctl restart containerd
else
  yum install -y -q git ansible docker wget curl net-tools >/dev/null
fi

# 关闭 Swap + 内核优化
swapoff -a; sed -i '/^[^#].*swap.*/s/^/#/' /etc/fstab 2>/dev/null || true
cat > /etc/sysctl.d/99-k8s.conf << 'EOF'
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
vm.swappiness = 0
EOF
sysctl --system >/dev/null

# 家宽节点提示
if [[ "$IS_HOME" == "true" ]]; then
  warn "🏠 家宽节点请确保：1. 路由器端口映射 (6443/443/3478) 2. 动态 DNS 配置 3. 测试 Master 连通性"
fi

touch /etc/newapi-node-initialized; log "✅ 节点 $HOSTNAME 初始化完成！"
