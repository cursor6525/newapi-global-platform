#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/../.env"

REGION="${1:-cn}"; ROLE="${2:-master}"; VIP="${3:-192.168.1.200}"
REGION_ID=$(echo "$REGION" | sed 's/cn/1/;s/us/2/;s/eu/3/;s/ap/4/')
BASE_IP="100.64.${REGION_ID}"; GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $*"; }; error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }
log "🚀 部署 ${REGION^^} 边缘节点 (角色: $ROLE)..."

# 安装 OpenResty (集成 Lua WAF)
if command -v apt-get &>/dev/null; then apt install -y -qq openresty openresty-openssl-devel >/dev/null
else yum install -y -q openresty openresty-openssl-devel >/dev/null; fi

# 配置 Nginx + Lua WAF
cat > /usr/local/openresty/nginx/conf/nginx.conf << EOF
worker_processes auto;
events { worker_connections 1024; }
http {
  include mime.types; default_type application/octet-stream; sendfile on; keepalive_timeout 65;

  lua_package_path "/usr/local/openresty/lualib/?.lua;;";
  lua_shared_dict limit 10m;
  server {
    listen 80; listen 443 ssl http2; server_name ${REGION}.newapi.global;
    ssl_certificate /etc/nginx/ssl/fullchain.pem; ssl_certificate_key /etc/nginx/ssl/privkey.pem;

    location / {
      proxy_set_header X-User-Region \$geoip2_data_country_code;
      proxy_pass http://${BASE_IP}.100:80;
    }

    access_by_lua_block {
      local waf = require "resty.waf"; local w = waf:new()
      w:rule("CC", {interval=60, count=100, action="deny"})
      w:rule("Bot", {action="deny"}); w:process()
    }
  }
}
EOF

# 配置 Keepalived 双机热备
cat > /etc/keepalived/keepalived.conf << EOF
! Configuration File for keepalived
global_defs { router_id EDGE_${REGION}_${ROLE} }
vrrp_instance VI_1 {
  state ${ROLE}; interface eth0; virtual_router_id 51;
  priority $([[ "$ROLE" == "master" ]] && echo 100 || echo 90); advert_int 1;
  authentication { auth_type PASS; auth_pass 1111 }; virtual_ipaddress { $VIP }
}
EOF

systemctl enable --now openresty keepalived; log "✅ ${REGION^^} 边缘节点部署完成！VIP: $VIP"
