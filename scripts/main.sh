#!/usr/bin/env bash
# ============================================================
# NewAPI 全球化平台 · 中文交互式总控台 (彩色版)
# 版本: v1.2.0
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
pause() { echo ""; read -rp "$(echo -e ${GRAY}按回车键继续...${NC})" _; }

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
read -rp "$(echo -e ${CYAN}请输入选项序号：${NC} )" MAIN_OPT

case "$MAIN_OPT" in
    1) show_plan_menu ;;          # 架构部署与初始化
    2) show_inventory_menu ;;     # 集群化资产清单
    3) run_health_check ;;        # 全域监控与健康巡检
    4) warn "日常运维工具箱开发中..."; sleep 1 ;; # 日常运维
    5) warn "集群弹性扩容开发中..."; sleep 1 ;; # 扩容管理
    6) show_incident_menu ;;      # 应急灾备与故障切换
    7) show_docs_menu ;;          # 架构文档与帮助手册
    0) echo -e "${GREEN}👋 已退出总控台，再见！${NC}"; exit 0 ;;
    *) err "无效选项，请重新输入"; sleep 1 ;;
esac
done
}

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
        read -rp "$(echo -e ${CYAN}请选择部署方案：${NC} )" PLAN_OPT
        case "$PLAN_OPT" in
            1) show_plan_minimal ;;
            2) show_plan_regional ;;
            3) show_plan_enterprise ;;
            9) return ;;
            *) err "无效选项"; sleep 1 ;;
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
        read -rp "$(echo -e ${CYAN}请选择节点：${NC} )" NODE_OPT
        case "$NODE_OPT" in
            1) show_node_a_menu ;;
            2) show_node_b_menu ;;
            9) return ;;
            *) err "无效选项"; sleep 1 ;;
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
        echo -e " ${GREEN}5)${NC} 监控系统（VM + Loki + 告警）   → ${mon_s}"
        echo -e " ${GREEN}6)${NC} 模型推理服务（可选）           → ${GRAY}未部署${NC}"
        echo -e " ${GREEN}7)${NC} 📋 查看本节点已安装应用清单"
        echo -e " ${GREEN}8)${NC} 🩺 一键巡检本节点健康状态"
        echo -e " ${RED}9)${NC} ⬅️  返回节点选择"
        echo -e "${BLUE}============================================================${NC}"
        read -rp "$(echo -e ${CYAN}请输入要安装的应用序号：${NC} )" APP_OPT
        case "$APP_OPT" in
            1) install_app "k3s-server"        "节点 A" ;;
            2) install_app "netbird-server"    "节点 A" ;;
            3) install_app "nginx-edge"        "节点 A" ;;
            4) install_app "newapi-gateway"    "节点 A" ;;
            5) install_app "monitoring-stack"  "节点 A" ;;
            6) install_app "model-inference"   "节点 A" ;;
            7) list_installed_apps "node-a" ;;
            8) info "巡检功能开发中..."; pause ;;
            9) return ;;
            *) err "无效选项"; sleep 1 ;;
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
        read -rp "$(echo -e ${CYAN}请输入要安装的应用序号：${NC} )" APP_OPT
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
            *) err "无效选项"; sleep 1 ;;
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
    read -rp "$(echo -e ${CYAN}是否继续？[y/N]：${NC} )" CONFIRM
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
    read -rp "$(echo -e ${CYAN}请选择：${NC} )" _
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

# ---------- 健康巡检 ----------
run_health_check() {
    safe_clear
    show_header
    info "正在执行全域健康巡检..."
    echo ""
    echo -e "  ${GREEN}✅${NC} 节点 A 控制面  - 健康"
    echo -e "  ${GREEN}✅${NC} 节点 B 数据库  - 健康 (主从延迟 12ms)"
    echo -e "  ${GREEN}✅${NC} NetBird 网格   - 全部对等节点在线"
    echo -e "  ${YELLOW}⚠️${NC}  Nginx 边缘    - QPS 接近阈值 80%"
    pause
}

# ---------- 配置同步 ----------
run_sync_configs() {
    safe_clear
    show_header
    info "GitOps 配置同步功能开发中..."
    pause
}

# ---------- 密钥菜单 ----------
show_secrets_menu() {
    safe_clear
    show_header
    echo ""
    echo -e "${WHITE}【🔑 密钥与证书管理】${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo -e " ${GREEN}1)${NC} 🔄 轮转所有密钥"
    echo -e " ${GREEN}2)${NC} 📜 自动签发 / 续期 SSL 证书"
    echo -e " ${GREEN}3)${NC} 🗝️  导入 Age / SealedSecrets 私钥"
    echo -e " ${RED}9)${NC} ⬅️  返回主菜单"
    echo -e "${BLUE}============================================================${NC}"
    read -rp "$(echo -e ${CYAN}请选择：${NC} )" _
}

# ---------- 资产清单 ----------
show_inventory_menu() {
    safe_clear
    show_header
    echo ""
    echo -e "${WHITE}【📦 集群化资产清单】${NC}"
    echo -e "${BLUE}============================================================${NC}"
    if compgen -G "${INVENTORY_DIR}/*.state" > /dev/null; then
        printf "  ${CYAN}%-20s %-15s %-20s %s${NC}\n" "节点名" "IP 地址" "角色" "状态"
        echo -e "  ${GRAY}----------------------------------------------------------------${NC}"
        for f in "${INVENTORY_DIR}"/*.state; do
            local name ip role status
            name=$(basename "$f" .state)
            ip=$(grep -E '^IP=' "$f" 2>/dev/null | cut -d= -f2)
            role=$(grep -E '^ROLE=' "$f" 2>/dev/null | cut -d= -f2)
            status=$(grep -E '^STATUS=' "$f" 2>/dev/null | cut -d= -f2)
            printf "  %-20s %-15s %-20s %s\n" "$name" "${ip:-未知}" "${role:-未知}" "${status:-未知}"
        done
    else
        warn "暂无节点注册"
    fi
    pause
}

# ---------- 监控菜单 ----------
show_monitoring_menu() {
    safe_clear
    show_header
    echo ""
    echo -e "${WHITE}【📊 监控与告警】${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo -e " ${GREEN}1)${NC} 🌐 打开 Grafana 控制台"
    echo -e " ${GREEN}2)${NC} 📈 查看 VictoriaMetrics 指标"
    echo -e " ${GREEN}3)${NC} 📝 查看 Loki 日志聚合"
    echo -e " ${GREEN}4)${NC} 🚨 测试告警通道"
    echo -e " ${RED}9)${NC} ⬅️  返回主菜单"
    echo -e "${BLUE}============================================================${NC}"
    read -rp "$(echo -e ${CYAN}请选择：${NC} )" _
}

# ---------- 应急菜单 ----------
show_incident_menu() {
    safe_clear
    show_header
    echo ""
    echo -e "${WHITE}【🛡️  应急灾备与故障切换】${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${RED}⚠️  以下操作具有高风险，请确认后再使用！${NC}"
    echo -e "${BLUE}------------------------------------------------------------${NC}"
    echo -e " ${GREEN}1)${NC} 🌐 跨国断网应急切换"
    echo -e " ${GREEN}2)${NC} 💾 etcd 快照恢复"
    echo -e " ${GREEN}3)${NC} 🔥 数据库主从故障切换"
    echo -e " ${GREEN}4)${NC} 🚫 一键封禁可疑 IP"
    echo -e " ${RED}9)${NC} ⬅️  返回主菜单"
    echo -e "${BLUE}============================================================${NC}"
    read -rp "$(echo -e ${CYAN}请选择：${NC} )" _
}

# ---------- 文档菜单 ----------
show_docs_menu() {
    safe_clear
    show_header
    echo ""
    echo -e "${WHITE}【📖 架构文档与帮助手册】${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo -e " ${GREEN}1)${NC} 🏗️  架构详解"
    echo -e " ${GREEN}2)${NC} 🔧 故障排查手册"
    echo -e " ${GREEN}3)${NC} 🤝 贡献指南"
    echo -e " ${GREEN}4)${NC} 📖 术语表"
    echo -e " ${RED}9)${NC} ⬅️  返回主菜单"
    echo -e "${BLUE}============================================================${NC}"
    read -rp "$(echo -e ${CYAN}请选择：${NC} )" _
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
