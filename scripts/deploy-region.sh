#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/../.env"

REGION="${1:-cn}"; REGION_ID=$(echo "$REGION" | sed 's/cn/1/;s/us/2/;s/eu/3/;s/ap/4/')
BASE_IP="100.64.${REGION_ID}"; GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $*"; }; error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }
log "🚀 部署 ${REGION^^} 区域全量组件..."

# 1. 控制面
bash "$(dirname "$0")/02-init-master.sh" $REGION
# 2. 数据层
bash "$(dirname "$0")/05-deploy-data.sh" $REGION
# 3. 边缘层 (主+备)
bash "$(dirname "$0")/03-deploy-edge.sh" $REGION master 192.168.1.200
bash "$(dirname "$0")/03-deploy-edge.sh" $REGION backup 192.168.1.201
# 4. 可观测栈
bash "$(dirname "$0")/06-deploy-monitor.sh"
# 5. GitOps
bash "$(dirname "$0")/07-bootstrap-flux.sh"
# 6. 合规审计
bash "$(dirname "$0")/audit-compliance.sh" $REGION

log "✅ ${REGION^^} 区域部署完成！访问: http://192.168.1.200"
