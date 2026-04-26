#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/../.env"

REGION="${1:-cn}"; REGION_ID=$(echo "$REGION" | sed 's/cn/1/;s/us/2/;s/eu/3/;s/ap/4/')
BASE_IP="100.64.${REGION_ID}"; GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $*"; }; error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }
log "🚀 初始化 ${REGION^^} 区域 K8s 控制面..."

# 安装 K8s 组件
if command -v apt-get &>/dev/null; then apt install -y -qq kubeadm kubelet kubectl >/dev/null
else yum install -y -q kubeadm kubelet kubectl >/dev/null; fi
systemctl enable --now kubelet

# 初始化集群
kubeadm init \
  --pod-network-cidr=192.168.0.0/16 \
  --apiserver-advertise-address="${BASE_IP}.1" \
  --ignore-preflight-errors=Swap >/dev/null

# 配置 kubectl
mkdir -p $HOME/.kube; cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

# 安装 Calico 网络插件
kubectl apply -f https://docs.projectcalico.org/v3.24/manifests/calico.yaml >/dev/null

# etcd 定时备份
crontab -l | { cat; echo "0 2 * * * /usr/local/bin/etcd-backup.sh >/dev/null 2>&1"; } | crontab -

log "✅ ${REGION^^} 控制面初始化完成！保存 join 命令供 Worker 使用:"
kubeadm token create --print-join-command
