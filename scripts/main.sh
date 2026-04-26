#!/bin/bash
set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'

echo -e "${CYAN}
╔══════════════════════════════════════════════════════════╗
║           🌍 NewAPI 全球化平台・运维控制台               ║
║          数据本地化 | NetBird零信任 | GitOps自动化       ║
╚══════════════════════════════════════════════════════════╝
${NC}"

while true; do
  echo -e "\n${YELLOW}请选择操作:${NC}"
  echo "  1) 🌐 部署区域集群 (CN/US/EU/AP)"
  echo "  2) ⚙️  扩容算力/数据/网络节点"
  echo "  3) 🔄 同步全球配置 (加密+审计)"
  echo "  4) 🛡️  执行合规审计 (数据不出境校验)"
  echo "  5) 📊 查看节点状态与告警"
  echo "  6) 📖 查看部署与扩容指南"
  echo "  0) 🚪 退出"
  read -p "请输入选项编号 [0-6]: " choice

  case $choice in
    1) bash "$(dirname "$0")/deploy-region.sh" ;;
    2) bash "$(dirname "$0")/scale-node.sh" ;;
    3) bash "$(dirname "$0")/sync-global.sh" ;;
    4) bash "$(dirname "$0")/audit-compliance.sh" ;;
    5) bash "$(dirname "$0")/check-status.sh" ;;
    6) echo -e "\n${CYAN}详细文档: docs/COMPLIANCE_AND_SCALING.md${NC}" ;;
    0) echo -e "\n${GREEN}✅ 退出控制台。感谢使用！${NC}"; exit 0 ;;
    *) echo -e "${RED}❌ 无效选项，请重新输入。${NC}" ;;
  esac
done
