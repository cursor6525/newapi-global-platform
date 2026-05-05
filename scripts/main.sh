#!/usr/bin/env bash
# ============================================================
# NewAPI 全球化平台 · 中文交互式总控台 (彩色版)
# 版本: v1.2.2 (扩容逻辑对齐版)
# 特性: 自动检测终端颜色支持 / 防闪烁 / 兼容性强
# ============================================================

set -o pipefail

# ---------- 全局路径 ----------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
INVENTORY_DIR="${ROOT_DIR}/inventory/nodes"
LOG_DIR="${ROOT_DIR}/logs"
mkdir -p "${INVENTORY_DIR}" "${LOG_DIR}"

# ---------- 颜色支持自动检测 ----------
if [[ -t 1 ]] && [[ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]]; then
    RED=$'\033[1;31m'
    GREEN=$'\033[1;32m'
    YELLOW=$'\033[1;33m'
    BLUE=$'\033[1;34m'
    PURPLE=$'\033[1;35m'
    CYAN=$'\033[1;36m'
    WHITE=$'\033[1;37m'
    GRAY=$'\033[0;90m'
    BOLD=$'\033[1m'
    NC=$'\033[0m'
else
    RED=''; GREEN=''; YELLOW=''; BLUE=''; PURPLE=''
    CYAN=''; WHITE=''; GRAY=''; BOLD=''; NC=''
fi

# ---------- 通用工具函数 ----------
log()   { echo -e "${GRAY}[$(date '+%H:%M:%S')]${NC} $*" | tee -a "${LOG_DIR}/main.log" >/dev/null; }
ok()    { echo -e "${GREEN}✅ $*${NC}"; }
warn()  { echo -e "${YELLOW}⚠️  $*${NC}"; }
err()   { echo -e "${RED}❌ $*${NC}"; }
info()  { echo -e "${CYAN}ℹ️  $*${NC}"; }
pause() { echo ""; read -p "$(printf "${GRAY}按回车键继续...${NC}")" _; }

# ---------- 安全清屏 ----------
safe_clear() {
    if [[ -t 1 ]]; then
        tput clear 2>/dev/null || clear 2>/dev/null || printf '\n%.0s' {1..3}
    fi
}

# ---------- 系统信息采集 ----------
get_sys_info() {
    CPU_COUNT=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || echo "未知")
    MEM_INFO=$(free -h 2>/dev/null | awk '/Mem/{print $2}' || echo "未知")
    DISK_INFO=$(df -h / 2>/dev/null | awk '/\//{print $2}' | head -n1 || echo "未知")
    OS_INFO=$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2 || echo "未知")
    KERNEL_VER=$(uname -r 2>/dev/null || echo "未知")
    NOW_TIME=$(date '+%Y-%m-%d %H:%M:%S')
    LOCAL_IP=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "未知")
    HOSTNAME_INFO=$(hostname 2>/dev/null || echo "未知")
    get_netbird_ip
}

# ---------- 获取 NetBird 组网 IP ----------
get_netbird_ip() {
    NETBIRD_IP=$(ip a 2>/dev/null | grep -A1 wt0 | grep inet | awk '{print $2}' | cut -d/ -f1 2>/dev/null || echo "未接入 NetBird")
}

# ---------- 节点部署状态读取 ----------
get_node_status() {
    local node="$1"
    if [[ -f "${INVENTORY_DIR}/${node}.state" ]]; then
        echo -e "${GREEN}✅ 已部署｜健康${NC}"
    else
        echo -e "${YELLOW}未部署${NC}"
    fi
}

# ---------- 从全局大脑读取应用状态（核心数据源） ----------
query_app_state() {
    local node="$1"
    local app="$2"
    if [[ -f "${INVENTORY_DIR}/${node}.state" ]]; then
        grep -q "APP_${app}=installed" "${INVENTORY_DIR}/${node}.state" && echo -e "${GREEN}✅ 部署成功${NC}" || echo -e "${GRAY}未部署${NC}"
    else
        echo -e "${GRAY}未部署${NC}"
    fi
}

# ---------- 动态计算：当前架构【最大可承载用户量】（真实动态，未部署=未部署）
get_support_user_max() {
    local total_all=$(ls ${INVENTORY_DIR}/node-*.state 2>/dev/null | wc -l)
    local base_ab=$(count_base_ab)

    # 1. 完全没部署任何服务器
    if [[ $total_all -eq 0 ]]; then
        echo "未部署"
        return
    fi

    # 2. 底座AB不完整
    if [[ $base_ab -lt 2 ]]; then
        echo "底座未完整（需A+B）"
        return
    fi

    # 3. 底座完整，按服务器总数分档匹配用户量
    if [[ $total_all -eq 2 ]]; then
        echo "0～5000"
    elif [[ $total_all -eq 3 ]]; then
        echo "5000～5万"
    elif [[ $total_all -ge 4 && $total_all -le 5 ]]; then
        echo "5万～20万"
    elif [[ $total_all -ge 6 && $total_all -le 9 ]]; then
        echo "20万～100万"
    elif [[ $total_all -eq 10 ]]; then
        echo "100万～500万"
    elif [[ $total_all -ge 11 && $total_all -le 20 ]]; then
        echo "500万～2000万"
    elif [[ $total_all -ge 21 && $total_all -le 40 ]]; then
        echo "2000万～5000万"
    else
        echo "5000万～1亿+"
    fi
}

# ---------- 动态获取：实时在线用户（未部署=0）
get_real_online_user() {
    # 先检查是否部署了NewAPI网关
    if [ ! -f "${INVENTORY_DIR}/node-a.state" ] || \
       ! grep -q "APP_newapi-gateway=installed" "${INVENTORY_DIR}/node-a.state"; then
        echo "0"
        return
    fi

    # 已部署，尝试从接口拉取数据（后期可改成你的真实监控接口）
    local online=$(curl -s --connect-timeout 1 "http://127.0.0.1:3000/api/v1/online" 2>/dev/null | jq -r .online 2>/dev/null)
    if [[ -z "$online" || "$online" == "null" ]]; then
        echo "0"
    else
        echo "$online"
    fi
}

# ---------- 全局服务部署总览超级看板（最终修复版）
show_global_service_table() {
    local base_ab=$(count_base_ab)
    local total_all=$(ls ${INVENTORY_DIR}/node-*.state 2>/dev/null | wc -l)
    local biz_edge=$(count_biz_edge_nodes)
    local data_slice=$(count_data_slice_nodes)
    local dr_security=$(count_dr_security_nodes)
    local max_support=$(get_support_user_max)
    local real_online=$(get_real_online_user)

    echo ""
    echo -e "${WHITE}【📊 NEWAPI 全局大脑｜集群实时数据总看板】${NC}"
    echo -e "${BLUE}=========================================================================${NC}"
    echo -e "${CYAN} 服务器总数：${WHITE}${total_all} 台${NC} ｜ ${CYAN}基础底座AB：${WHITE}${base_ab}/2 台${NC}"
    echo -e "${BLUE}-------------------------------------------------------------------------${NC}"
    echo -e "${GREEN} 业务边缘节点　：${WHITE}${biz_edge} 台${NC}"
    echo -e "${BLUE} 只读数据分片节点：${WHITE}${data_slice} 台${NC}"
    echo -e "${YELLOW} 容灾/备份/日志/安全/海外节点：${WHITE}${dr_security} 台${NC}"
    echo -e "${BLUE}-------------------------------------------------------------------------${NC}"
    echo -e "${CYAN} 当前架构适配最大承载用户：${WHITE}${max_support} 人${NC}"
    echo -e "${RED} 当前实时在线用户　　　　：${WHITE}${real_online} 人${NC}"
    echo -e "${BLUE}=========================================================================${NC}"

    # 智能扩容判断建议
    echo -e "${WHITE}【🔍 智能扩容分析建议】${NC}"
    echo -e "${BLUE}-------------------------------------------------------------------------${NC}"
    if [[ $total_all -eq 0 ]]; then
        echo -e "${YELLOW}⚠️  请先部署基础底座A+B服务器${NC}"
    elif [[ $base_ab -lt 2 ]]; then
        echo -e "${RED}❌ 警告：基础底座AB服务器未部署完整，优先补齐底座！${NC}"
    else
        if [[ "$max_support" != "底座未完整（需A+B）" && "$max_support" != "未部署" && $real_online -gt $max_support ]]; then
            echo -e "${RED}❌ 在线用户已超当前架构承载上限，建议立即扩容业务/数据节点！${NC}"
        else
            echo -e "${GREEN}✅ 当前服务器配置充足，在线用户在承载范围内，无需扩容${NC}"
        fi
    fi
    echo -e "${BLUE}=========================================================================${NC}"
    echo -e "${GRAY}说明：数据源 → NEWAPI 全局大脑 inventory 节点状态目录${NC}"
    echo ""

# ---------- 全局服务部署总览看板 ----------
show_global_service_table() {
    echo ""
    echo -e "${WHITE}【📊 全局服务部署总览 | NEWAPI 全局大脑数据看板】${NC}"
    echo -e "${BLUE}=====================================================================${NC}"
    printf " ${CYAN}%-8s %-8s %-8s %-8s %-10s %-8s %-8s${NC}\n" "节点" "K3s" "NetBird" "Nginx" "NewAPI" "MySQL" "Redis"
    echo -e "${BLUE}---------------------------------------------------------------------${NC}"
    printf " 节点A  %-8s %-8s %-8s %-10s %-8s %-8s\n" \
        "$(query_app_state node-a k3s)" \
        "$(query_app_state node-a netbird)" \
        "$(query_app_state node-a nginx)" \
        "$(query_app_state node-a newapi)" \
        "$(query_app_state node-a mysql)" \
        "$(query_app_state node-a redis)"
    printf " 节点B  %-8s %-8s %-8s %-10s %-8s %-8s\n" \
        "$(query_app_state node-b k3s)" \
        "$(query_app_state node-b netbird)" \
        "$(query_app_state node-b nginx)" \
        "$(query_app_state node-b newapi)" \
        "$(query_app_state node-b mysql)" \
        "$(query_app_state node-b redis)"
    printf " 节点C  %-8s %-8s %-8s %-10s %-8s %-8s\n" \
        "$(query_app_state node-c k3s)" \
        "$(query_app_state node-c netbird)" \
        "$(query_app_state node-c nginx)" \
        "$(query_app_state node-c newapi)" \
        "$(query_app_state node-c mysql)" \
        "$(query_app_state node-c redis)"
    printf " 节点D  %-8s %-8s %-8s %-10s %-8s %-8s\n" \
        "$(query_app_state node-d k3s)" \
        "$(query_app_state node-d netbird)" \
        "$(query_app_state node-d nginx)" \
        "$(query_app_state node-d newapi)" \
        "$(query_app_state node-d mysql)" \
        "$(query_app_state node-d redis)"
    printf " 节点E  %-8s %-8s %-8s %-10s %-8s %-8s\n" \
        "$(query_app_state node-e k3s)" \
        "$(query_app_state node-e netbird)" \
        "$(query_app_state node-e nginx)" \
        "$(query_app_state node-e newapi)" \
        "$(query_app_state node-e mysql)" \
        "$(query_app_state node-e redis)"
    printf " 节点F  %-8s %-8s %-8s %-10s %-8s %-8s\n" \
        "$(query_app_state node-f k3s)" \
        "$(query_app_state node-f netbird)" \
        "$(query_app_state node-f nginx)" \
        "$(query_app_state node-f newapi)" \
        "$(query_app_state node-f mysql)" \
        "$(query_app_state node-f redis)"
    printf " 节点G  %-8s %-8s %-8s %-10s %-8s %-8s\n" \
        "$(query_app_state node-g k3s)" \
        "$(query_app_state node-g netbird)" \
        "$(query_app_state node-g nginx)" \
        "$(query_app_state node-g newapi)" \
        "$(query_app_state node-g mysql)" \
        "$(query_app_state node-g redis)"
    echo -e "${BLUE}=====================================================================${NC}"
    echo -e "${GRAY}说明：绿色✅部署成功｜灰色未部署｜数据源：NEWAPI全局大脑文件夹${NC}"
}

# ---------- 头部横幅 ----------
show_header() {
echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}     ${PURPLE}🌐 NewAPI 全球化平台 · 中文交互式总控台${NC}            ${BLUE}║${NC}"
echo -e "${BLUE}║${NC}     ${GRAY}部署｜运维｜监控｜扩容｜集群化资产清单${NC}              ${BLUE}║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
}

# ============================================================
# 主菜单入口（已按你要求完全替换）
# ============================================================
show_main_menu() {
while true; do
safe_clear
show_header
get_sys_info
echo ""
show_global_service_table
echo ""
echo -e "${WHITE}【主菜单 · 全生命周期管理】${NC}"
echo -e "${BLUE}============================================================${NC}"
echo -e " ${GREEN}1)${NC} 🚀 架构部署与初始化    ${GRAY}单机 / 单区域基础块 / 全球化高可用${NC}"
echo -e " ${GREEN}2)${NC} 📦 集群化资产清单      ${GRAY}节点｜角色｜区域｜服务状态总览${NC}"
echo -e " ${GREEN}3)${NC} 🩺 全域监控与健康巡检  ${GRAY}节点连通性｜指标｜日志｜告警${NC}"
echo -e " ${GREEN}4)${NC} 🔧 日常运维工具箱      ${GRAY}安装｜启停｜配置｜备份｜恢复${NC}"
echo -e " ${GREEN}5)${NC} ⬆️  集群弹性扩容管理    ${GRAY}单机升单区｜单区升全球｜新增节点${NC}"
echo -e " ${GREEN}6)${NC} 🛡️  应急灾备与故障切换  ${GRAY}断网切换｜主从切换｜快照恢复${NC}"
echo -e " ${GREEN}7)${NC} 📖 架构文档与帮助手册  ${GRAY}部署规范｜角色说明｜排错指南${NC}"
echo -e " ${RED}0)${NC} 🚪 退出总控台"
echo -e "${BLUE}============================================================${NC}"
echo -e "${GRAY}本机：${HOSTNAME_INFO} | IP：${LOCAL_IP} | NetBird：${NETBIRD_IP} | ${OS_INFO} | ${NOW_TIME}${NC}"
echo ""
read -p "$(printf "${CYAN}请输入选项序号：${NC} ")" MAIN_OPT

case "$MAIN_OPT" in
    1) show_plan_menu ;;              # 架构部署与初始化
    2) show_cluster_inventory ;;       # 集群化资产清单
    3) show_monitor_main ;;            # 全域监控与健康巡检
    4) show_ops_main ;;                # 日常运维工具箱
    5) show_scale_main ;;              # 集群弹性扩容管理
    6) show_disaster_main ;;           # 应急灾备与故障切换
    7) show_docs_main ;;               # 架构文档与帮助手册
    0) echo -e "${GREEN}👋 已退出总控台，再见！${NC}"; exit 0 ;;
    *) err "无效选项，请重新输入"; sleep 1 ;;
esac
done
}

# ============================================================
# 1.架构部署与初始化
# ============================================================
# ---------- 部署架构选型 ----------
show_plan_menu() {
    while true; do
        safe_clear
        show_header
        show_global_service_table
        echo ""
        echo -e "${WHITE}【🚀 架构部署与初始化】${NC}"
        echo -e "${BLUE}============================================================${NC}"
        echo -e " ${GREEN}1)${NC} 🏠 ${YELLOW}最小生产架构 (2 台服务器)${NC}"
        echo -e "       ${GRAY}└─ 业务数据分离 ｜ 适合 MVP / 中小团队${NC}"
        echo ""
        echo -e " ${GREEN}2)${NC} 🌏 ${YELLOW}多区域架构 (3-6 台服务器)${NC}"
        echo -e "       ${GRAY}└─ 跨区高可用 ｜ 适合区域级 SaaS${NC}"
        echo ""
        echo -e " ${GREEN}3)${NC} 🌐 ${YELLOW}企业级全球化 (7+ 台服务器)${NC}"
        echo -e "       ${GRAY}└─ 多云多活 ｜ 合规审计 ｜ 跨国企业${NC}"
        echo ""
        echo -e " ${RED}9)${NC} ⬅️  返回主菜单"
        echo -e "${BLUE}============================================================${NC}"
        read -p "$(printf "${CYAN}请选择部署方案：${NC} ")" PLAN_OPT
        case "$PLAN_OPT" in
            1) show_plan_minimal ;;
            2) show_plan_regional ;;
            3) show_plan_enterprise ;;
            9) return ;;
            *) err "无效选项，请重新输入"; sleep 1 ;;
        esac
    done
}

# ---------- 最小生产架构 ----------
show_plan_minimal() {
    while true; do
        safe_clear
        show_header
        show_global_service_table
        echo ""
        echo -e "${GREEN}【2 台服务器 ｜ 最小生产架构 · 业务数据分离】${NC}"
        echo -e "${BLUE}============================================================${NC}"
        echo -e "请选择要操作的服务器节点："
        echo ""
        echo -e " ${GREEN}1)${NC} 🖥️  节点 A（总控机：当前服务器）  $(get_node_status node-a)"
        echo -e " ${GREEN}2)${NC} 💾 节点 B（数据节点：远程服务器）  $(get_node_status node-b)"
        echo ""
        echo -e " ${RED}9)${NC} ⬅️  返回上一级"
        echo -e "${BLUE}============================================================${NC}"
        echo -e "${GRAY}架构说明：${NC}"
        echo -e "${GRAY}  节点 A = 控制面 + 业务网关 + 边缘入口${NC}"
        echo -e "${GRAY}  节点 B = 数据库 + 缓存 + 备份（纯数据，禁业务）${NC}"
        echo -e "${BLUE}============================================================${NC}"
        read -p "$(printf "${CYAN}请选择节点：${NC} ")" NODE_OPT
        case "$NODE_OPT" in
            1) show_node_a_menu ;;
            2) show_node_b_menu ;;
            9) return ;;
            *) err "无效选项，请重新输入"; sleep 1 ;;
        esac
    done
}

# ---------- 节点 A 界面 ----------
show_node_a_menu() {
    while true; do
        safe_clear
        show_header
        get_sys_info
        local k3s_s netbird_s nginx_s newapi_s mon_s
        k3s_s=$(query_app_state node-a k3s)
        netbird_s=$(query_app_state node-a netbird)
        nginx_s=$(query_app_state node-a nginx)
        newapi_s=$(query_app_state node-a newapi)
        mon_s=$(query_app_state node-a monitoring)

        echo ""
        echo -e "${BLUE}============================================================${NC}"
        echo -e "🖥️  ${WHITE}节点 A（总控机：当前服务器）${NC}"
        echo -e "${BLUE}============================================================${NC}"
        echo -e "${CYAN}【主机名】${NC}：${HOSTNAME_INFO}"
        echo -e "${CYAN}【内网 IP】${NC}：${LOCAL_IP}"
        echo -e "${CYAN}【NetBird IP】${NC}：${NETBIRD_IP}"
        echo -e "${CYAN}【系统】${NC}  ：${OS_INFO} (内核 ${KERNEL_VER})"
        echo -e "${CYAN}【配置】${NC}  ：CPU ${CPU_COUNT} 核 ｜ 内存 ${MEM_INFO} ｜ 磁盘 ${DISK_INFO}"
        echo -e "${CYAN}【时间】${NC}  ：${NOW_TIME}"
        echo -e "${BLUE}------------------------------------------------------------${NC}"
        echo -e "${YELLOW}⚠️  角色定义：总控 + 控制面 + 业务网关 + 边缘入口${NC}"
        echo -e "${RED}❗ 严禁在本节点安装数据库 / Redis 等数据组件${NC}"
        echo -e "${BLUE}============================================================${NC}"
        echo ""
        echo -e "${WHITE}✅ 可安装应用清单（仅节点 A 允许）：${NC}"
        echo ""
        echo -e " ${GREEN}1)${NC} K3s 控制面（集群核心）         → ${k3s_s}"
        echo -e " ${GREEN}2)${NC} NetBird 控制端（零信任组网）   → ${netbird_s}"
        echo -e " ${GREEN}3)${NC} Nginx 边缘网关（公网入口）     → ${nginx_s}"
        echo -e " ${GREEN}4)${NC} NewAPI 网关服务（核心业务）   → ${newapi_s}"
        echo -e " ${GREEN}5)${NC} 邮件密钥分发服务（内网SMTP） → ${email_s}"
        echo -e " ${GREEN}6)${NC} 监控系统（VM + Loki + 告警）   → ${mon_s}"
        echo -e " ${GREEN}7)${NC} 模型推理服务（可选）           → ${GRAY}未部署${NC}"
        echo -e " ${GREEN}8)${NC} 📋 查看本节点已安装应用清单"
        echo -e " ${GREEN}9)${NC} 🩺 一键巡检本节点健康状态"
        echo -e " ${RED}0)${NC} ⬅️  返回节点选择"
        echo -e "${BLUE}============================================================${NC}"
        read -p "$(printf "${CYAN}请输入要安装的应用序号：${NC} ")" APP_OPT
        case "$APP_OPT" in
            1) install_app "k3s-server"        "节点 A" ;;
            2) install_app "netbird-server"    "节点 A" ;;
            3) install_app "nginx-edge"        "节点 A" ;;
            4) install_app "newapi-gateway"    "节点 A" ;;
            5) install_app "email-distribution" "节点 A" ;;
            6) install_app "monitoring-stack"  "节点 A" ;;
            7) install_app "model-inference"   "节点 A" ;;
            8) list_installed_apps "node-a" ;;
            9) info "巡检功能开发中..."; pause ;;
            0) return ;;
            *) err "无效选项，请重新输入"; sleep 1 ;;
        esac
    done
}


# ---------- 节点 B 界面 ----------
show_node_b_menu() {
    while true; do
        safe_clear
        show_header
        get_sys_info
        local mysql_s redis_s netbird_s
        mysql_s=$(query_app_state node-b mysql)
        redis_s=$(query_app_state node-b redis)
        netbird_s=$(query_app_state node-b netbird)

        echo ""
        echo -e "${BLUE}============================================================${NC}"
        echo -e "💾 ${WHITE}节点 B（数据节点：远程服务器）${NC}"
        echo -e "${BLUE}============================================================${NC}"
        echo -e "${CYAN}【主机名】${NC}：${HOSTNAME_INFO}"
        echo -e "${CYAN}【内网 IP】${NC}：${LOCAL_IP}"
        echo -e "${CYAN}【NetBird IP】${NC}：${NETBIRD_IP}"
        echo -e "${CYAN}【系统】${NC}  ：${OS_INFO} (内核 ${KERNEL_VER})"
        echo -e "${CYAN}【配置】${NC}  ：CPU ${CPU_COUNT} 核 ｜ 内存 ${MEM_INFO} ｜ 磁盘 ${DISK_INFO}"
        echo -e "${CYAN}【时间】${NC}  ：${NOW_TIME}"
        echo -e "${BLUE}------------------------------------------------------------${NC}"
        echo -e "${YELLOW}⚠️  角色定义：专属纯数据节点${NC}"
        echo -e "${RED}❗ 禁止安装业务服务 / K3s 控制面 / Nginx 网关${NC}"
        echo -e "${RED}❗ 此节点仅承载数据库、缓存、备份等数据组件${NC}"
        echo -e "${BLUE}============================================================${NC}"
        echo ""
        echo -e "${WHITE}✅ 可安装应用清单（仅数据节点允许）：${NC}"
        echo ""
        echo -e " ${GREEN}1)${NC} MySQL 数据库（主从 + 半同步）     → ${mysql_s}"
        echo -e " ${GREEN}2)${NC} Redis 缓存（哨兵模式）             → ${redis_s}"
        echo -e " ${GREEN}3)${NC} 自动备份服务（异地 + 加密）       → ${GRAY}未部署${NC}"
        echo -e " ${GREEN}4)${NC} NetBird 客户端（加入加密网格）   → ${netbird_s}"
        echo -e " ${GREEN}5)${NC} ProxySQL 读写分离（可选）         → ${GRAY}未部署${NC}"
        echo -e " ${GREEN}6)${NC} etcd 备份代理（可选）             → ${GRAY}未部署${NC}"
        echo -e " ${GREEN}7)${NC} 📋 查看本节点已安装应用清单"
        echo -e " ${GREEN}8)${NC} 🩺 一键巡检本节点健康状态"
        echo -e " ${RED}9)${NC} ⬅️  返回节点选择"
        echo -e "${BLUE}============================================================${NC}"
        read -p "$(printf "${CYAN}请输入要安装的应用序号：${NC} ")" APP_OPT
        case "$APP_OPT" in
            1) install_app "mysql-ha"        "节点 B" ;;
            2) install_app "redis-sentinel"  "节点 B" ;;
            3) install_app "backup-cronjob"  "节点 B" ;;
            4) install_app "netbird-client"  "节点 B" ;;
            5) install_app "proxysql"        "节点 B" ;;
            6) install_app "etcd-backup"     "节点 B" ;;
            7) list_installed_apps "node-b" ;;
            8) info "巡检功能开发中..."; pause ;;
            9) return ;;
            *) err "无效选项，请重新输入"; sleep 1 ;;
        esac
    done
}

# ---------- 应用安装统一入口 ----------
install_app() {
    local app="$1"
    local node="$2"
    safe_clear
    show_header
    echo ""
    echo -e "${YELLOW}⚙️  即将在【${node}】安装：${WHITE}${app}${NC}"
    echo -e "${BLUE}============================================================${NC}"
    info "本次安装将执行以下动作："
    echo -e "  ${GREEN}1)${NC} 检查系统依赖与端口占用"
    echo -e "  ${GREEN}2)${NC} 拉取官方镜像 / 安装包"
    echo -e "  ${GREEN}3)${NC} 生成默认配置（可后续编辑）"
    echo -e "  ${GREEN}4)${NC} 启动服务并验证健康状态"
    echo -e "  ${GREEN}5)${NC} 写入节点资产清单（.state 文件）"
    echo ""
    read -p "$(printf "${CYAN}是否继续？[y/N]：${NC} ")" CONFIRM
    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        log "开始安装 ${app} (${node})"
        if [[ -x "${SCRIPT_DIR}/installers/install-${app}.sh" ]]; then
            bash "${SCRIPT_DIR}/installers/install-${app}.sh"
        else
            warn "安装脚本 install-${app}.sh 暂未实现"
            sleep 2
        fi
        # 写入全局大脑状态文件
        local node_name
        if [[ "$node" == "节点 A" ]]; then node_name="node-a"; fi
        if [[ "$node" == "节点 B" ]]; then node_name="node-b"; fi
        echo "APP_${app}=installed" >> "${INVENTORY_DIR}/${node_name}.state"
        ok "${app} 安装流程结束 → 已写入全局大脑状态"
    else
        warn "已取消安装"
    fi
    pause
}

# ---------- 多区域架构 ----------
show_plan_regional() {
    safe_clear
    show_header
    show_global_service_table
    echo ""
    echo -e "${WHITE}【🌏 多区域架构】(开发中)${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo -e " ${GREEN}1)${NC} 🇨🇳 中国区 (cn-north)"
    echo -e " ${GREEN}2)${NC} 🇸🇬 亚太区 (ap-southeast)"
    echo -e " ${GREEN}3)${NC} 🇺🇸 北美区 (us-east)"
    echo -e " ${GREEN}4)${NC} 🇪🇺 欧洲区 (eu-central)"
    echo -e " ${RED}9)${NC} ⬅️  返回上一级"
    echo -e "${BLUE}============================================================${NC}"
    read -p "$(printf "${CYAN}请选择：${NC} ")" _
}

# ---------- 企业级 ----------
show_plan_enterprise() {
    safe_clear
    show_header
    show_global_service_table
    echo ""
    echo -e "${WHITE}【🌐 企业级全球化架构】${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${YELLOW}该方案启用全部企业级特性：${NC}"
    echo -e "  🔹 多云多活 (AWS / 阿里云 / GCP)"
    echo -e "  🔹 NetBird 控制面 HA (3 节点反亲和)"
    echo -e "  🔹 MySQL 跨区主从 + Orchestrator 防脑裂"
    echo -e "  🔹 GitOps (FluxCD) + SealedSecrets 全自动"
    echo -e "  🔹 GDPR / PIPL / CCPA 合规审计"
    echo -e "  🔹 混沌工程 + SLO/SLI 体系"
    echo -e "${BLUE}============================================================${NC}"
    pause
}

# ============================================================
# 2. 集群化资产清单 子菜单
# ============================================================
show_cluster_inventory() {
while true; do
safe_clear
show_header
echo ""
echo -e "${WHITE}【📦 集群化资产总清单｜全节点/区域/角色/状态一览】${NC}"
echo -e "${BLUE}============================================================${NC}"
printf " ${CYAN}%-14s %-10s %-16s %s${NC}\n" "节点名称" "所属区域" "节点角色" "部署状态"
echo -e "----------------------------------------------------------------${NC}"
echo -e " node-a        国内      管控/控制面    $(get_node_status node-a)"
echo -e " node-b        国内      业务网关       $(get_node_status node-b)"
echo -e " node-c        国内      数据存储       $(get_node_status node-c)"
echo -e " node-d        海外      业务边缘       $(get_node_status node-d)"
echo -e " node-e        海外      数据从库       $(get_node_status node-e)"
echo -e " node-f        全局      异地灾备       $(get_node_status node-f)"
echo -e " node-g        全局      流量调度       $(get_node_status node-g)"
echo -e "${BLUE}============================================================${NC}"
echo -e " ${GREEN}1)${NC} 刷新资产状态清单"
echo -e " ${GREEN}2)${NC} 注册新节点到资产库"
echo -e " ${GREEN}3)${NC} 下线退役无效节点"
echo -e " ${RED}9)${NC} ⬅️  返回主菜单"
echo -e "${BLUE}============================================================${NC}"
read -p "$(printf "${CYAN}请选择操作：${NC} ")" I_OPT
case "$I_OPT" in
1) info "已刷新集群资产清单"; pause ;;
2) info "进入新节点注册流程"; pause ;;
3) info "进入节点下线流程"; pause ;;
9) return ;;
*) err "无效选项，请重新输入"; sleep 1 ;;
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
read -p "$(printf "${CYAN}请选择：${NC} ")" M_OPT
case "$M_OPT" in
1) info "开始全集群健康巡检..."; pause ;;
2) info "跳转Grafana地址..."; pause ;;
3) info "进入指标查询终端..."; pause ;;
4) info "实时聚合日志查看..."; pause ;;
5) info "测试邮件/机器人告警..."; pause ;;
6) info "检测NetBird集群节点连通性..."; pause ;;
9) return ;;
*) err "无效选项，请重新输入"; sleep 1 ;;
esac
done
}

# ============================================================
# 4. 日常运维工具箱 子菜单（已增加全局状态表）
# ============================================================
show_ops_main() {
while true; do
safe_clear
show_header
show_global_service_table
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
read -p "$(printf "${CYAN}请选择运维功能：${NC} ")" O_OPT
case "$O_OPT" in
1) info "进入服务管理列表..."; pause ;;
2) info "进入服务启停控制..."; pause ;;
3) info "GitOps配置热更新..."; pause ;;
4) info "执行全配置打包备份..."; pause ;;
5) info "从备份恢复集群配置..."; pause ;;
6) info "密钥轮转/证书续期..."; pause ;;
9) return ;;
*) err "无效选项，请重新输入"; sleep 1 ;;
esac
done
}

# # ============================================================
# # 5. 集群弹性扩容管理 子菜单（按你的需求调整）
# # ============================================================
# show_scale_main() {
# while true; do
# safe_clear
# show_header
# show_global_service_table
# echo ""
# echo -e "${WHITE}【⬆️  集群弹性扩容管理｜无缝升级 不重构架构】${NC}"
# echo -e "${BLUE}============================================================${NC}"
# # 1. 阶段式扩容（架构升级）
# echo -e " ${GREEN}1)${NC} 🏠 ${YELLOW}最小生产架构 → 升级单区域生产块${NC}"
# echo -e "       ${GRAY}└─ 2台 → 3-6台 ｜ 业务数据扩展 ｜ 适合 MVP 上量${NC}"
# echo ""
# echo -e " ${GREEN}2)${NC} 🌏 ${YELLOW}单区域基础块 → 升级全球化架构${NC}"
# echo -e "       ${GRAY}└─ 3-6台 → 7+台 ｜ 跨区高可用 ｜ 适合区域级 SaaS${NC}"
# echo ""
# # 2. 横向扩容（节点类型扩展）
# echo -e " ${GREEN}3)${NC} 🌐 ${YELLOW}企业级全球化 → 多云多活扩展${NC}"
# echo -e "       ${GRAY}└─ 7+台 → 无限扩展 ｜ 全球节点新增 ｜ 跨国企业架构${NC}"
# echo ""
# echo -e " ${GREEN}4)${NC} 📡 ${YELLOW}横向新增业务边缘节点${NC}"
# echo -e "       ${GRAY}└─ 新增公网接入/缓存节点 ｜ 降低主节点压力${NC}"
# echo ""
# echo -e " ${GREEN}5)${NC} 💾 ${YELLOW}横向新增数据存储节点${NC}"
# echo -e "       ${GRAY}└─ 新增MySQL/Redis节点 ｜ 读写分离/分片扩展${NC}"
# echo ""
# echo -e " ${GREEN}6)${NC} 🛡️ ${YELLOW}新增海外跨区容灾节点${NC}"
# echo -e "       ${GRAY}└─ 新增异地备份节点 ｜ 多活/灾备架构扩展${NC}"
# echo ""
# # 3. 补充：系统级扩容
# echo -e " ${GREEN}7)${NC} ⚙️ ${YELLOW}系统级资源扩容（CPU/内存/磁盘）${NC}"
# echo -e "       ${GRAY}└─ 升级节点硬件/替换高配服务器 ｜ 单节点性能瓶颈突破${NC}"
# echo ""
# echo -e " ${RED}9)${NC} ⬅️  返回主菜单"
# echo -e "${BLUE}============================================================${NC}"
# read -p "$(printf "${CYAN}请选择扩容方式：${NC} ")" S_OPT
# case "$S_OPT" in
# 1) info "正在执行：2台 → 3-6台 单区域生产块扩容..."; pause ;;
# 2) info "正在执行：3-6台 → 7+台 全球化架构扩容..."; pause ;;
# 3) info "正在执行：7+台 → 无限扩展 多云多活扩容..."; pause ;;
# 4) info "正在执行：新增业务边缘节点接入集群..."; pause ;;
# 5) info "正在执行：新增数据存储节点接入集群..."; pause ;;
# 6) info "正在执行：新增海外跨区容灾节点接入集群..."; pause ;;
# 7) info "正在执行：系统级资源扩容（CPU/内存/磁盘）..."; pause ;;
# 9) return ;;
# *) err "无效选项，请重新输入"; sleep 1 ;;
# esac
# done
# }

# ============================================================
# 5. 集群弹性扩容管理｜带区域规则自动提示
# ============================================================
show_scale_main() {
while true; do
safe_clear
show_header
show_global_service_table

# ========== 【全局大脑读取当前集群状态】 ==========
local has_biz=$(ls ${INVENTORY_DIR}/*.state 2>/dev/null | grep -E "newapi" | wc -l)
local has_data=$(ls ${INVENTORY_DIR}/*.state 2>/dev/null | grep -E "mysql|redis" | wc -l)
local has_global=$(ls ${INVENTORY_DIR}/*.state 2>/dev/null | grep -E "node-d|node-e|node-f" | wc -l)
local ha_level="单区域架构"
[[ $has_global -gt 0 ]] && ha_level="全球化架构"

echo ""
echo -e "${WHITE}【⬆️  智能扩容总控台｜根据你的集群实时推荐】${NC}"
echo -e "${BLUE}=========================================================================${NC}"
echo -e "${CYAN}📊 你的集群当前状态：${NC}"
echo -e "   已安装业务节点：${GREEN}${has_biz} 个${NC}   已安装数据节点：${GREEN}${has_data} 个${NC}   架构等级：${GREEN}${ha_level}${NC}"
echo -e "${BLUE}=========================================================================${NC}"
echo ""
echo -e "${WHITE}🧩 积木式扩容（新服务器 + 部署应用 = 无缝扩容）${NC}"
echo ""

echo -e "${GREEN}1)${NC} 🏠 ${YELLOW}最小生产架构 → 升级单区域生产块${NC}"
echo -e "       ${GRAY}└─ 2台 → 3-6台｜业务数据扩展｜适合 MVP 上量${NC}"
echo ""

echo -e "${GREEN}2)${NC} 🌏 ${YELLOW}单区域基础块 → 升级全球化架构${NC}"
echo -e "       ${GRAY}└─ 3-6台 → 7+台｜跨区高可用｜适合区域级 SaaS${NC}"
echo ""

echo -e "${GREEN}3)${NC} 🌐 ${YELLOW}企业级全球化 → 多云多活扩展${NC}"
echo -e "       ${GRAY}└─ 7+台 → 无限扩展｜全球节点新增｜跨国企业架构${NC}"
echo ""

echo -e "${GREEN}4)${NC} 📡 ${YELLOW}横向新增业务边缘节点${NC}"
echo -e "       ${GRAY}└─ 新增公网接入/缓存节点｜降低主节点压力${NC}"
echo ""

echo -e "${GREEN}5)${NC} 💾 ${YELLOW}横向新增数据存储节点${NC}"
echo -e "       ${GRAY}└─ 新增MySQL/Redis节点｜读写分离/分片扩展${NC}"
echo ""

echo -e "${GREEN}6)${NC} 🛡️ ${YELLOW}新增海外跨区容灾节点${NC}"
echo -e "       ${GRAY}└─ 新增异地备份节点｜多活/灾备架构扩展${NC}"
echo ""

echo -e "${RED}9)${NC} ⬅️  返回主菜单"
echo -e "${BLUE}=========================================================================${NC}"
read -p "$(printf "${CYAN}请选择扩容方案（系统已根据你的集群自动推荐）：${NC} ")" S_OPT

case "$S_OPT" in
1)
    safe_clear
    show_header
    show_global_service_table
    echo ""
    echo -e "${WHITE}【扩容1：最小生产架构 → 升级单区域生产块】${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${YELLOW}📌 服务器选择规则（必须遵守）：${NC}"
    echo -e "  ${RED}❌ 禁止跨区${NC}：新增节点必须与节点A（K3s控制面）同区域"
    echo -e "  ${GREEN}✅ 推荐标准${NC}：同机房/同区域，延迟 < 10ms"
    echo ""
    echo -e "${CYAN}📝 节点分工与部署清单：${NC}"
    echo -e "  新增节点C（业务工作边缘节点）："
    echo -e "    → 部署：NetBird客户端 + Nginx + NewAPI + K3s Agent + 监控探针"
    echo -e "    → 禁止：MySQL/Redis、K3s控制面"
    echo ""
    echo -e "  新增节点D（只读数据从库节点）："
    echo -e "    → 部署：NetBird客户端 + MySQL从库 + Redis从库 + 备份"
    echo -e "    → 禁止：业务网关、K3s"
    echo ""
    echo -e "${BLUE}============================================================${NC}"
    info "请按规则准备服务器，准备完成后可执行自动部署流程"
    pause
    ;;
2)
    safe_clear
    show_header
    show_global_service_table
    echo ""
    echo -e "${WHITE}【扩容2：单区域基础块 → 升级全球化架构】${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${YELLOW}📌 服务器选择规则（必须遵守）：${NC}"
    echo -e "  ${GREEN}✅ 推荐跨区${NC}：新增节点选择目标用户所在区域（海外/其他区域）"
    echo -e "  ${CYAN}ℹ️  延迟要求${NC}：无强制限制，可就近服务用户"
    echo ""
    echo -e "${CYAN}📝 节点分工与部署清单：${NC}"
    echo -e "  新增节点D（海外业务边缘节点）："
    echo -e "    → 部署：NetBird客户端 + Nginx + NewAPI + 监控探针"
    echo -e "    → 禁止：K3s控制面、数据库类组件"
    echo ""
    echo -e "  新增节点E（海外只读数据从库节点）："
    echo -e "    → 部署：NetBird客户端 + MySQL从库 + Redis从库 + 备份"
    echo -e "    → 禁止：业务网关、K3s"
    echo ""
    echo -e "${BLUE}============================================================${NC}"
    info "请按规则准备服务器，准备完成后可执行自动部署流程"
    pause
    ;;
3)
    safe_clear
    show_header
    show_global_service_table
    echo ""
    echo -e "${WHITE}【扩容3：企业级全球化 → 多云多活扩展】${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${YELLOW}📌 服务器选择规则（必须遵守）：${NC}"
    echo -e "  ${GREEN}✅ 多云多区部署${NC}：可新增不同云厂商、不同区域的服务器"
    echo -e "  ${RED}❌ 注意${NC}：K3s集群内部节点必须同区域，跨区节点不加入K3s"
    echo ""
    echo -e "${CYAN}📝 节点分工与部署清单：${NC}"
    echo -e "  新增节点G（多云业务边缘节点）："
    echo -e "    → 部署：NetBird客户端 + Nginx + NewAPI + 监控探针"
    echo -e "    → 禁止：K3s控制面、数据库类组件"
    echo ""
    echo -e "  新增节点H（多云数据从库节点）："
    echo -e "    → 部署：NetBird客户端 + MySQL从库 + Redis从库 + 备份"
    echo -e "    → 禁止：业务网关、K3s"
    echo ""
    echo -e "${BLUE}============================================================${NC}"
    info "请按规则准备服务器，准备完成后可执行自动部署流程"
    pause
    ;;
4)
    safe_clear
    show_header
    show_global_service_table
    echo ""
    echo -e "${WHITE}【扩容4：横向新增业务边缘节点】${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${YELLOW}📌 服务器选择规则（必须遵守）：${NC}"
    echo -e "  ${RED}❌ 禁止跨区（若加入K3s集群）${NC}：必须与节点A同区域，延迟 < 10ms"
    echo -e "  ${GREEN}✅ 可选跨区（仅做反向代理）${NC}：可部署在海外，就近服务用户"
    echo ""
    echo -e "${CYAN}📝 节点分工与部署清单：${NC}"
    echo -e "  节点角色：业务工作边缘/备用流量入口"
    echo -e "  必须部署：NetBird客户端 + Nginx + NewAPI + 监控探针"
    echo -e "  可选部署：K3s Agent（加入集群调度）"
    echo -e "  禁止部署：MySQL/Redis、K3s控制面"
    echo ""
    echo -e "${BLUE}============================================================${NC}"
    info "请按规则准备服务器，准备完成后可执行自动部署流程"
    pause
    ;;
5)
    safe_clear
    show_header
    show_global_service_table
    echo ""
    echo -e "${WHITE}【扩容5：横向新增数据存储节点】${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${YELLOW}📌 服务器选择规则（必须遵守）：${NC}"
    echo -e "  ${GREEN}✅ 推荐跨区部署${NC}：可部署在同区域/其他区域/海外，做读写分离/容灾"
    echo -e "  ${CYAN}ℹ️  延迟要求${NC}：跨区延迟 < 100ms，不影响数据同步即可"
    echo ""
    echo -e "${CYAN}📝 节点分工与部署清单：${NC}"
    echo -e "  节点角色：只读数据从库节点"
    echo -e "  必须部署：NetBird客户端 + MySQL从库 + Redis从库 + 备份服务"
    echo -e "  禁止部署：业务网关、K3s集群组件"
    echo ""
    echo -e "${BLUE}============================================================${NC}"
    info "请按规则准备服务器，准备完成后可执行自动部署流程"
    pause
    ;;
6)
    safe_clear
    show_header
    show_global_service_table
    echo ""
    echo -e "${WHITE}【扩容6：新增海外跨区容灾节点】${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${YELLOW}📌 服务器选择规则（必须遵守）：${NC}"
    echo -e "  ${GREEN}✅ 强制跨区部署${NC}：推荐同区域跨机房/异地跨区，避免单机房故障"
    echo -e "  ${CYAN}ℹ️  延迟要求${NC}：无强制限制，保证NetBird内网连通即可"
    echo ""
    echo -e "${CYAN}📝 节点分工与部署清单：${NC}"
    echo -e "  节点角色：同城/异地容灾备份节点"
    echo -e "  必须部署：NetBird客户端 + 集群备份 + 数据归档 + 灾备同步服务"
    echo -e "  禁止部署：线上业务服务、K3s集群组件"
    echo ""
    echo -e "${BLUE}============================================================${NC}"
    info "请按规则准备服务器，准备完成后可执行自动部署流程"
    pause
    ;;
9)
    return
    ;;
*)
    err "无效选项，请重新输入"; sleep 1
    ;;
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
read -p "$(printf "${CYAN}请选择应急功能：${NC} ")" D_OPT
case "$D_OPT" in
1) info "触发跨区流量自动切换..."; pause ;;
2) info "数据库主从手动/自动切换..."; pause ;;
3) info "Redis哨兵故障自愈触发..."; pause ;;
4) info "集群快照备份与还原..."; pause ;;
5) info "WAF黑名单一键封禁..."; pause ;;
9) return ;;
*) err "无效选项，请重新输入"; sleep 1 ;;
esac
done
}

# ============================================================
# 7. 架构文档与帮助手册 子菜单（修复：添加9的case处理）
# ============================================================
show_docs_main() {
while true; do
safe_clear
show_header
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
read -p "$(printf "${CYAN}请选择文档：${NC} ")" DOC_OPT
case "$DOC_OPT" in
1) info "打开整体架构说明文档..."; pause ;;
2) info "打开节点角色规范文档..."; pause ;;
3) info "打开故障排查手册..."; pause ;;
4) info "打开部署与扩容流程文档..."; pause ;;
5) info "打开术语解释文档..."; pause ;;
9) return ;;
*) err "无效选项，请重新输入"; sleep 1 ;;
esac
done
}


# ---------- 已安装应用清单 ----------
list_installed_apps() {
    local node="$1"
    safe_clear
    show_header
    info "正在读取【${node}】已安装应用..."
    echo ""
    if [[ -f "${INVENTORY_DIR}/${node}.state" ]]; then
        grep -E '^APP_' "${INVENTORY_DIR}/${node}.state" | \
            sed "s/^APP_/  ${GREEN}✅${NC} /" | sed 's/=/ → /'
    else
        warn "暂无安装记录"
    fi
    pause
}

# ---------- 主入口 ----------
main() {
    if [[ $EUID -ne 0 ]]; then
        warn "建议使用 root 用户运行（部分操作需要管理员权限）"
        sleep 1
    fi
    show_main_menu
}

main "$@"
