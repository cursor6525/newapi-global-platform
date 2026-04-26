#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/../.env"

GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $*"; }; error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }
log "🚀 开始扩容节点向导..."

echo "请选择资源池: 1)算力 2)数据 3)网络"; read -p "输入 [1-3]: " pool_choice
declare -A pool_map=([1]="compute" [2]="data" [3]="network"); POOL="${pool_map[$pool_choice]:-compute}"

echo "请选择地域: 1)CN 2)US 3)EU 4)AP"; read -p "输入 [1-4]: " region_choice
declare -A region_map=([1]="cn" [2]="us" [3]="eu" [4]="ap"); REGION="${region_map[$region_choice]:-cn}"

log "执行扩容: 区域=$REGION | 资源池=$POOL"
bash "$(dirname "$0")/08-add-node.sh" "${REGION_BASE_IP:-100.64.1}.1" "${K8S_TOKEN}" "$REGION" "$POOL"

log "✅ 扩容完成！节点将自动调度业务"
