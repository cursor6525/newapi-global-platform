#!/bin/bash
set -euo pipefail
echo "====================================="
echo "📊 安装监控系统 (Node Exporter)"
echo "====================================="

if ! command -v docker &> /dev/null; then
  curl -fsSL https://get.docker.com | bash
  systemctl enable --now docker
fi

docker pull prom/node-exporter:latest
docker rm -f node-exporter 2>/dev/null || true

docker run -d \
  --name node-exporter \
  --net=host \
  --pid=host \
  --restart=always \
  -v /:/host:ro,rslave \
  prom/node-exporter:latest \
  --path.rootfs=/host

sleep 2
echo "✅ 节点监控已部署"
