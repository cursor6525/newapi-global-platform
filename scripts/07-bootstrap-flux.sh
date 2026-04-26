#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/../.env"

GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $*"; }; error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }
log "🚀 引导 FluxCD GitOps..."

curl -s https://fluxcd.io/install.sh | bash >/dev/null

flux bootstrap git \
  --url=https://github.com/$GITHUB_USER/newapi-global-platform.git \
  --branch=main \
  --path=./clusters \
  --personal \
  --token-auth >/dev/null

log "✅ FluxCD 引导完成！配置变更将自动同步到集群"
