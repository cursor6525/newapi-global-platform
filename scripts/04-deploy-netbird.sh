#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/../.env"

ROLE="${1:-client}"; GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $*"; }; error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }
log "🚀 部署 NetBird ${ROLE} 节点..."

if [[ "$ROLE" == "hub" ]]; then
  docker run -d --name netbird-hub --net=host --privileged \
    -e NB_DOMAIN=netbird.global -v /var/lib/netbird:/var/lib/netbird netbirdio/hub:latest >/dev/null
  log "✅ NetBird Hub 部署完成！Setup Key:"; docker exec -it netbird-hub netbird mgmt get setup-key
elif [[ "$ROLE" == "relay" ]]; then
  docker run -d --name netbird-relay --net=host --privileged \
    -e NB_RELAY_HUB=$NETBIRD_MGMT_URL -e NB_RELAY_SETUP_KEY=$NETBIRD_SETUP_KEY netbirdio/relay:latest >/dev/null
  log "✅ NetBird Relay 部署完成！"
else
  curl -fsSL https://pkgs.netbird.io/install.sh | sh >/dev/null
  netbird up --management-url $NETBIRD_MGMT_URL --setup-key $NETBIRD_SETUP_KEY >/dev/null
  log "✅ NetBird 客户端加入完成！IP: $(ip -4 addr show wt0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}')"
fi
