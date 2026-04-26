#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/../.env"

GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $*"; }; error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }
log "🚀 部署可观测栈 (VM + Grafana + Loki + Alertmanager)..."

# VictoriaMetrics
docker run -d --name victoria-metrics -p 8428:8428 -v /opt/monitoring/vm:/victoria-metrics-data \
  victoriametrics/victoria-metrics:latest -retentionPeriod=30d >/dev/null

# Grafana
docker run -d --name grafana -p 3000:3000 -v /opt/monitoring/grafana:/var/lib/grafana \
  -e GF_SECURITY_ADMIN_PASSWORD=$GRAFANA_ADMIN_PASS grafana/grafana-oss:latest >/dev/null

# Loki
docker run -d --name loki -p 3100:3100 -v /opt/monitoring/loki:/loki grafana/loki:2.9.0 >/dev/null

# Alertmanager (钉钉告警)
docker run -d --name alertmanager -p 9093:9093 -v /opt/monitoring/alertmanager:/alertmanager prom/alertmanager:latest >/dev/null
cat > /opt/monitoring/alertmanager/alertmanager.yml << EOF
route:
  group_by: ['alertname']
  receiver: 'dingtalk'
receivers:
  - name: 'dingtalk'
    webhook_configs:
      - url: '$DINGTALK_WEBHOOK'
        send_resolved: true
EOF

log "✅ 可观测栈部署完成！Grafana: http://$(hostname -I | awk '{print $1}'):3000"
