#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/../.env"

GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $*"; }; error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }
log "🚀 同步全球配置..."

for region in cn us eu ap; do
  REGION_ID=$(echo $region | sed 's/cn/1/;s/us/2/;s/eu/3/;s/ap/4/')
  TARGET_IP="100.64.${REGION_ID}.100"
  curl -k -X POST "https://$TARGET_IP:8443/api/v1/config/sync" \
    -H "Authorization: Bearer $GLOBAL_SYNC_TOKEN" \
    -d '{"action":"update_channels"}' >/dev/null
  log "✅ 同步 $region 完成"
done
