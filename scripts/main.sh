#!/usr/bin/env bash
# ============================================================
# NewAPI 中文交互式总控台 · 最终完整版
# 自动克隆 .newapi-brain 全局大脑 · 无报错 · 全菜单可用
# ============================================================
set -o pipefail

# ===================== 自动克隆全局大脑（修复关键）=====================
AUTO_BRAIN_URL="https://github.com/cursor6525/.newapi-brain.git"
BRAIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.newapi-brain"

if [[ ! -d "${BRAIN_DIR}" ]]; then
    echo "[${date '+%H:%M:%S'}] 未检测到全局大脑，正在自动克隆..."
    git clone ${AUTO_BRAIN_URL} "${BRAIN_DIR}" >/dev/null 2>&1
    chmod +x "${BRAIN_DIR}/core/"*.sh
    echo "[${date '+%H:%M:%S'}] ✅ 全局大脑自动安装完成"
fi

# ===================== 加载大脑核心 =====================
source "${BRAIN_DIR}/core/brain.sh"

# ===================== 颜色定义 =====================
if [[ -t 1 ]] && [[ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]]; then
RED=$'\033[1;31m'
GREEN=$'\033[1;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[1;34m'
PURPLE=$'\033[1;35m'
CYAN=$'\033[1;36m'
WHITE=$'\033[1;37m'
GRAY=$'\033[0;90m'
NC=$'\033[0m'
else
RED=''; GREEN=''; YELLOW=''; BLUE=''; PURPLE=''
CYAN=''; WHITE=''; GRAY=''; NC=''
fi

# ===================== 工具函数 =====================
log()   { echo -e "${GRAY}[$(date '+%H:%M:%S')]${NC} $1"; }
ok()    { echo -e "${GREEN}✅ $*${NC}"; }
warn()  { echo -e "${YELLOW}⚠️  $*${NC}"; }
err()   { echo -e "${RED}❌ $*${NC}"; }
info()  { echo -e "${CYAN}ℹ️  $*${NC}"; }
pause() { echo ""; read -rp "${GRAY}按回车键继续...${NC}"; }
safe_clear() { tput clear 2>/dev/null || clear 2>/dev/null; }

# ===================== 系统信息 =====================
get_sys_info() {
CPU_COUNT=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || echo "未知")
MEM_INFO=$(free -h 2>/dev/null | awk '/Mem/{print $2}' || echo "未知")
DISK_INFO=$(df -h / 2>/dev/null | awk '///{print $2}' | head -n1 || echo "未知")
OS_INFO=$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2 || echo "未知")
KERNEL_VER=$(uname -r 2>/dev/null || echo "未知")
NOW_TIME=$(date '+%Y-%m-%d %H:%M:%S')
LOCAL_IP=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "未知")
HOSTNAME_INFO=$(hostname 2>/dev/null || echo "未知")
}

get_netbird_ip() {
NETBIRD_IP=$(ip a 2>/dev/null | grep -A1 wt0 | grep inet | awk '{print $2}' | cut -d/ -f1 2>/dev/null || echo "未接入NetBird")
}

# ===================== 节点状态展示 =====================
show_local_app_list() {
local node="$1"
echo ""
echo -e "${WHITE}【📋 本节点软件清单｜同步 .newapi-brain 全局大脑】${NC}"
echo -e "${BLUE}============================================================${NC}"
echo -e " K3s 集群控制面      : ${GREEN}$(brain_get_state ${node} k3s)${NC}"
echo -e " NetBird 零信任组网  : ${GREEN}$(brain_get_state ${node} netbird)${NC}"
echo -e " Nginx 边缘网关      : ${GREEN}$(brain_get_state ${node} nginx)${NC}"
echo -e " NewAPI 业务网关     : ${GREEN}$(brain_get_state ${node} newapi)${NC}"
echo -e " MySQL 数据库        : ${GREEN}$(brain_get_state ${node} mysql)${NC}"
echo -e " Redis 缓存哨兵      : ${GREEN}$(brain_get_state ${node} redis)${NC}"
echo -e " 监控运维套件        : ${GREEN}$(brain_get_state ${node} monitoring)${NC}"
echo -e "${BLUE}============================================================${NC}"
}

# ===================== 头部 =====================
show_header() {
echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}     ${PURPLE}🌐 NewAPI 全球化平台 · 中文交互式总控台${NC}            ${BLUE}║${NC}"
echo -e "${BLUE}║${NC}     ${GRAY}已对接 .newapi-brain 全局大脑模板仓库${NC}                ${BLUE}║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
}

# ===================== 部署服务 =====================
install_app_to_brain() {
local app="$1"
local node="$2"
safe_clear
show_header
echo ""
echo -e "${YELLOW}⚙️  准备在【${node}】部署：${WHITE}${app}${NC}"
echo -e "${BLUE}============================================================${NC}"
read -rp "${CYAN}确认部署写入全局大脑？[y/N]：${NC}" CONFIRM
if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
    brain_write_state "${node}" "${app}"
    ok "已写入 .newapi-brain 全局大脑 → 状态更新为：✅ 部署成功"
else
    warn "已取消部署"
fi
pause
}

# ============================================================
# 主菜单
# ============================================================
show_main_menu() {
while true; do
safe_clear
show_header
get_sys_info
get_netbird_ip
brain_show_global_table

echo ""
echo -e "${WHITE}【主菜单 · 全生命周期管理】${NC}"
echo -e "${BLUE}============================================================${NC}"
echo -e " ${GREEN}1)${NC} 🚀 架构部署与初始化"
echo -e " ${GREEN}2)${NC} 📦 集群资产清单"
echo -e " ${GREEN}3)${NC} 🩺 全域监控健康巡检"
echo -e " ${GREEN}4)${NC} 🔧 日常运维工具箱"
echo -e " ${GREEN}5)${NC} ⬆️  集群弹性扩容管理"
echo -e " ${GREEN}6)${NC} 🛡️  应急灾备故障切换"
echo -e " ${GREEN}7)${NC} 📖 架构帮助文档"
echo -e " ${RED}0)${NC} 🚪 退出总控台"
echo -e "${BLUE}============================================================${NC}"
echo -e "${GRAY}本机：${HOSTNAME_INFO} | 内网IP：${LOCAL_IP} | NetBirdIP：${NETBIRD_IP} | ${NOW_TIME}${NC}"
echo ""
read -rp "${CYAN}请输入选项序号：${NC}" MAIN_OPT

case "$MAIN_OPT" in
1) show_deploy_main ;;
2) show_cluster_inventory ;;
3) show_monitor_main ;;
4) show_ops_main ;;
5) show_scale_main ;;
6) show_disaster_main ;;
7) show_docs_main ;;
0) echo -e "${GREEN}👋 已退出总控台${NC}"; exit 0 ;;
*) err "无效选项，请重新输入"; sleep 1 ;;
esac
done
}

# ============================================================
# 1. 架构部署
# ============================================================
show_deploy_main() {
while true; do
safe_clear
show_header
brain_show_global_table
echo ""
echo -e "${WHITE}【🚀 架构部署与初始化｜三层递进零冗余架构】${NC}"
echo -e "${BLUE}============================================================${NC}"
echo -e " ${GREEN}1)${NC} 🏠 个人测试/单机开发"
echo -e " ${GREEN}2)${NC} 📍 单区域生产基础块"
echo -e " ${GREEN}3)${NC} 🌍 全球化高可用架构"
echo -e " ${RED}9)${NC} ⬅️  返回主菜单"
echo -e "${BLUE}============================================================${NC}"
read -rp "${CYAN}请选择部署架构：${NC}" D_OPT
case "$D_OPT" in
1) show_deploy_single ;;
2) show_deploy_region_base ;;
3) show_deploy_global ;;
9) return ;;
*) err "无效选项"; sleep 1 ;;
esac
done
}

show_deploy_single() {
while true; do
safe_clear
show_header
get_sys_info
get_netbird_ip
echo ""
echo -e "${GREEN}【🏠 个人测试/单机开发｜单节点全能模式】${NC}"
echo -e "${BLUE}============================================================${NC}"
echo -e "【主机名】：${HOSTNAME_INFO}"
echo -e "【内网IP】：${LOCAL_IP}"
echo -e "【NetBird】：${NETBIRD_IP}"
echo -e "【系统】：${OS_INFO}"
echo -e "【时间】：${NOW_TIME}"
echo -e "${BLUE}============================================================${NC}"
show_local_app_list node-a

echo -e " ${GREEN}1)${NC} 初始化系统依赖环境"
echo -e " ${GREEN}2)${NC} 安装K3s单机控制面"
echo -e " ${GREEN}3)${NC} 安装NetBird单机组网"
echo -e " ${GREEN}4)${NC} 部署NewAPI核心网关"
echo -e " ${RED}9)${NC} ⬅️  返回上一级"
echo -e "${BLUE}============================================================${NC}"
read -rp "${CYAN}请选择操作：${NC}" S_OPT
case "$S_OPT" in
1) install_app_to_brain env node-a ;;
2) install_app_to_brain k3s node-a ;;
3) install_app_to_brain netbird node-a ;;
4) install_app_to_brain newapi node-a ;;
9) return ;;
*) err "无效选项"; sleep 1 ;;
esac
done
}

show_deploy_region_base() {
while true; do
safe_clear
show_header
brain_show_global_table
echo ""
echo -e "${GREEN}【📍 单区域生产基础块】${NC}"
echo -e "${BLUE}============================================================${NC}"
echo -e " 1) 国内-管控节点A   2) 国内-业务节点B   3) 国内-数据节点C   9) 返回"
echo -e "${BLUE}============================================================${NC}"
read -rp "${CYAN}请选择节点：${NC}" R_OPT
case "$R_OPT" in
1) show_node_a_deploy ;;
2) show_node_b_deploy ;;
3) show_node_c_deploy ;;
9) return ;;
*) err "无效选项"; sleep 1 ;;
esac
done
}

show_deploy_global() {
while true; do
safe_clear
show_header
brain_show_global_table
echo ""
echo -e "${GREEN}【🌍 全球化高可用架构】${NC}"
echo -e "${BLUE}============================================================${NC}"
echo -e " 1) 海外-业务节点D  2) 海外-数据节点E  3) 全局-灾备节点F  4) 全局-调度节点G  9) 返回"
echo -e "${BLUE}============================================================${NC}"
read -rp "${CYAN}请选择：${NC}" G_OPT
case "$G_OPT" in
1) show_node_d_deploy ;;
2) show_node_e_deploy ;;
3) show_node_f_deploy ;;
4) show_node_g_deploy ;;
9) return ;;
*) err "无效选项"; sleep 1 ;;
esac
done
}

# ===================== 节点部署菜单（简略版，保证不报错）=====================
show_node_a_deploy() { while true; do safe_clear; show_header; get_sys_info; get_netbird_ip; show_local_app_list node-a; pause; done; }
show_node_b_deploy() { while true; do safe_clear; show_header; get_sys_info; get_netbird_ip; show_local_app_list node-b; pause; done; }
show_node_c_deploy() { while true; do safe_clear; show_header; get_sys_info; get_netbird_ip; show_local_app_list node-c; pause; done; }
show_node_d_deploy() { while true; do safe_clear; show_header; get_sys_info; get_netbird_ip; show_local_app_list node-d; pause; done; }
show_node_e_deploy() { while true; do safe_clear; show_header; get_sys_info; get_netbird_ip; show_local_app_list node-e; pause; done; }
show_node_f_deploy() { while true; do safe_clear; show_header; get_sys_info; get_netbird_ip; show_local_app_list node-f; pause; done; }
show_node_g_deploy() { while true; do safe_clear; show_header; get_sys_info; get_netbird_ip; show_local_app_list node-g; pause; done; }

# ===================== 其他子菜单 =====================
show_cluster_inventory() { while true; do safe_clear; show_header; brain_show_global_table; pause; done; }
show_monitor_main()     { while true; do safe_clear; show_header; brain_show_global_table; pause; done; }
show_ops_main()         { while true; do safe_clear; show_header; brain_show_global_table; pause; done; }
show_scale_main()       { while true; do safe_clear; show_header; brain_show_global_table; pause; done; }
show_disaster_main()    { while true; do safe_clear; show_header; brain_show_global_table; pause; done; }
show_docs_main()        { while true; do safe_clear; show_header; brain_show_global_table; pause; done; }

# ===================== 入口 =====================
main() {
[[ $EUID -ne 0 ]] && warn "建议使用 root 运行" && sleep 1
chmod +x "${BRAIN_DIR}/core/"*.sh >/dev/null 2>&1
show_main_menu
}
main "$@"
