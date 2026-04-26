#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/../.env"

MASTER_IP="${1:-192.168.1.100}"; TOKEN="${2:-}"; REGION="${3:-cn}"; POOL="${4:-compute}"
GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $*"; }; error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

if [[ -z "$MASTER_IP" || -z "$TOKEN" ]]; then error "❌ 参数缺失: master_ip 和 token 必填"; fi
log "🚀 加入 ${REGION^^} 区域 ${POOL} 池..."

# 加入 K8s 集群
kubeadm join $MASTER_IP:6443 --token $TOKEN --discovery-token-unsafe-skip-ca-verification --ignore-preflight-errors=all >/dev/null
until kubectl get node $(hostname) 2>/dev/null | grep -q Ready; do sleep 3; done

# 打标 (地域+资源池)
kubectl label node $(hostname) "region=$REGION" "pool=$POOL" --overwrite 2>/dev/null

# NetBird 加入 (可选)
if [[ "$NETBIRD_ENABLED" == "true" ]]; then
  curl -fsSL https://pkgs.netbird.io/install.sh | sh >/dev/null
  netbird up --management-url $NETBIRD_MGMT_URL --setup-key $NETBIRD_SETUP_KEY >/dev/null
  log "✅ NetBird 加入完成！IP: $(ip -4 addr show wt0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}')"
fi

log "✅ 节点加入成功！类型: $POOL | 地域: $REGION"
