#!/usr/bin/env bash
# ============================================================
# NewAPI 中文交互式总控台
# 已完全适配 .newapi-brain 独立 GitHub 模板仓库
# 唯一数据源：同级目录 .newapi-brain
# 统一状态：✅ 部署成功 ｜ 未部署
# ============================================================
set -o pipefail

# -------------------------- 全局路径绑定（固定勿改）--------------------------
BRAIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.newapi-brain"
if [[ ! -d "${BRAIN_DIR}" ]]; then
    echo -e "\033[1;31m❌ 未检测到 .newapi-brain 全局大脑仓库！\033[0m"
    echo -e "\033[1;36m请先克隆：git clone https://github.com/你的用户名/.newapi-brain.git\033[0m"
    exit 1
fi
source "${BRAIN_DIR}/core/brain.sh"

# -------------------------- 颜色定义 --------------------------
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

# -------------------------- 通用工具函数 --------------------------
log()   { echo -e "${GRAY}[$(date '+%H:%M:%S')]${NC} $1"; }
ok()    { echo -e "${GREEN}✅ $*${NC}"; }
warn()  { echo -e "${YELLOW}⚠️  $*${NC}"; }
err()   { echo -e "${RED}❌ $*${NC}"; }
info()  { echo -e "${CYAN}ℹ️  $*${NC}"; }
pause() { echo ""; read -rp "${GRAY}按回车键继续...${NC}"; }
safe_clear() { tput clear 2>/dev/null || clear 2>/dev/null; }

# -------------------------- 系统&NetBird信息采集 --------------------------
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

# -------------------------- 单节点本机软件清单（从大脑读取） --------------------------
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

# -------------------------- 头部横幅 --------------------------
show_header() {
echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}     ${PURPLE}🌐 NewAPI 全球化平台 · 中文交互式总控台${NC}            ${BLUE}║${NC}"
echo -e "${BLUE}║${NC}     ${GRAY}已对接 .newapi-brain 全局大脑模板仓库${NC}                ${BLUE}║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
}

# -------------------------- 部署服务写入全局大脑 --------------------------
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

# 调用大脑内置全局看板
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
# 1. 架构部署与初始化 子菜单
# ============================================================
show_deploy_main() {
while true; do
safe_clear
show_header
brain_show_global_table
echo ""
echo -e "${WHITE}【🚀 架构部署与初始化｜三层递进零冗余架构】${NC}"
echo -e "${BLUE}============================================================${NC}"
echo -e " ${GREEN}1)${NC} 🏠 个人测试/单机开发     ${GRAY}单节点AllInOne，最小省资源${NC}"
echo -e " ${GREEN}2)${NC} 📍 单区域生产基础块     ${GRAY}固定3节点，作为全球架构复用底座${NC}"
echo -e " ${GREEN}3)${NC} 🌍 全球化高可用架构     ${GRAY}复用单区域基础块+新增跨区节点${NC}"
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

# 1-1 单机开发部署
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
echo -e "【NetBird组网IP】：${NETBIRD_IP}"
echo -e "【系统】：${OS_INFO} (内核 ${KERNEL_VER})"
echo -e "【配置】：CPU ${CPU_COUNT}核｜内存 ${MEM_INFO}｜磁盘 ${DISK_INFO}"
echo -e "【时间】：${NOW_TIME}"
echo -e "${BLUE}============================================================${NC}"

show_local_app_list node-a

echo -e " ${GREEN}1)${NC} 初始化系统依赖环境"
echo -e " ${GREEN}2)${NC} 安装K3s单机控制面"
echo -e " ${GREEN}3)${NC} 安装NetBird单机组网"
echo -e " ${GREEN}4)${NC} 部署NewAPI核心网关"
echo -e " ${GREEN}5)${NC} 部署中转站点&邮件告警"
echo -e " ${GREEN}6)${NC} 部署轻量监控套件"
echo -e " ${RED}9)${NC} ⬅️  返回上一级"
echo -e "${BLUE}============================================================${NC}"
read -rp "${CYAN}请选择操作：${NC}" S_OPT
case "$S_OPT" in
1) install_app_to_brain env node-a ;;
2) install_app_to_brain k3s node-a ;;
3) install_app_to_brain netbird node-a ;;
4) install_app_to_brain newapi node-a ;;
5) install_app_to_brain mail node-a ;;
6) install_app_to_brain monitoring node-a ;;
9) return ;;
*) err "无效选项"; sleep 1 ;;
esac
done
}

# 1-2 单区域生产基础块（核心复用底座）
show_deploy_region_base() {
while true; do
safe_clear
show_header
brain_show_global_table
echo ""
echo -e "${GREEN}【📍 单区域生产基础块｜3节点标准架构｜全局可复用】${NC}"
echo -e "${BLUE}============================================================${NC}"
echo -e " ${GREEN}1)${NC} 🖥️  国内-管控节点A   $(get_node_status node-a)"
echo -e " ${GREEN}2)${NC} 🧩 国内-业务节点B   $(get_node_status node-b)"
echo -e " ${GREEN}3)${NC} 💾 国内-数据节点C   $(get_node_status node-c)"
echo -e "${BLUE}------------------------------------------------------------${NC}"
echo -e "${GRAY}架构规则：${NC}"
echo -e "${GRAY} 节点A：控制面+NetBird主控+中转/邮件核心（全球复用）${NC}"
echo -e "${GRAY} 节点B：业务网关+NewAPI服务（禁止装数据组件）${NC}"
echo -e "${GRAY} 节点C：纯数据节点（数据库/缓存/备份，禁控制面）${NC}"
echo -e "${BLUE}============================================================${NC}"
echo -e " ${RED}9)${NC} ⬅️  返回上一级"
echo -e "${BLUE}============================================================${NC}"
read -rp "${CYAN}请选择要部署的节点：${NC}" R_OPT
case "$R_OPT" in
1) show_node_a_deploy ;;
2) show_node_b_deploy ;;
3) show_node_c_deploy ;;
9) return ;;
*) err "无效选项"; sleep 1 ;;
esac
done
}

# 1-3 全球化高可用架构（复用基础块）
show_deploy_global() {
while true; do
safe_clear
show_header
brain_show_global_table
echo ""
echo -e "${GREEN}【🌍 全球化高可用｜复用单区域基础块 无冗余部署】${NC}"
echo -e "${BLUE}============================================================${NC}"
echo -e "${YELLOW}已自动复用：国内A/B/C全套核心服务（无需重复部署）${NC}"
echo -e "${BLUE}------------------------------------------------------------${NC}"
echo -e " ${GREEN}1)${NC} 🌏 海外-业务节点D   $(get_node_status node-d)"
echo -e " ${GREEN}2)${NC} 📂 海外-数据节点E   $(get_node_status node-e)"
echo -e " ${GREEN}3)${NC} 🛡️  全局-灾备节点F   $(get_node_status node-f)"
echo -e " ${GREEN}4)${NC} 📡 全局-调度节点G   $(get_node_status node-g)"
echo -e "${BLUE}------------------------------------------------------------${NC}"
echo -e "${GRAY}规则：仅部署边缘代理/从库/调度，不重复中转、邮件、主库${NC}"
echo -e "${BLUE}============================================================${NC}"
echo -e " ${RED}9)${NC} ⬅️  返回上一级"
echo -e "${BLUE}============================================================${NC}"
read -rp "${CYAN}请选择全球新增节点：${NC}" G_OPT
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

# 单区域-管控节点A部署子菜单
show_node_a_deploy() {
while true; do
safe_clear
show_header
get_sys_info
get_netbird_ip
echo ""
echo -e "${WHITE}【国内-管控节点A｜集群总控+全局复用核心】${NC}"
echo -e "${BLUE}============================================================${NC}"
echo -e "【主机名】：${HOSTNAME_INFO}"
echo -e "【内网IP】：${LOCAL_IP}"
echo -e "【NetBird组网IP】：${NETBIRD_IP}"
echo -e "【系统】：${OS_INFO} (内核 ${KERNEL_VER})"
echo -e "【配置】：CPU ${CPU_COUNT}核｜内存 ${MEM_INFO}｜磁盘 ${DISK_INFO}"
echo -e "【时间】：${NOW_TIME}"
echo -e "${BLUE}============================================================${NC}"

show_local_app_list node-a

echo -e " ${GREEN}1)${NC} 初始化管控节点环境"
echo -e " ${GREEN}2)${NC} 部署K3s高可用控制面"
echo -e " ${GREEN}3)${NC} 部署NetBird服务端主控"
echo -e " ${GREEN}4)${NC} 部署全局共用中转站点"
echo -e " ${GREEN}5)${NC} 部署全局邮件告警服务"
echo -e " ${GREEN}6)${NC} 部署集群总监控面板"
echo -e " ${RED}9)${NC} ⬅️  返回节点选择"
echo -e "${BLUE}============================================================${NC}"
read -rp "${CYAN}请选择：${NC}" O_OPT
case "$O_OPT" in
1) install_app_to_brain env node-a ;;
2) install_app_to_brain k3s node-a ;;
3) install_app_to_brain netbird node-a ;;
4) install_app_to_brain proxy node-a ;;
5) install_app_to_brain mail node-a ;;
6) install_app_to_brain monitoring node-a ;;
9) return ;;
*) err "无效选项"; sleep 1 ;;
esac
done
}

# 单区域-业务节点B部署子菜单
show_node_b_deploy() {
while true; do
safe_clear
show_header
get_sys_info
get_netbird_ip
echo ""
echo -e "${WHITE}【国内-业务节点B｜业务网关专属节点】${NC}"
echo -e "${BLUE}============================================================${NC}"
echo -e "【主机名】：${HOSTNAME_INFO}"
echo -e "【内网IP】：${LOCAL_IP}"
echo -e "【NetBird组网IP】：${NETBIRD_IP}"
echo -e "【系统】：${OS_INFO} (内核 ${KERNEL_VER})"
echo -e "【配置】：CPU ${CPU_COUNT}核｜内存 ${MEM_INFO}｜磁盘 ${DISK_INFO}"
echo -e "【时间】：${NOW_TIME}"
echo -e "${BLUE}============================================================${NC}"

show_local_app_list node-b

echo -e " ${GREEN}1)${NC} 加入K3s集群工作节点"
echo -e " ${GREEN}2)${NC} 部署Nginx边缘网关"
echo -e " ${GREEN}3)${NC} 部署NewAPI业务网关"
echo -e " ${GREEN}4)${NC} 接入NetBird内网网格"
echo -e " ${GREEN}5)${NC} 部署模型推理服务"
echo -e " ${RED}9)${NC} ⬅️  返回节点选择"
echo -e "${BLUE}============================================================${NC}"
read -rp "${CYAN}请选择：${NC}" O_OPT
case "$O_OPT" in
1) install_app_to_brain k3s-agent node-b ;;
2) install_app_to_brain nginx node-b ;;
3) install_app_to_brain newapi node-b ;;
4) install_app_to_brain netbird node-b ;;
5) install_app_to_brain model node-b ;;
9) return ;;
*) err "无效选项"; sleep 1 ;;
esac
done
}

# 单区域-数据节点C部署子菜单
show_node_c_deploy() {
while true; do
safe_clear
show_header
get_sys_info
get_netbird_ip
echo ""
echo -e "${WHITE}【国内-数据节点C｜纯数据专属节点】${NC}"
echo -e "${BLUE}============================================================${NC}"
echo -e "【主机名】：${HOSTNAME_INFO}"
echo -e "【内网IP】：${LOCAL_IP}"
echo -e "【NetBird组网IP】：${NETBIRD_IP}"
echo -e "【系统】：${OS_INFO} (内核 ${KERNEL_VER})"
echo -e "【配置】：CPU ${CPU_COUNT}核｜内存 ${MEM_INFO}｜磁盘 ${DISK_INFO}"
echo -e "【时间】：${NOW_TIME}"
echo -e "${BLUE}============================================================${NC}"

show_local_app_list node-c

echo -e " ${GREEN}1)${NC} 加入K3s集群工作节点"
echo -e " ${GREEN}2)${NC} 部署MySQL主库服务"
echo -e " ${GREEN}3)${NC} 部署Redis哨兵缓存"
echo -e " ${GREEN}4)${NC} 接入NetBird内网网格"
echo -e " ${GREEN}5)${NC} 配置自动定时备份"
echo -e " ${RED}9)${NC} ⬅️  返回节点选择"
echo -e "${BLUE}============================================================${NC}"
read -rp "${CYAN}请选择：${NC}" O_OPT
case "$O_OPT" in
1) install_app_to_brain k3s-agent node-c ;;
2) install_app_to_brain mysql node-c ;;
3) install_app_to_brain redis node-c ;;
4) install_app_to_brain netbird node-c ;;
5) install_app_to_brain backup node-c ;;
9) return ;;
*) err "无效选项"; sleep 1 ;;
esac
done
}

# 海外节点D/E/F/G 模板
show_node_d_deploy() {
while true; do
safe_clear
show_header
get_sys_info
get_netbird_ip
echo ""
echo -e "${WHITE}【海外-业务节点D】${NC}"
echo -e "${BLUE}============================================================${NC}"
echo -e "【主机名】：${HOSTNAME_INFO}"
echo -e "【内网IP】：${LOCAL_IP}"
echo -e "【NetBird组网IP】：${NETBIRD_IP}"
echo -e "${BLUE}============================================================${NC}"
show_local_app_list node-d
pause
done
}

show_node_e_deploy() {
while true; do
safe_clear
show_header
get_sys_info
get_netbird_ip
echo ""
echo -e "${WHITE}【海外-数据节点E】${NC}"
echo -e "${BLUE}============================================================${NC}"
echo -e "【主机名】：${HOSTNAME_INFO}"
echo -e "【内网IP】：${LOCAL_IP}"
echo -e "【NetBird组网IP】：${NETBIRD_IP}"
echo -e "${BLUE}============================================================${NC}"
show_local_app_list node-e
pause
done
}

show_node_f_deploy() {
while true; do
safe_clear
show_header
get_sys_info
get_netbird_ip
echo ""
echo -e "${WHITE}【全局-灾备节点F】${NC}"
echo -e "${BLUE}============================================================${NC}"
echo -e "【主机名】：${HOSTNAME_INFO}"
echo -e "【内网IP】：${LOCAL_IP}"
echo -e "【NetBird组网IP】：${NETBIRD_IP}"
echo -e "${BLUE}============================================================${NC}"
show_local_app_list node-f
pause
done
}

show_node_g_deploy() {
while true; do
safe_clear
show_header
get_sys_info
get_netbird_ip
echo ""
echo -e "${WHITE}【全局-调度节点G】${NC}"
echo -e "${BLUE}============================================================${NC}"
echo -e "【主机名】：${HOSTNAME_INFO}"
echo -e "【内网IP】：${LOCAL_IP}"
echo -e "【NetBird组网IP】：${NETBIRD_IP}"
echo -e "${BLUE}============================================================${NC}"
show_local_app_list node-g
pause
done
}

# ============================================================
# 2. 集群资产清单 子菜单
# ============================================================
show_cluster_inventory() {
while true; do
safe_clear
show_header
brain_show_global_table
echo ""
echo -e "${WHITE}【📦 集群化资产总清单｜全节点/区域/角色/状态一览】${NC}"
echo -e "${BLUE}============================================================${NC}"
echo -e " ${GREEN}1)${NC} 刷新资产状态清单"
echo -e " ${GREEN}2)${NC} 注册新节点到资产库"
echo -e " ${GREEN}3)${NC} 下线退役无效节点"
echo -e " ${RED}9)${NC} ⬅️  返回主菜单"
echo -e "${BLUE}============================================================${NC}"
read -rp "${CYAN}请选择操作：${NC}" I_OPT
case "$I_OPT" in
1) info "已刷新集群资产清单"; pause ;;
2) info "进入新节点注册流程"; pause ;;
3) info "进入节点下线流程"; pause ;;
9) return ;;
*) err "无效选项"; sleep 1 ;;
esac
done
}

# ============================================================
# 3. 全域监控与健康巡检 子菜单
# ============================================================
show_monitor_main() {
while true; do
safe_clear
show_header
brain_show_global_table
echo ""
echo -e "${WHITE}【🩺 全域监控与健康巡检】${NC}"
echo -e "${BLUE}============================================================${NC}"
echo -e " ${GREEN}1)${NC} 🔍 全集群一键健康巡检"
echo -e " ${GREEN}2)${NC} 📊 Grafana监控面板入口"
echo -e " ${GREEN}3)${NC} 📈 VictoriaMetrics指标查询"
echo -e " ${GREEN}4)${NC} 📝 Loki日志聚合查看"
echo -e " ${GREEN}5)${NC} 🚨 告警通道配置与测试"
echo -e " ${GREEN}6)${NC} 节点网络连通性检测"
echo -e " ${RED}9)${NC} ⬅️  返回主菜单"
echo -e "${BLUE}============================================================${NC}"
read -rp "${CYAN}请选择：${NC}" M_OPT
case "$M_OPT" in
1) info "开始全集群健康巡检..."; pause ;;
2) info "跳转Grafana地址..."; pause ;;
3) info "进入指标查询终端..."; pause ;;
4) info "实时聚合日志查看..."; pause ;;
5) info "测试邮件/机器人告警..."; pause ;;
6) info "检测NetBird集群节点连通性..."; pause ;;
9) return ;;
*) err "无效选项"; sleep 1 ;;
esac
done
}

# ============================================================
# 4. 日常运维工具箱 子菜单
# ============================================================
show_ops_main() {
while true; do
safe_clear
show_header
brain_show_global_table
echo ""
echo -e "${WHITE}【🔧 日常运维工具箱】${NC}"
echo -e "${BLUE}============================================================${NC}"
echo -e " ${GREEN}1)${NC} 🛠️  服务安装/重装/卸载"
echo -e " ${GREEN}2)${NC} 🔄 服务重启/重载/启停"
echo -e " ${GREEN}3)${NC} 📑 配置文件热更新部署"
echo -e " ${GREEN}4)${NC} 💾 集群配置一键备份"
echo -e " ${GREEN}5)${NC} 📥 集群配置从备份恢复"
echo -e " ${GREEN}6)${NC} 🔑 密钥与SSL证书管理"
echo -e " ${RED}9)${NC} ⬅️  返回主菜单"
echo -e "${BLUE}============================================================${NC}"
read -rp "${CYAN}请选择运维功能：${NC}" O_OPT
case "$O_OPT" in
1) info "进入服务管理列表..."; pause ;;
2) info "进入服务启停控制..."; pause ;;
3) info "GitOps配置热更新..."; pause ;;
4) info "执行全配置打包备份..."; pause ;;
5) info "从备份恢复集群配置..."; pause ;;
6) info "密钥轮转/证书续期..."; pause ;;
9) return ;;
*) err "无效选项"; sleep 1 ;;
esac
done
}

# ============================================================
# 5. 集群弹性扩容管理 子菜单
# ============================================================
show_scale_main() {
while true; do
safe_clear
show_header
brain_show_global_table
echo ""
echo -e "${WHITE}【⬆️  集群弹性扩容管理｜无缝升级 不重构架构】${NC}"
echo -e "${BLUE}============================================================${NC}"
echo -e " ${GREEN}1)${NC} 单机开发 → 升级单区域生产块"
echo -e " ${GREEN}2)${NC} 单区域基础块 → 升级全球化架构"
echo -e " ${GREEN}3)${NC} 横向新增业务边缘节点"
echo -e " ${GREEN}4)${NC} 横向新增数据存储节点"
echo -e " ${GREEN}5)${NC} 新增海外跨区容灾节点"
echo -e " ${RED}9)${NC} ⬅️  返回主菜单"
echo -e "${BLUE}============================================================${NC}"
read -rp "${CYAN}请选择扩容方式：${NC}" S_OPT
case "$S_OPT" in
1) info "单机平滑扩容为3节点单区域..."; pause ;;
2) info "复用现有单区域，叠加全球节点..."; pause ;;
3) info "新增业务工作节点接入集群..."; pause ;;
4) info "新增只读数据/缓存节点..."; pause ;;
5) info "部署海外跨区容灾节点..."; pause ;;
9) return ;;
*) err "无效选项"; sleep 1 ;;
esac
done
}

# ============================================================
# 6. 应急灾备与故障切换 子菜单
# ============================================================
show_disaster_main() {
while true; do
safe_clear
show_header
brain_show_global_table
echo ""
echo -e "${RED}【🛡️  应急灾备与故障切换｜高风险操作请谨慎】${NC}"
echo -e "${BLUE}============================================================${NC}"
echo -e " ${GREEN}1)${NC} 🌐 跨国网络断网应急切换"
echo -e " ${GREEN}2)${NC} 💾 MySQL数据库主从故障切换"
echo -e " ${GREEN}3)${NC} 🧩 Redis集群故障自愈"
echo -e " ${GREEN}4)${NC} 📦 K3s集群快照备份与恢复"
echo -e " ${GREEN}5)${NC} 🚫 恶意IP一键封禁防护"
echo -e " ${RED}9)${NC} ⬅️  返回主菜单"
echo -e "${BLUE}============================================================${NC}"
read -rp "${CYAN}请选择应急功能：${NC}" D_OPT
case "$D_OPT" in
1) info "触发跨区流量自动切换..."; pause ;;
2) info "数据库主从手动/自动切换..."; pause ;;
3) info "Redis哨兵故障自愈触发..."; pause ;;
4) info "集群快照备份与还原..."; pause ;;
5) info "WAF黑名单一键封禁..."; pause ;;
9) return ;;
*) err "无效选项"; sleep 1 ;;
esac
done
}

# ============================================================
# 7. 架构文档与帮助手册 子菜单
# ============================================================
show_docs_main() {
while true; do
safe_clear
show_header
brain_show_global_table
echo ""
echo -e "${WHITE}【📖 架构文档与帮助手册】${NC}"
echo -e "${BLUE}============================================================${NC}"
echo -e " ${GREEN}1)${NC} 整体架构层级说明文档"
echo -e " ${GREEN}2)${NC} 各节点角色规范约束"
echo -e " ${GREEN}3)${NC} 常见故障排查手册"
echo -e " ${GREEN}4)${NC} 部署与扩容标准流程"
echo -e " ${GREEN}5)${NC} 专业术语名词解释"
echo -e " ${RED}9)${NC} ⬅️  返回主菜单"
echo -e "${BLUE}============================================================${NC}"
read -rp "${CYAN}请选择文档：${NC}" D_OPT
case "$D_OPT" in
1) info "查看架构层级说明..."; pause ;;
2) info "查看节点角色规范..."; pause ;;
3) info "打开故障排查手册..."; pause ;;
4) info "查看部署扩容流程..."; pause ;;
5) info "查看术语名词解释..."; pause ;;
9) return ;;
*) err "无效选项"; sleep 1 ;;
esac
done
}

# ---------- 程序入口 ----------
main() {
[[ $EUID -ne 0 ]] && warn "建议使用 root 用户运行（部分集群操作需要管理员权限）" && sleep 1
chmod +x "${BRAIN_DIR}/core/"*.sh
show_main_menu
}
main "$@"
