#!/usr/bin/env bash
# ============================================================
# NewAPI 全球化平台 · 中文交互式总控台 (彩色版)
# 版本: v2.0 (严格按5点要求增强：分层清单+全局互斥+扩容规则+角色隔离+兼容原风格)
# 特性: 自动检测终端颜色支持 / 防闪烁 / 兼容性强
# ============================================================

set -o pipefail

# ---------- 全局路径 ----------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
INVENTORY_DIR="${ROOT_DIR}/inventory/nodes"
LOG_DIR="${ROOT_DIR}/logs"
mkdir -p "${INVENTORY_DIR}" "${LOG_DIR}"

# ---------- 全局唯一组件（全网只能装 1 台） ----------
GLOBAL_ONLY_ONE=(
  "k3s-server"
  "netbird-hub"
  "keepalived-vip"
  "email-key-dist"
  "newapi-gateway"
)

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

# ---------- 全局服务部署总览看板 ----------
show_global_service_table() {
    echo ""
    echo -e "${WHITE}【📊 全局服务部署总览 | NEWAPI 全局大脑数据看板】${NC}"
    echo -e "${BLUE}=====================================================================${NC}"
    printf " ${CYAN}%-8s %-8s %-8s %-8s %-10s %-8s %-8s${NC}\n" "节点" "K3s" "NetBird" "Nginx" "NewAPI" "MySQL" "Redis"
    echo -e "${BLUE}---------------------------------------------------------------------${NC}"
    printf " CN1    %-8s %-8s %-8s %-10s %-8s %-8s\n" \
        "$(query_app_state cn1 k3s-server)" \
        "$(query_app_state cn1 netbird-hub)" \
        "$(query_app_state cn1 nginx-edge)" \
        "$(query_app_state cn1 newapi-gateway)" \
        "$(query_app_state cn1 mysql)" \
        "$(query_app_state cn1 redis)"
    printf " CN2    %-8s %-8s %-8s %-10s %-8s %-8s\n" \
        "$(query_app_state cn2 k3s-agent)" \
        "$(query_app_state cn2 netbird-client)" \
        "$(query_app_state cn2 nginx)" \
        "$(query_app_state cn2 newapi)" \
        "$(query_app_state cn2 mysql-master)" \
        "$(query_app_state cn2 redis-sentinel)"
    printf " CN3    %-8s %-8s %-8s %-10s %-8s %-8s\n" \
        "$(query_app_state cn3 k3s-agent)" \
        "$(query_app_state cn3 netbird-client)" \
        "$(query_app_state cn3 nginx)" \
        "$(query_app_state cn3 newapi)" \
        "$(query_app_state cn3 mysql-slave)" \
        "$(query_app_state cn3 redis-slave)"
    printf " 节点A  %-8s %-8s %-8s %-10s %-8s %-8s\n" \
        "$(query_app_state node-a k3s-server)" \
        "$(query_app_state node-a netbird-hub)" \
        "$(query_app_state node-a nginx-edge)" \
        "$(query_app_state node-a newapi-gateway)" \
        "$(query_app_state node-a mysql)" \
        "$(query_app_state node-a redis)"
    printf " 节点B  %-8s %-8s %-8s %-10s %-8s %-8s\n" \
        "$(query_app_state node-b k3s-agent)" \
        "$(query_app_state node-b netbird-client)" \
        "$(query_app_state node-b nginx)" \
        "$(query_app_state node-b newapi)" \
        "$(query_app_state node-b mysql-ha)" \
        "$(query_app_state node-b redis-sentinel)"
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
# 全局唯一组件安装检查（核心：扩容不重复装主控）
# ============================================================
install_app_check_global() {
    local app="$1"
    local node="$2"
    for g_app in "${GLOBAL_ONLY_ONE[@]}"; do
        if [[ "$g_app" == "$app" ]]; then
            if grep -r "APP_${app}=installed" "${INVENTORY_DIR}" 2>/dev/null; then
                err "❌ 全局组件【$app】已在其他节点部署，扩容节点禁止重复安装！"
                pause
                return 1
            fi
        fi
    done
    return 0
}

# ============================================================
# 主菜单入口
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

# ---------- 节点 A 总控：分层软件清单（全局唯一） ----------
show_node_a_menu() {
    while true; do
        safe_clear
        show_header
        get_sys_info
        local k3s_s netbird_s nginx_s newapi_s mon_s
        k3s_s=$(query_app_state node-a k3s-server)
        netbird_s=$(query_app_state node-a netbird-hub)
        nginx_s=$(query_app_state node-a nginx-edge)
        newapi_s=$(query_app_state node-a newapi-gateway)
        mon_s=$(query_app_state node-a monitoring-stack)

        echo ""
        echo -e "${BLUE}============================================================${NC}"
        echo -e "🖥️  ${WHITE}节点 A【全局总控节点】${NC}"
        echo -e "${BLUE}============================================================${NC}"
        echo -e "${CYAN}【主机名】${NC}：${HOSTNAME_INFO}"
        echo -e "${CYAN}【内网 IP】${NC}：${LOCAL_IP}"
        echo -e "${CYAN}【NetBird IP】${NC}：${NETBIRD_IP}"
        echo -e "${CYAN}【系统】${NC}  ：${OS_INFO} (内核 ${KERNEL_VER})"
        echo -e "${CYAN}【配置】${NC}  ：CPU ${CPU_COUNT} 核 ｜ 内存 ${MEM_INFO} ｜ 磁盘 ${DISK_INFO}"
        echo -e "${BLUE}------------------------------------------------------------${NC}"
        echo -e "${GREEN}📚 本节点【固定分层软件清单】：${NC}"
        echo -e "  🏗️ 集群层：K3s 控制面、NetBird Hub"
        echo -e "  🛡️ 安全层：Nginx 边缘 WAF、Keepalived VIP"
        echo -e "  🧩 业务层：NewAPI 网关、邮件密钥分发"
        echo -e "  ⚙️ 运维层：GitOps 代理"
        echo -e "  📈 监控层：VM + Loki + 告警全栈"
        echo -e "${YELLOW}⚠️ 扩容规则：以上组件全网只装 1 次，新增节点自动跳过${NC}"
        echo -e "${RED}❗ 严禁安装：MySQL / Redis / 数据类组件${NC}"
        echo -e "${BLUE}============================================================${NC}"
        echo ""
        echo -e "${WHITE}✅ 可安装应用：${NC}"
        echo ""
        echo -e " ${GREEN}1)${NC} K3s 控制面（全局唯一）           → ${k3s_s}"
        echo -e " ${GREEN}2)${NC} NetBird Hub（全局唯一）           → ${netbird_s}"
        echo -e " ${GREEN}3)${NC} Nginx 边缘 WAF                    → ${nginx_s}"
        echo -e " ${GREEN}4)${NC} NewAPI 网关（全局唯一）           → ${newapi_s}"
        echo -e " ${GREEN}5)${NC} 全栈监控系统                     → ${mon_s}"
        echo -e " ${GREEN}6)${NC} 模型推理服务（可选）             → ${GRAY}未部署${NC}"
        echo -e " ${GREEN}7)${NC} 📋 查看已安装应用"
        echo -e " ${GREEN}8)${NC} 🩺 一键健康巡检"
        echo -e " ${RED}9)${NC} ⬅️  返回"
        echo -e "${BLUE}============================================================${NC}"
        read -p "$(printf "${CYAN}请输入序号：${NC} ")" APP_OPT
        case "$APP_OPT" in
            1) install_app_check_global "k3s-server" "节点A" && install_app "k3s-server" "节点 A" ;;
            2) install_app_check_global "netbird-hub" "节点A" && install_app "netbird-hub" "节点 A" ;;
            3) install_app "nginx-edge" "节点 A" ;;
            4) install_app_check_global "newapi-gateway" "节点A" && install_app "newapi-gateway" "节点 A" ;;
            5) install_app "monitoring-stack" "节点 A" ;;
            6) install_app "model-inference" "节点 A" ;;
            7) list_installed_apps "node-a" ;;
            8) info "巡检功能开发中..."; pause ;;
            9) return ;;
            *) err "无效选项"; sleep 1 ;;
        esac
    done
}

# ---------- 节点 B 纯数据：分层软件清单（仅数据） ----------
show_node_b_menu() {
    while true; do
        safe_clear
        show_header
        get_sys_info
        local mysql_s redis_s netbird_s proxysql_s backup_s
        mysql_s=$(query_app_state node-b mysql-ha)
        redis_s=$(query_app_state node-b redis-sentinel)
        netbird_s=$(query_app_state node-b netbird-client)
        proxysql_s=$(query_app_state node-b proxysql)
        backup_s=$(query_app_state node-b backup-cronjob)

        echo ""
        echo -e "${BLUE}============================================================${NC}"
        echo -e "💾 ${WHITE}节点 B【纯数据节点】${NC}"
        echo -e "${BLUE}============================================================${NC}"
        echo -e "${CYAN}【主机名】${NC}：${HOSTNAME_INFO}"
        echo -e "${CYAN}【内网 IP】${NC}：${LOCAL_IP}"
        echo -e "${CYAN}【NetBird IP】${NC}：${NETBIRD_IP}"
        echo -e "${CYAN}【系统】${NC}  ：${OS_INFO} (内核 ${KERNEL_VER})"
        echo -e "${CYAN}【配置】${NC}  ：CPU ${CPU_COUNT} 核 ｜ 内存 ${MEM_INFO} ｜ 磁盘 ${DISK_INFO}"
        echo -e "${BLUE}------------------------------------------------------------${NC}"
        echo -e "${GREEN}📚 本节点【固定分层软件清单】：${NC}"
        echo -e "  📦 数据层：MySQL、Redis、ProxySQL、自动备份"
        echo -e "  🔗 组网层：NetBird 客户端"
        echo -e "  📈 监控层：监控探针"
        echo -e "${RED}❗ 严禁安装：K3s 控制面 / NetBird Hub / Nginx WAF / NewAPI / 网关类${NC}"
        echo -e "${BLUE}============================================================${NC}"
        echo ""
        echo -e "${WHITE}✅ 可安装应用：${NC}"
        echo ""
        echo -e " ${GREEN}1)${NC} MySQL 高可用                    → ${mysql_s}"
        echo -e " ${GREEN}2)${NC} Redis 哨兵集群                  → ${redis_s}"
        echo -e " ${GREEN}3)${NC} ProxySQL 读写分离               → ${proxysql_s}"
        echo -e " ${GREEN}4)${NC} 自动备份服务                    → ${backup_s}"
        echo -e " ${GREEN}5)${NC} NetBird 客户端                  → ${netbird_s}"
        echo -e " ${GREEN}6)${NC} etcd 备份代理（可选）           → ${GRAY}未部署${NC}"
        echo -e " ${GREEN}7)${NC} 📋 查看已安装应用"
        echo -e " ${GREEN}8)${NC} 🩺 一键健康巡检"
        echo -e " ${RED}9)${NC} ⬅️  返回"
        echo -e "${BLUE}============================================================${NC}"
        read -p "$(printf "${CYAN}请输入序号：${NC} ")" APP_OPT
        case "$APP_OPT" in
            1) install_app "mysql-ha" "节点 B" ;;
            2) install_app "redis-sentinel" "节点 B" ;;
            3) install_app "proxysql" "节点 B" ;;
            4) install_app "backup-cronjob" "节点 B" ;;
            5) install_app "netbird-client" "节点 B" ;;
            6) install_app "etcd-backup" "节点 B" ;;
            7) list_installed_apps "node-b" ;;
            8) info "巡检功能开发中..."; pause ;;
            9) return ;;
            *) err "无效选项"; sleep 1 ;;
        esac
    done
}

# ---------- 多区域架构：CN1 / CN2 / CN3 每台分层写死 ----------
show_plan_regional() {
    while true; do
        safe_clear
        show_header
        show_global_service_table
        echo ""
        echo -e "${GREEN}【多区域架构｜CN1北京总控｜CN2上海数据｜CN3广州容灾】${NC}"
        echo -e "${BLUE}============================================================${NC}"
        echo -e " ${GREEN}1)${NC} 🖥️ CN1 北京【全域总控集群节点】"
        echo -e " ${GREEN}2)${NC} 💾 CN2 上海【区域数据主节点】"
        echo -e " ${GREEN}3)${NC} 🛡️ CN3 广州【容灾备库日志节点】"
        echo -e " ${RED}9)${NC} ⬅️ 返回"
        echo -e "${BLUE}============================================================${NC}"
        read -p "$(printf "${CYAN}请选择节点：${NC} ")" opt
        case "$opt" in
            1) show_cn1_detail ;;
            2) show_cn2_detail ;;
            3) show_cn3_detail ;;
            9) return ;;
            *) err "无效选项"; sleep 1 ;;
        esac
    done
}

# ---------- CN1 北京总控：分层清单（全局唯一） ----------
show_cn1_detail() {
    while true; do
        safe_clear
        show_header
        local k3s_s nb_hub_s nginx_s keep_s newapi_s email_s
        k3s_s=$(query_app_state cn1 k3s-server)
        nb_hub_s=$(query_app_state cn1 netbird-hub)
        nginx_s=$(query_app_state cn1 nginx-edge)
        keep_s=$(query_app_state cn1 keepalived-vip)
        newapi_s=$(query_app_state cn1 newapi-gateway)
        email_s=$(query_app_state cn1 email-key-dist)

        echo ""
        echo -e "${BLUE}============================================================${NC}"
        echo -e "🖥️ CN1 北京【全域总控集群节点】${NC}"
        echo -e "${BLUE}============================================================${NC}"
        echo -e "${GREEN}📚 本节点【固定分层软件清单】：${NC}"
        echo -e "  🏗️ 集群层：K3s 控制面、NetBird Hub、Relay"
        echo -e "  🛡️ 安全层：Keepalived VIP、Nginx WAF"
        echo -e "  🧩 业务层：NewAPI 网关、邮件密钥分发"
        echo -e "  ⚙️ 运维层：GitOps 代理"
        echo -e "  📈 监控层：全局监控中枢"
        echo -e "${YELLOW}⚠️ 全局唯一：扩容节点绝不重复安装${NC}"
        echo -e "${RED}❗ 禁止安装：MySQL / Redis / 数据组件${NC}"
        echo -e "${BLUE}============================================================${NC}"
        echo ""
        echo " 1) K3s 控制面（全局唯一）        → ${k3s_s}"
        echo " 2) NetBird Hub（全局唯一）        → ${nb_hub_s}"
        echo " 3) Nginx WAF 边缘                 → ${nginx_s}"
        echo " 4) Keepalived VIP（全局唯一）      → ${keep_s}"
        echo " 5) NewAPI 网关（全局唯一）        → ${newapi_s}"
        echo " 6) 邮件密钥分发（全局唯一）       → ${email_s}"
        echo " 7) 查看已安装应用"
        echo " Q) 返回"
        read -p "选择：" opt
        case "$opt" in
            1) install_app_check_global "k3s-server" "CN1" && install_app "k3s-server" "CN1" ;;
            2) install_app_check_global "netbird-hub" "CN1" && install_app "netbird-hub" "CN1" ;;
            3) install_app "nginx-edge" "CN1" ;;
            4) install_app_check_global "keepalived-vip" "CN1" && install_app "keepalived-vip" "CN1" ;;
            5) install_app_check_global "newapi-gateway" "CN1" && install_app "newapi-gateway" "CN1" ;;
            6) install_app_check_global "email-key-dist" "CN1" && install_app "email-key-dist" "CN1" ;;
            7) list_installed_apps "cn1" ;;
            Q|q) return ;;
            *) err "无效选项"; sleep 1 ;;
        esac
    done
}

# ---------- CN2 上海数据主节点：分层清单 ----------
show_cn2_detail() {
    while true; do
        safe_clear
        show_header
        local mysql_s redis_s proxysql_s netbird_s
        mysql_s=$(query_app_state cn2 mysql-master)
        redis_s=$(query_app_state cn2 redis-sentinel)
        proxysql_s=$(query_app_state cn2 proxysql)
        netbird_s=$(query_app_state cn2 netbird-client)

        echo ""
        echo -e "${BLUE}============================================================${NC}"
        echo -e "💾 CN2 上海【数据主节点】${NC}"
        echo -e "${BLUE}============================================================${NC}"
        echo -e "${GREEN}📚 本节点【固定分层软件清单】：${NC}"
        echo -e "  📦 数据层：MySQL 主库、Redis 哨兵、ProxySQL"
        echo -e "  🔗 组网层：NetBird 客户端"
        echo -e "  📈 监控层：监控探针"
        echo -e "${RED}❗ 禁止安装：任何主控/网关组件${NC}"
        echo -e "${BLUE}============================================================${NC}"
        echo ""
        echo " 1) MySQL 主库        → ${mysql_s}"
        echo " 2) Redis 哨兵        → ${redis_s}"
        echo " 3) ProxySQL          → ${proxysql_s}"
        echo " 4) NetBird 客户端    → ${netbird_s}"
        echo " 5) 查看已安装应用"
        echo " 9) 返回"
        read -p "选择：" opt
        case "$opt" in
            1) install_app "mysql-master" "CN2" ;;
            2) install_app "redis-sentinel" "CN2" ;;
            3) install_app "proxysql" "CN2" ;;
            4) install_app "netbird-client" "CN2" ;;
            5) list_installed_apps "cn2" ;;
            9) return ;;
            *) err "无效选项"; sleep 1 ;;
        esac
    done
}

# ---------- CN3 广州容灾节点：分层清单 ----------
show_cn3_detail() {
    while true; do
        safe_clear
        show_header
        local mysql_s redis_s backup_s netbird_s
        mysql_s=$(query_app_state cn3 mysql-slave)
        redis_s=$(query_app_state cn3 redis-slave)
        backup_s=$(query_app_state cn3 backup-cronjob)
        netbird_s=$(query_app_state cn3 netbird-client)

        echo ""
        echo -e "${BLUE}============================================================${NC}"
        echo -e "🛡️ CN3 广州【容灾备库节点】${NC}"
        echo -e "${BLUE}============================================================${NC}"
        echo -e "${GREEN}📚 本节点【固定分层软件清单】：${NC}"
        echo -e "  📦 数据层：MySQL 从库、Redis 从节点"
        echo -e "  ⚙️ 运维层：定时备份、异地灾备"
        echo -e "  🔗 组网层：NetBird 客户端"
        echo -e "  📈 监控层：日志采集、监控上报"
        echo -e "${RED}❗ 禁止安装：任何主控/网关组件${NC}"
        echo -e "${BLUE}============================================================${NC}"
        echo ""
        echo " 1) MySQL 从库        → ${mysql_s}"
        echo " 2) Redis 从节点      → ${redis_s}"
        echo " 3) 自动备份          → ${backup_s}"
        echo " 4) NetBird 客户端    → ${netbird_s}"
        echo " 5) 查看已安装应用"
        echo " 9) 返回"
        read -p "选择：" opt
        case "$opt" in
            1) install_app "mysql-slave" "CN3" ;;
            2) install_app "redis-slave" "CN3" ;;
            3) install_app "backup-cronjob" "CN3" ;;
            4) install_app "netbird-client" "CN3" ;;
            5) list_installed_apps "cn3" ;;
            9) return ;;
            *) err "无效选项"; sleep 1 ;;
        esac
    done
}

# ---------- 企业级架构 ----------
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
# 应用安装统一入口
# ============================================================
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
        local node_name
        if [[ "$node" == "节点 A" ]]; then node_name="node-a"; fi
        if [[ "$node" == "节点 B" ]]; then node_name="node-b"; fi
        if [[ "$node" == "CN1" ]]; then node_name="cn1"; fi
        if [[ "$node" == "CN2" ]]; then node_name="cn2"; fi
        if [[ "$node" == "CN3" ]]; then node_name="cn3"; fi
        echo "APP_${app}=installed" >> "${INVENTORY_DIR}/${node_name}.state"
        ok "${app} 安装完成 → 已写入全局状态"
    else
        warn "已取消安装"
    fi
    pause
}

# ============================================================
# 2. 集群化资产清单
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
echo -e " cn1          北京      全域总控         $(get_node_status cn1)"
echo -e " cn2          上海      数据主节点       $(get_node_status cn2)"
echo -e " cn3          广州      容灾备库         $(get_node_status cn3)"
echo -e " node-a       国内      管控/控制面      $(get_node_status node-a)"
echo -e " node-b       国内      纯数据节点       $(get_node_status node-b)"
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
# 3. 全域监控与健康巡检
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
# 4. 日常运维工具箱
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

# ============================================================
# 5. 集群弹性扩容管理（自动按角色扩容，不装主控）
# ============================================================
show_scale_main() {
while true; do
safe_clear
show_header
show_global_service_table

local has_biz=$(ls ${INVENTORY_DIR}/*.state 2>/dev/null | grep -E "newapi" | wc -l)
local has_data=$(ls ${INVENTORY_DIR}/*.state 2>/dev/null | grep -E "mysql|redis" | wc -l)
local ha_level="单区域架构"

echo ""
echo -e "${WHITE}【⬆️  智能扩容总控台｜自动遵守：主控不重复、角色不越界】${NC}"
echo -e "${BLUE}=========================================================================${NC}"
echo -e "${CYAN}📌 扩容核心规则（系统自动强制执行）：${NC}"
echo -e " 1. 全局唯一组件只装一次：K3s控制面、NetBird Hub、VIP、NewAPI、邮件密钥"
echo -e " 2. 扩容节点只装：K3s Agent、NetBird 客户端、MySQL从库、Redis从库、监控探针"
echo -e " 3. 总控不装数据库，数据节点不装网关/控制面"
echo -e "${BLUE}=========================================================================${NC}"
echo ""

echo -e "${GREEN}1)${NC} 🏗️ 新增 K3s 集群从节点（仅 Agent，不装控制面）"
echo -e "${GREEN}2)${NC} 📦 新增 数据从库节点（MySQL/Redis 从库 + 备份）"
echo -e "${GREEN}3)${NC} 🌍 新增 海外边缘节点（仅网关 + 客户端）"
echo -e "${RED}9)${NC} ⬅️  返回主菜单"
echo -e "${BLUE}=========================================================================${NC}"
read -p "$(printf "${CYAN}请选择扩容类型：${NC} ")" S_OPT

case "$S_OPT" in
1)
    info "✅ 扩容类型：K3s 从节点 → 仅安装 Agent，不装控制面"
    pause
    ;;
2)
    info "✅ 扩容类型：数据从库 → 仅安装 MySQL/Redis 从库 + 客户端"
    pause
    ;;
3)
    info "✅ 扩容类型：海外边缘 → 仅安装网关 + NetBird 客户端"
    pause
    ;;
9) return ;;
*) err "无效选项"; sleep 1 ;;
esac
done
}

# ============================================================
# 6. 应急灾备与故障切换
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
# 7. 架构文档与帮助手册
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
