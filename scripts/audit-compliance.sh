#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/../.env"

REGION="${1:-cn}"; REGION_ID=$(echo "$REGION" | sed 's/cn/1/;s/us/2/;s/eu/3/;s/ap/4/')
BASE_IP="100.64.${REGION_ID}"; GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $*"; }; error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }
log "🚀 审计 ${REGION^^} 区域数据合规..."

# 1. 数据库连接校验
DB_CONN=$(kubectl get deploy newapi -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="DB_HOST")].value}' 2>/dev/null || echo "未配置")
if [[ "$DB_CONN" == "$BASE_IP.10" ]]; then log "✅ 数据库本地连接: $DB_CONN"; else error "❌ 数据库未指向本地: $DB_CONN"; fi

# 2. NetBird ACL 校验
if netbird mgmt list acls 2>/dev/null | grep -q "deny-cross-region"; then log "✅ 跨区拦截策略生效"; else error "❌ ACL 策略未生效"; fi

# 3. 备份路径校验
BACKUP_PATH="/opt/backup/newapi-${REGION}"
if [[ -d "$BACKUP_PATH" ]]; then log "✅ 备份路径本地化: $BACKUP_PATH"; else error "❌ 备份路径未创建"; fi

log "✅ ${REGION^^} 合规审计通过！"
