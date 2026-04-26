#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/../.env"

REGION="${1:-cn}"; REGION_ID=$(echo "$REGION" | sed 's/cn/1/;s/us/2/;s/eu/3/;s/ap/4/')
BASE_IP="100.64.${REGION_ID}"; GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $*"; }; error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }
log "🚀 备份 ${REGION^^} 区域 MySQL..."

# 备份主库 + 压缩
mysqldump -h $BASE_IP.10 -u root -p$DB_ROOT_PASS newapi_${REGION} | gzip > /tmp/newapi_${REGION}_$(date +%Y%m%d).sql.gz

# 上传到对象存储 (Rclone)
rclone copy /tmp/newapi_${REGION}_*.sql.gz "s3:newapi-backup-${REGION}/daily/" --bwlimit 2M >/dev/null

# 清理旧备份 (本地 3 天 + 云端 30 天)
find /tmp -name "newapi_${REGION}_*.sql.gz" -mtime +3 -delete
rclone delete "s3:newapi-backup-${REGION}/daily/" --min-age 30d >/dev/null

log "✅ ${REGION^^} MySQL 备份完成！"
