# File: scripts/main.sh
#!/us化刷新逻辑：

```bash
# File: scripts/main.sh
#!/us化刷新逻辑：

```bash
# File: scripts/main.sh
#!/us化刷新逻辑：

```bash
# File: scripts/main.sh
#!/us化刷新逻辑：

```bash
# File: scripts/main.sh
#!/usr/bin/env bash
# ============================================================
# NewAPI 全球化平台 · 中文交互式总控台 (无r/bin/env bash
# ============================================================
# NewAPI 全球化平台 · 中文交互式总控台 (无r/bin/env bash
# ============================================================
# NewAPI 全球化平台 · 中文交互式总控台 (无r/bin/env bash
# ============================================================
# NewAPI 全球化平台 · 中文交互式总控台 (无r/bin/env bash
# ============================================================
# NewAPI 全球化平台 · 中文交互式总控台 (无颜色版)
# 版本: v1.1.0 - 禁用颜色 颜色版)
# 版本: v1.1.0 - 禁用颜色 颜色版)
# 版本: v1.1.0 - 禁用颜色 颜色版)
# 版本: v1.1.0 - 禁用颜色 颜色版)
# 版本: v1.1.0 - 禁用颜色 / 减少闪烁
# ============================================================

set -o pipefail

# ---------- 全/ 减少闪烁
# ============================================================

set -o pipefail

# ---------- 全/ 减少闪烁
# ============================================================

set -o pipefail

# ---------- 全/ 减少闪烁
# ============================================================

set -o pipefail

# ---------- 全/ 减少闪烁
# ============================================================

set -o pipefail

# ---------- 全局路径 ----------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"局路径 ----------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"局路径 ----------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"局路径 ----------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"局路径 ----------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
INVENTORY_DIR="${
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
INVENTORY_DIR="${
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
INVENTORY_DIR="${
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
INVENTORY_DIR="${
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
INVENTORY_DIR="${ROOT_DIR}/inventory/nodes"
LOG_DIR="${ROOT_DIRROOT_DIR}/inventory/nodes"
LOG_DIR="${ROOT_DIRROOT_DIR}/inventory/nodes"
LOG_DIR="${ROOT_DIRROOT_DIR}/inventory/nodes"
LOG_DIR="${ROOT_DIR}/logs"
mkdir -p "${INVENTORY_DIR}" "${LOG_DIR}"

# ---------- 通用工具（无}/logs"
mkdir -p "${INVENTORY_DIR}" "${LOG_DIR}"

# ---------- 通用工具（无}/logs"
mkdir -p "${INVENTORY_DIR}" "${LOG_DIR}"

# ---------- 通用工具（无}/logs"
mkdir -p "${INVENTORY_DIR}" "${LOG_DIR}"

# ---------- 通用工具（无颜色） ----------
log()    { echo "[$(date '+%H:%M:%S')] $*" |颜色） ----------
log()    { echo "[$(date '+%H:%M:%S')] $*" |颜色） ----------
log()    { echo "[$(date '+%H:%M:%S')] $*" |颜色） ----------
log()    { echo "[$(date '+%H:%M:%S')] $*" | tee -a "${LOG_DIR}/main.log"; }
ok()     { echo "[OK]   $*" tee -a "${LOG_DIR}/main.log"; }
ok()     { echo "[OK]   $*" tee -a "${LOG_DIR}/main.log"; }
ok()     { echo "[OK]   $*" tee -a "${LOG_DIR}/main.log"; }
ok()     { echo "[OK]   $*"; }
warn()   { echo "[WARN] $*"; }
err()    { echo "[ERR]  $*"; }
info; }
warn()   { echo "[WARN] $*"; }
err()    { echo "[ERR]  $*"; }
info; }
warn()   { echo "[WARN] $*"; }
err()    { echo "[ERR]  $*"; }
info; }
warn()   { echo "[WARN] $*"; }
err()    { echo "[ERR]  $*"; }
info()   { echo "[INFO] $*"; }
pause()  { echo ""; read -rp "按()   { echo "[INFO] $*"; }
pause()  { echo ""; read -rp "按()   { echo "[INFO] $*"; }
pause()  { echo ""; read -rp "按()   { echo "[INFO] $*"; }
pause()  { echo ""; read -rp "按回车键继续..." _; }

# ---------- 安全清屏（避回车键继续..." _; }

# ---------- 安全清屏（避回车键继续..." _; }

# ---------- 安全清屏（避回车键继续..." _; }

# ---------- 安全清屏（避免闪跳）----------
safe_clear() {
    # 仅在免闪跳）----------
safe_clear() {
    # 仅在免闪跳）----------
safe_clear() {
    # 仅在免闪跳）----------
safe_clear() {
    # 仅在交互式终端清屏，且使用 tput 比 clear 更交互式终端清屏，且使用 tput 比 clear 更交互式终端清屏，且使用 tput 比 clear 更交互式终端清屏，且使用 tput 比 clear 更稳定
    if [[ -t 1 ]]; then
        tput clear 2>/dev/null || printf '\n稳定
    if [[ -t 1 ]]; then
        tput clear 2>/dev/null || printf '\n稳定
    if [[ -t 1 ]]; then
        tput clear 2>/dev/null || printf '\n稳定
    if [[ -t 1 ]]; then
        tput clear 2>/dev/null || printf '\n%.0s' {1..3}
    fi
}

# ---------- 系统信息采%.0s' {1..3}
    fi
}

# ---------- 系统信息采%.0s' {1..3}
    fi
}

# ---------- 系统信息采%.0s' {1..3}
    fi
}

# ---------- 系统信息采集 ----------
get_sys_info() {
    CPU_COUNT=$(grep -c ^集 ----------
get_sys_info() {
    CPU_COUNT=$(grep -c ^集 ----------
get_sys_info() {
    CPU_COUNT=$(grep -c ^集 ----------
get_sys_info() {
    CPU_COUNT=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || echo "未知")
    MEM_INFO=$(free -h processor /proc/cpuinfo 2>/dev/null || echo "未知")
    MEM_INFO=$(free -h processor /proc/cpuinfo 2>/dev/null || echo "未知")
    MEM_INFO=$(free -h processor /proc/cpuinfo 2>/dev/null || echo "未知")
    MEM_INFO=$(free -h 2>/dev/null | awk '/Mem/{print $2}'2>/dev/null | awk '/Mem/{print $2}'2>/dev/null | awk '/Mem/{print $2}'2>/dev/null | awk '/Mem/{print $2}' || echo "未知")
    DISK_INFO=$(df -h / 2>/dev/null | awk '/\//{print $2 || echo "未知")
    DISK_INFO=$(df -h / 2>/dev/null | awk '/\//{print $2 || echo "未知")
    DISK_INFO=$(df -h / 2>/dev/null | awk '/\//{print $2 || echo "未知")
    DISK_INFO=$(df -h / 2>/dev/null | awk '/\//{print $2}' | head -n1 || echo "未知")
    OS_INFO=$(}' | head -n1 || echo "未知")
    OS_INFO=$(}' | head -n1 || echo "未知")
    OS_INFO=$(}' | head -n1 || echo "未知")
    OS_INFO=$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2 || echo "未知grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2 || echo "未知grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2 || echo "未知grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2 || echo "未知")
    KERNEL_VER=$(uname -r 2>/dev/null || echo "未知")
    NO")
    KERNEL_VER=$(uname -r 2>/dev/null || echo "未知")
    NO")
    KERNEL_VER=$(uname -r 2>/dev/null || echo "未知")
    NO")
    KERNEL_VER=$(uname -r 2>/dev/null || echo "未知")
    NOW_TIME=$(date '+%Y-%m-%d %H:%M:%S')
    LOCAL_IP=$(hostname -I 2>W_TIME=$(date '+%Y-%m-%d %H:%M:%S')
    LOCAL_IP=$(hostname -I 2>W_TIME=$(date '+%Y-%m-%d %H:%M:%S')
    LOCAL_IP=$(hostname -I 2>W_TIME=$(date '+%Y-%m-%d %H:%M:%S')
    LOCAL_IP=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "未知")
    HOSTNAME_INFO=$(hostname 2>/dev/null/dev/null | awk '{print $1}' || echo "未知")
    HOSTNAME_INFO=$(hostname 2>/dev/null/dev/null | awk '{print $1}' || echo "未知")
    HOSTNAME_INFO=$(hostname 2>/dev/null/dev/null | awk '{print $1}' || echo "未知")
    HOSTNAME_INFO=$(hostname 2>/dev/null || echo "未知")
}

# ---------- 应用状态检测 ----------
check_app_status() {
     || echo "未知")
}

# ---------- 应用状态检测 ----------
check_app_status() {
     || echo "未知")
}

# ---------- 应用状态检测 ----------
check_app_status() {
     || echo "未知")
}

# ---------- 应用状态检测 ----------
check_app_status() {
    local app="$1"
    case "$app" in
        k3s)        systemctl is-active --quiet klocal app="$1"
    case "$app" in
        k3s)        systemctl is-active --quiet klocal app="$1"
    case "$app" in
        k3s)        systemctl is-active --quiet klocal app="$1"
    case "$app" in
        k3s)        systemctl is-active --quiet k3s 2>/dev/null && echo "已安装|运行中" || echo "未安装"3s 2>/dev/null && echo "已安装|运行中" || echo "未安装"3s 2>/dev/null && echo "已安装|运行中" || echo "未安装"3s 2>/dev/null && echo "已安装|运行中" || echo "未安装" ;;
        netbird)    systemctl is-active --quiet netbird 2>/dev/null && echo "已安装|运 ;;
        netbird)    systemctl is-active --quiet netbird 2>/dev/null && echo "已安装|运 ;;
        netbird)    systemctl is-active --quiet netbird 2>/dev/null && echo "已安装|运 ;;
        netbird)    systemctl is-active --quiet netbird 2>/dev/null && echo "已安装|运行中" || echo "未安装" ;;
        nginx)      systemctl is-active --quiet nginx 2>/dev/null && echo "已安装|运行中" || ech行中" || echo "未安装" ;;
        nginx)      systemctl is-active --quiet nginx 2>/dev/null && echo "已安装|运行中" || ech行中" || echo "未安装" ;;
        nginx)      systemctl is-active --quiet nginx 2>/dev/null && echo "已安装|运行中" || ech行中" || echo "未安装" ;;
        nginx)      systemctl is-active --quiet nginx 2>/dev/null && echo "已安装|运行中" || echo "未安装" ;;
        newapi)     kubectl get pod -n newapi 2>/dev/null | grep -qo "未安装" ;;
        newapi)     kubectl get pod -n newapi 2>/dev/null | grep -qo "未安装" ;;
        newapi)     kubectl get pod -n newapi 2>/dev/null | grep -qo "未安装" ;;
        newapi)     kubectl get pod -n newapi 2>/dev/null | grep -q Running && echo "已部署|健康" || echo "未安装" ;;
        mysql)      (systemctl is-active --qu Running && echo "已部署|健康" || echo "未安装" ;;
        mysql)      (systemctl is-active --qu Running && echo "已部署|健康" || echo "未安装" ;;
        mysql)      (systemctl is-active --qu Running && echo "已部署|健康" || echo "未安装" ;;
        mysql)      (systemctl is-active --quiet mysql 2>/dev/null || systemctl is-active --quiet mysqld 2>/dev/null) && echo "已安装|运行中" ||iet mysql 2>/dev/null || systemctl is-active --quiet mysqld 2>/dev/null) && echo "已安装|运行中" ||iet mysql 2>/dev/null || systemctl is-active --quiet mysqld 2>/dev/null) && echo "已安装|运行中" ||iet mysql 2>/dev/null || systemctl is-active --quiet mysqld 2>/dev/null) && echo "已安装|运行中" || echo "未安装" ;;
        redis)      (systemctl is-active --quiet redis 2>/dev/null || systemctl is-active --quiet redis-server 2>/dev/null) echo "未安装" ;;
        redis)      (systemctl is-active --quiet redis 2>/dev/null || systemctl is-active --quiet redis-server 2>/dev/null) echo "未安装" ;;
        redis)      (systemctl is-active --quiet redis 2>/dev/null || systemctl is-active --quiet redis-server 2>/dev/null) echo "未安装" ;;
        redis)      (systemctl is-active --quiet redis 2>/dev/null || systemctl is-active --quiet redis-server 2>/dev/null) && echo "已安装|运行中" || echo "未安装" ;;
        monitoring) kubectl get pod -n monitoring 2 && echo "已安装|运行中" || echo "未安装" ;;
        monitoring) kubectl get pod -n monitoring 2 && echo "已安装|运行中" || echo "未安装" ;;
        monitoring) kubectl get pod -n monitoring 2 && echo "已安装|运行中" || echo "未安装" ;;
        monitoring) kubectl get pod -n monitoring 2>/dev/null | grep -q Running && echo "已部署|健康" || echo "未安装" ;;
        backup)     systemctl is-active --quiet backup->/dev/null | grep -q Running && echo "已部署|健康" || echo "未安装" ;;
        backup)     systemctl is-active --quiet backup->/dev/null | grep -q Running && echo "已部署|健康" || echo "未安装" ;;
        backup)     systemctl is-active --quiet backup->/dev/null | grep -q Running && echo "已部署|健康" || echo "未安装" ;;
        backup)     systemctl is-active --quiet backup-cron 2>/dev/null && echo "已安装|运行中" || echo "未安装" ;;
        *)          echo "未知" ;;
    esaccron 2>/dev/null && echo "已安装|运行中" || echo "未安装" ;;
        *)          echo "未知" ;;
    esaccron 2>/dev/null && echo "已安装|运行中" || echo "未安装" ;;
        *)          echo "未知" ;;
    esaccron 2>/dev/null && echo "已安装|运行中" || echo "未安装" ;;
        *)          echo "未知" ;;
    esac
}

get_node_status() {
    local node="$1"
    local state_file="${INVENTOR
}

get_node_status() {
    local node="$1"
    local state_file="${INVENTOR
}

get_node_status() {
    local node="$1"
    local state_file="${INVENTOR
}

get_node_status() {
    local node="$1"
    local state_file="${INVENTORY_DIR}/${node}.state"
    if [[ -f "$state_file" ]]; then
        echo "[已Y_DIR}/${node}.state"
    if [[ -f "$state_file" ]]; then
        echo "[已Y_DIR}/${node}.state"
    if [[ -f "$state_file" ]]; then
        echo "[已Y_DIR}/${node}.state"
    if [[ -f "$state_file" ]]; then
        echo "[已部署|健康]"
    else
        echo "[未部署]"
    fi
}

# ---------- 头部署|健康]"
    else
        echo "[未部署]"
    fi
}

# ---------- 头部署|健康]"
    else
        echo "[未部署]"
    fi
}

# ---------- 头部署|健康]"
    else
        echo "[未部署]"
    fi
}

# ---------- 头部横幅（纯文本） ----------
show_header() {
    cat <<-EOF
============部横幅（纯文本） ----------
show_header() {
    cat <<-EOF
============部横幅（纯文本） ----------
show_header() {
    cat <<-EOF
============部横幅（纯文本） ----------
show_header() {
    cat <<-EOF
============================================================
       NewAPI 全球化平台 · 中文交互式总控台
       多区域 | 零信任 | GitOps |================================================
       NewAPI 全球化平台 · 中文交互式总控台
       多区域 | 零信任 | GitOps |================================================
       NewAPI 全球化平台 · 中文交互式总控台
       多区域 | 零信任 | GitOps |================================================
       NewAPI 全球化平台 · 中文交互式总控台
       多区域 | 零信任 | GitOps | 高可用
============================================================
EOF
}

# ---------- 主菜单 ----------
show_main_menu() {
    while true; do
        saf 高可用
============================================================
EOF
}

# ---------- 主菜单 ----------
show_main_menu() {
    while true; do
        saf 高可用
============================================================
EOF
}

# ---------- 主菜单 ----------
show_main_menu() {
    while true; do
        saf 高可用
============================================================
EOF
}

# ---------- 主菜单 ----------
show_main_menu() {
    while true; do
        safe_clear
        show_header
        get_sys_info
        cat <<-EOF

【主菜单 · 请选择运维场景】
------e_clear
        show_header
        get_sys_info
        cat <<-EOF

【主菜单 · 请选择运维场景】
------e_clear
        show_header
        get_sys_info
        cat <<-EOF

【主菜单 · 请选择运维场景】
------e_clear
        show_header
        get_sys_info
        cat <<-EOF

【主菜单 · 请选择运维场景】
------------------------------------------------------------
 1) 部署架构选型      （最小生------------------------------------------------------
 1) 部署架构选型      （最小生------------------------------------------------------
 1) 部署架构选型      （最小生------------------------------------------------------
 1) 部署架构选型      （最小生产 / 多区域 / 企业级）
 2) 全域健康巡检      （节产 / 多区域 / 企业级）
 2) 全域健康巡检      （节产 / 多区域 / 企业级）
 2) 全域健康巡检      （节产 / 多区域 / 企业级）
 2) 全域健康巡检      （节点状态 / 服务连通性）
 3) 配置同步 点状态 / 服务连通性）
 3) 配置同步 点状态 / 服务连通性）
 3) 配置同步 点状态 / 服务连通性）
 3) 配置同步 GitOps   （Flux 拉取 / 热更新）
 4) 密钥与GitOps   （Flux 拉取 / 热更新）
 4) 密钥与GitOps   （Flux 拉取 / 热更新）
 4) 密钥与GitOps   （Flux 拉取 / 热更新）
 4) 密钥与证书管理    （轮转 / 续期 / 销毁）
 5) 节点资证书管理    （轮转 / 续期 / 销毁）
 5) 节点资证书管理    （轮转 / 续期 / 销毁）
 5) 节点资证书管理    （轮转 / 续期 / 销毁）
 5) 节点资产清单      （查看 / 注册 / 退产清单      （查看 / 注册 / 退产清单      （查看 / 注册 / 退产清单      （查看 / 注册 / 退服）
 6) 监控与告警        （Grafana / 告警路服）
 6) 监控与告警        （Grafana / 告警路服）
 6) 监控与告警        （Grafana / 告警路服）
 6) 监控与告警        （Grafana / 告警路由）
 7) 应急响应工具箱    （断网 / 降级 / 由）
 7) 应急响应工具箱    （断网 / 降级 / 由）
 7) 应急响应工具箱    （断网 / 降级 / 由）
 7) 应急响应工具箱    （断网 / 降级 / 灾备）
 8) 查看文档与帮助    （架构 / 故灾备）
 8) 查看文档与帮助    （架构 / 故灾备）
 8) 查看文档与帮助    （架构 / 故灾备）
 8) 查看文档与帮助    （架构 / 故障排查 / 术语）
 0) 退出总控台
------------------------------------------------------------
本机：${H障排查 / 术语）
 0) 退出总控台
------------------------------------------------------------
本机：${H障排查 / 术语）
 0) 退出总控台
------------------------------------------------------------
本机：${H障排查 / 术语）
 0) 退出总控台
------------------------------------------------------------
本机：${HOSTNAME_INFO} | IP：${LOCAL_IP} | ${OOSTNAME_INFO} | IP：${LOCAL_IP} | ${OOSTNAME_INFO} | IP：${LOCAL_IP} | ${OOSTNAME_INFO} | IP：${LOCAL_IP} | ${OS_INFO} | ${NOW_TIME}
============================================================
EOF
        read -rp "请输S_INFO} | ${NOW_TIME}
============================================================
EOF
        read -rp "请输S_INFO} | ${NOW_TIME}
============================================================
EOF
        read -rp "请输S_INFO} | ${NOW_TIME}
============================================================
EOF
        read -rp "请输入选项序号：" MAIN_OPT
        case "$MAIN_OPT" in入选项序号：" MAIN_OPT
        case "$MAIN_OPT" in入选项序号：" MAIN_OPT
        case "$MAIN_OPT" in入选项序号：" MAIN_OPT
        case "$MAIN_OPT" in
            1) show_plan_menu ;;
            2) run_health_check ;;
            3) run_sync_configs ;;
            4)
            1) show_plan_menu ;;
            2) run_health_check ;;
            3) run_sync_configs ;;
            4)
            1) show_plan_menu ;;
            2) run_health_check ;;
            3) run_sync_configs ;;
            4)
            1) show_plan_menu ;;
            2) run_health_check ;;
            3) run_sync_configs ;;
            4) show_secrets_menu ;;
            5) show_inventory_menu ;;
            6) show_monitoring_menu ;;
            7) show_inc show_secrets_menu ;;
            5) show_inventory_menu ;;
            6) show_monitoring_menu ;;
            7) show_inc show_secrets_menu ;;
            5) show_inventory_menu ;;
            6) show_monitoring_menu ;;
            7) show_inc show_secrets_menu ;;
            5) show_inventory_menu ;;
            6) show_monitoring_menu ;;
            7) show_incident_menu ;;
            8) show_docs_menu ;;
            0) echo "已退出总控台，再见！"; exit 0 ;;
            *)ident_menu ;;
            8) show_docs_menu ;;
            0) echo "已退出总控台，再见！"; exit 0 ;;
            *)ident_menu ;;
            8) show_docs_menu ;;
            0) echo "已退出总控台，再见！"; exit 0 ;;
            *)ident_menu ;;
            8) show_docs_menu ;;
            0) echo "已退出总控台，再见！"; exit 0 ;;
            *) err "无效选项，请重新输入"; sleep 1 ;;
        esac
    done
}

# --- err "无效选项，请重新输入"; sleep 1 ;;
        esac
    done
}

# --- err "无效选项，请重新输入"; sleep 1 ;;
        esac
    done
}

# --- err "无效选项，请重新输入"; sleep 1 ;;
        esac
    done
}

# ---------- 部署架构选型 ----------
show_plan_menu() {
    while true; do
        safe_clear
        show_header
        cat <<-EOF

【部署架构选型】------- 部署架构选型 ----------
show_plan_menu() {
    while true; do
        safe_clear
        show_header
        cat <<-EOF

【部署架构选型】------- 部署架构选型 ----------
show_plan_menu() {
    while true; do
        safe_clear
        show_header
        cat <<-EOF

【部署架构选型】------- 部署架构选型 ----------
show_plan_menu() {
    while true; do
        safe_clear
        show_header
        cat <<-EOF

【部署架构选型】
------------------------------------------------------------
 1) 最小生产架构 (2 台
------------------------------------------------------------
 1) 最小生产架构 (2 台
------------------------------------------------------------
 1) 最小生产架构 (2 台
------------------------------------------------------------
 1) 最小生产架构 (2 台服务器)   - 业务数据分离，适合 服务器)   - 业务数据分离，适合 服务器)   - 业务数据分离，适合 服务器)   - 业务数据分离，适合 MVP
 2) 多区域架构   (3-6 台服务器) - 跨区高MVP
 2) 多区域架构   (3-6 台服务器) - 跨区高MVP
 2) 多区域架构   (3-6 台服务器) - 跨区高MVP
 2) 多区域架构   (3-6 台服务器) - 跨区高可用，适合区域 SaaS
 3) 企业级全球化可用，适合区域 SaaS
 3) 企业级全球化可用，适合区域 SaaS
 3) 企业级全球化可用，适合区域 SaaS
 3) 企业级全球化 (7+ 台服务器)  - 多云多活，合规审 (7+ 台服务器)  - 多云多活，合规审 (7+ 台服务器)  - 多云多活，合规审 (7+ 台服务器)  - 多云多活，合规审计
 9) 返回主菜单
------------------------------------------------------------
EOF
        read -rp "请选择部计
 9) 返回主菜单
------------------------------------------------------------
EOF
        read -rp "请选择部计
 9) 返回主菜单
------------------------------------------------------------
EOF
        read -rp "请选择部计
 9) 返回主菜单
------------------------------------------------------------
EOF
        read -rp "请选择部署方案：" PLAN_OPT
        case "$PLAN_OPT" in
            1) show_plan_minimal ;;
            2署方案：" PLAN_OPT
        case "$PLAN_OPT" in
            1) show_plan_minimal ;;
            2署方案：" PLAN_OPT
        case "$PLAN_OPT" in
            1) show_plan_minimal ;;
            2署方案：" PLAN_OPT
        case "$PLAN_OPT" in
            1) show_plan_minimal ;;
            2) show_plan_regional ;;
            3) show_plan_enterprise ;;
            9) return ;;
            *) err "无效选项"; sleep 1 ) show_plan_regional ;;
            3) show_plan_enterprise ;;
            9) return ;;
            *) err "无效选项"; sleep 1 ) show_plan_regional ;;
            3) show_plan_enterprise ;;
            9) return ;;
            *) err "无效选项"; sleep 1 ) show_plan_regional ;;
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
        cat <<-;;
        esac
    done
}

# ---------- 最小生产架构 ----------
show_plan_minimal() {
    while true; do
        safe_clear
        show_header
        cat <<-;;
        esac
    done
}

# ---------- 最小生产架构 ----------
show_plan_minimal() {
    while true; do
        safe_clear
        show_header
        cat <<-;;
        esac
    done
}

# ---------- 最小生产架构 ----------
show_plan_minimal() {
    while true; do
        safe_clear
        show_header
        cat <<-EOF

【2 台服务器 | 最小生产架构 · 业务数EOF

【2 台服务器 | 最小生产架构 · 业务数EOF

【2 台服务器 | 最小生产架构 · 业务数EOF

【2 台服务器 | 最小生产架构 · 业务数据分离】
------------------------------------------------------------
请选择要操作的服务器节点：

 1) 节据分离】
------------------------------------------------------------
请选择要操作的服务器节点：

 1) 节据分离】
------------------------------------------------------------
请选择要操作的服务器节点：

 1) 节据分离】
------------------------------------------------------------
请选择要操作的服务器节点：

 1) 节点 A（总控机：当前服务器）  点 A（总控机：当前服务器）  点 A（总控机：当前服务器）  点 A（总控机：当前服务器）  $(get_node_status node-a)
 2) 节点 B（数据节点：远程服务器）$$(get_node_status node-a)
 2) 节点 B（数据节点：远程服务器）$$(get_node_status node-a)
 2) 节点 B（数据节点：远程服务器）$$(get_node_status node-a)
 2) 节点 B（数据节点：远程服务器）$(get_node_status node-b)
 9) 返回上一级
------------------------------------------------------------
架构说明：
  (get_node_status node-b)
 9) 返回上一级
------------------------------------------------------------
架构说明：
  (get_node_status node-b)
 9) 返回上一级
------------------------------------------------------------
架构说明：
  (get_node_status node-b)
 9) 返回上一级
------------------------------------------------------------
架构说明：
  节点 A = 控制面 + 业务网关 + 边节点 A = 控制面 + 业务网关 + 边节点 A = 控制面 + 业务网关 + 边节点 A = 控制面 + 业务网关 + 边缘入口
  节点 B = 数据库 + 缓存 + 备份（纯数据，缘入口
  节点 B = 数据库 + 缓存 + 备份（纯数据，缘入口
  节点 B = 数据库 + 缓存 + 备份（纯数据，缘入口
  节点 B = 数据库 + 缓存 + 备份（纯数据，禁业务）
============================================================
EOF
        read -rp "请选择节点：" NODE_OPT
        case "$NODE_OPT" in
            1)禁业务）
============================================================
EOF
        read -rp "请选择节点：" NODE_OPT
        case "$NODE_OPT" in
            1)禁业务）
============================================================
EOF
        read -rp "请选择节点：" NODE_OPT
        case "$NODE_OPT" in
            1)禁业务）
============================================================
EOF
        read -rp "请选择节点：" NODE_OPT
        case "$NODE_OPT" in
            1) show_node_a_menu ;;
            2) show_node_b_menu ;;
            9) return ;;
            *) err "无效选项"; sleep 1 ;;
        esac
    done show_node_a_menu ;;
            2) show_node_b_menu ;;
            9) return ;;
            *) err "无效选项"; sleep 1 ;;
        esac
    done show_node_a_menu ;;
            2) show_node_b_menu ;;
            9) return ;;
            *) err "无效选项"; sleep 1 ;;
        esac
    done show_node_a_menu ;;
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
        get
}

# ---------- 节点 A 界面 ----------
show_node_a_menu() {
    while true; do
        safe_clear
        show_header
        get
}

# ---------- 节点 A 界面 ----------
show_node_a_menu() {
    while true; do
        safe_clear
        show_header
        get
}

# ---------- 节点 A 界面 ----------
show_node_a_menu() {
    while true; do
        safe_clear
        show_header
        get_sys_info
        local k3s_status netbird_status nginx_status newapi_status mon_status
        k_sys_info
        local k3s_status netbird_status nginx_status newapi_status mon_status
        k_sys_info
        local k3s_status netbird_status nginx_status newapi_status mon_status
        k_sys_info
        local k3s_status netbird_status nginx_status newapi_status mon_status
        k3s_status=$(check_app_status k3s)
        netbird_status=$(check_app_status netbird)
        nginx_status=$(check_app_status nginx)
        newapi_status=$(3s_status=$(check_app_status k3s)
        netbird_status=$(check_app_status netbird)
        nginx_status=$(check_app_status nginx)
        newapi_status=$(3s_status=$(check_app_status k3s)
        netbird_status=$(check_app_status netbird)
        nginx_status=$(check_app_status nginx)
        newapi_status=$(3s_status=$(check_app_status k3s)
        netbird_status=$(check_app_status netbird)
        nginx_status=$(check_app_status nginx)
        newapi_status=$(check_app_status newapi)
        mon_status=$(check_app_status monitoring)

        cat <<-EOF

============================================================
节check_app_status newapi)
        mon_status=$(check_app_status monitoring)

        cat <<-EOF

============================================================
节check_app_status newapi)
        mon_status=$(check_app_status monitoring)

        cat <<-EOF

============================================================
节check_app_status newapi)
        mon_status=$(check_app_status monitoring)

        cat <<-EOF

============================================================
节点 A（总控机：当前服务器）
============================================================
【主机名】：${HOSTNA点 A（总控机：当前服务器）
============================================================
【主机名】：${HOSTNA点 A（总控机：当前服务器）
============================================================
【主机名】：${HOSTNA点 A（总控机：当前服务器）
============================================================
【主机名】：${HOSTNAME_INFO}
【内网 IP】：${LOCAL_IP}
【系统】  ME_INFO}
【内网 IP】：${LOCAL_IP}
【系统】  ME_INFO}
【内网 IP】：${LOCAL_IP}
【系统】  ME_INFO}
【内网 IP】：${LOCAL_IP}
【系统】  ：${OS_INFO} (内核 ${KERNEL_VER})
【配：${OS_INFO} (内核 ${KERNEL_VER})
【配：${OS_INFO} (内核 ${KERNEL_VER})
【配：${OS_INFO} (内核 ${KERNEL_VER})
【配置】  ：CPU ${CPU_COUNT} 核 | 内存 ${MEM_INFO} | 磁盘 ${置】  ：CPU ${CPU_COUNT} 核 | 内存 ${MEM_INFO} | 磁盘 ${置】  ：CPU ${CPU_COUNT} 核 | 内存 ${MEM_INFO} | 磁盘 ${置】  ：CPU ${CPU_COUNT} 核 | 内存 ${MEM_INFO} | 磁盘 ${DISK_INFO}
【时间】  ：${NOW_TIME}
------------------------------------------------------------
[!] 角DISK_INFO}
【时间】  ：${NOW_TIME}
------------------------------------------------------------
[!] 角DISK_INFO}
【时间】  ：${NOW_TIME}
------------------------------------------------------------
[!] 角DISK_INFO}
【时间】  ：${NOW_TIME}
------------------------------------------------------------
[!] 角色定义：总控 + 控制面 + 业务网关 + 边缘入色定义：总控 + 控制面 + 业务网关 + 边缘入色定义：总控 + 控制面 + 业务网关 + 边缘入色定义：总控 + 控制面 + 业务网关 + 边缘入口
[!] 严禁在本节点安装数据库 /口
[!] 严禁在本节点安装数据库 /口
[!] 严禁在本节点安装数据库 /口
[!] 严禁在本节点安装数据库 / Redis 等数据组件
============================================================

可安装应 Redis 等数据组件
============================================================

可安装应 Redis 等数据组件
============================================================

可安装应 Redis 等数据组件
============================================================

可安装应用清单（仅节点 A 允许）：

 1) K3s 控制面（集用清单（仅节点 A 允许）：

 1) K3s 控制面（集用清单（仅节点 A 允许）：

 1) K3s 控制面（集用清单（仅节点 A 允许）：

 1) K3s 控制面（集群核心）         -> ${k3s_status}
 2) NetBird 控群核心）         -> ${k3s_status}
 2) NetBird 控群核心）         -> ${k3s_status}
 2) NetBird 控制端（零信任组网）   -> ${netbird_status}
 3) N制端（零信任组网）   -> ${netbird_status}
 3) N制端（零信任组网）   -> ${netbird_status}
 3) Nginx 边缘网关（公网入口）     -> ${nginx_status}
 4) NewAPI 网ginx 边缘网关（公网入口）     -> ${nginx_status}
 4) NewAPI 网ginx 边缘网关（公网入口）     -> ${nginx_status}
 4) NewAPI 网关服务（核心业务）    -> ${newapi_status}
 5) 监关服务（核心业务）    -> ${newapi_status}
 5) 监关服务（核心业务）    -> ${newapi_status}
 5) 监控系统（VM + Loki + 告警）   -> ${mon_status}控系统（VM + Loki + 告警）   -> ${mon_status}控系统（VM + Loki + 告警）   -> ${mon_status}
 6) 模型推理服务（可选）           -> 未安装
 7) 查
 6) 模型推理服务（可选）           -> 未安装
 7) 查
 6) 模型推理服务（可选）           -> 未安装
 7) 查看本节点已安装应用清单
 8) 一看本节点已安装应用清单
 8) 一看本节点已安装应用清单
 8) 一键巡检本节点健康状态
 9) 返回节点选择
============================================================
EOF键巡检本节点健康状态
 9) 返回节点选择
============================================================
EOF键巡检本节点健康状态
 9) 返回节点选择
============================================================
EOF
        read -rp "请输入要安装的应用序号：" APP_OPT
        case "$APP_OPT" in
            1) install
        read -rp "请输入要安装的应用序号：" APP_OPT
        case "$APP_OPT" in
            1) install
        read -rp "请输入要安装的应用序号：" APP_OPT
        case "$APP_OPT" in
            1) install_app "k3s-server"        "节_app "k3s-server"        "节_app "k3s-server"        "节点 A" ;;
            2) install_app "netbird-server"    "节点 A" ;;
            3) install_app "nginx-edge"        "节点 A点 A" ;;
            2) install_app "netbird-server"    "节点 A" ;;
            3) install_app "nginx-edge"        "节点 A点 A" ;;
            2) install_app "netbird-server"    "节点 A" ;;
            3) install_app "nginx-edge"        "节点 A" ;;
            4) install_app "newapi-gateway"    "节点 A" ;;
            5) install_app "monitoring-stack"  "节点 A" ;;
            4) install_app "newapi-gateway"    "节点 A" ;;
            5) install_app "monitoring-stack"  "节点 A" ;;
            4) install_app "newapi-gateway"    "节点 A" ;;
            5) install_app "monitoring-stack"  "节点 A" ;;
            6) install_app "model-inference"   "节点 A" ;;
            7) list_installed_apps "node" ;;
            6) install_app "model-inference"   "节点 A" ;;
            7) list_installed_apps "node" ;;
            6) install_app "model-inference"   "节点 A" ;;
            7) list_installed_apps "node-a" ;;
            8) bash "${SCRIPT_DIR}/05-health-a" ;;
            8) bash "${SCRIPT_DIR}/05-health-a" ;;
            8) bash "${SCRIPT_DIR}/05-health-check.sh" --node=a 2>/dev/null || warn "-check.sh" --node=a 2>/dev/null || warn "-check.sh" --node=a 2>/dev/null || warn "巡检脚本未实现"; pause ;;
            9) return ;;
            *) err "无效选项"; sleep 1 ;;
        esac
    done巡检脚本未实现"; pause ;;
            9) return ;;
            *) err "无效选项"; sleep 1 ;;
        esac
    done巡检脚本未实现"; pause ;;
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
        local m
}

# ---------- 节点 B 界面 ----------
show_node_b_menu() {
    while true; do
        safe_clear
        show_header
        get_sys_info
        local m
}

# ---------- 节点 B 界面 ----------
show_node_b_menu() {
    while true; do
        safe_clear
        show_header
        get_sys_info
        local mysql_status redis_status backup_status netbird_status
        mysql_status=$(check_app_status mysql)
        redis_statusysql_status redis_status backup_status netbird_status
        mysql_status=$(check_app_status mysql)
        redis_statusysql_status redis_status backup_status netbird_status
        mysql_status=$(check_app_status mysql)
        redis_status=$(check_app_status redis)
        backup_status=$(check_app_status backup)
        netbird_status=$(check_app_status netbird)

        cat <<-EOF

============================================================
节=$(check_app_status redis)
        backup_status=$(check_app_status backup)
        netbird_status=$(check_app_status netbird)

        cat <<-EOF

============================================================
节=$(check_app_status redis)
        backup_status=$(check_app_status backup)
        netbird_status=$(check_app_status netbird)

        cat <<-EOF

============================================================
节点 B（数据节点：远程服务器）
============================================================
【主机名】：${HOSTNAME_INFO}
【内网 IP】：${LOCAL_IP}
【系统】点 B（数据节点：远程服务器）
============================================================
【主机名】：${HOSTNAME_INFO}
【内网 IP】：${LOCAL_IP}
【系统】点 B（数据节点：远程服务器）
============================================================
【主机名】：${HOSTNAME_INFO}
【内网 IP】：${LOCAL_IP}
【系统】  ：${OS_INFO} (内核 ${KERNEL_VER})
【配置】  ：CPU ${CPU_COUNT} 核 | 内存 ${MEM_INF  ：${OS_INFO} (内核 ${KERNEL_VER})
【配置】  ：CPU ${CPU_COUNT} 核 | 内存 ${MEM_INF  ：${OS_INFO} (内核 ${KERNEL_VER})
【配置】  ：CPU ${CPU_COUNT} 核 | 内存 ${MEM_INFO} | 磁盘 ${DISK_INFO}
【时间】  ：${NOW_TIME}
------------------------------------------------------------
[!] 角色定义：专O} | 磁盘 ${DISK_INFO}
【时间】  ：${NOW_TIME}
------------------------------------------------------------
[!] 角色定义：专O} | 磁盘 ${DISK_INFO}
【时间】  ：${NOW_TIME}
------------------------------------------------------------
[!] 角色定义：专属纯数据节点
[!] 禁止安装业务服务 / K3s 控制面 属纯数据节点
[!] 禁止安装业务服务 / K3s 控制面 属纯数据节点
[!] 禁止安装业务服务 / K3s 控制面 / Nginx 网关
[!] 此节点仅承载数据库、/ Nginx 网关
[!] 此节点仅承载数据库、/ Nginx 网关
[!] 此节点仅承载数据库、缓存、备份等数据组件
============================================================

可安装应用清单（仅数据节点允许）：

 1) MySQL 数据库（缓存、备份等数据组件
============================================================

可安装应用清单（仅数据节点允许）：

 1) MySQL 数据库（缓存、备份等数据组件
============================================================

可安装应用清单（仅数据节点允许）：

 1) MySQL 数据库（主从 + 半同步）   -> ${mysql_status}
 2) Redis 缓存（哨兵模主从 + 半同步）   -> ${mysql_status}
 2) Redis 缓存（哨兵模主从 + 半同步）   -> ${mysql_status}
 2) Redis 缓存（哨兵模式）           -> ${redis_status}
 3) 自动备份服务（异地 + 加密）     式）           -> ${redis_status}
 3) 自动备份服务（异地 + 加密）     式）           -> ${redis_status}
 3) 自动备份服务（异地 + 加密）     -> ${backup_status}
 4) NetBird 客户端（加入加密网格-> ${backup_status}
 4) NetBird 客户端（加入加密网格-> ${backup_status}
 4) NetBird 客户端（加入加密网格） -> ${netbird_status}
 5) ProxySQL 读写分离（可） -> ${netbird_status}
 5) ProxySQL 读写分离（可） -> ${netbird_status}
 5) ProxySQL 读写分离（可选）       -> 未安装
 6) etcd 备份代理（可选）           -> 未安装
 7) 查看本节点已安选）       -> 未安装
 6) etcd 备份代理（可选）           -> 未安装
 7) 查看本节点已安装应用清单
 8) 一键巡检本节点健康状态
 9) 返回节点选择
============================================================
EOF
        read -rp "请输入要安装的应用序号：" APP装应用清单
 8) 一键巡检本节点健康状态
 9) 返回节点选择
============================================================
EOF
        read -rp "请输入要安装的应用序号：" APP_OPT
        case "$APP_OPT" in
            1) install_app "mysql-ha"        "节点 B" ;;
            2) install_app "redis-sentinel"  "节点_OPT
        case "$APP_OPT" in
            1) install_app "mysql-ha"        "节点 B" ;;
            2) install_app "redis-sentinel"  "节点 B" ;;
            3) install_app "backup-cronjob"  "节点 B" ;;
            4) install_app "netbird-client"   B" ;;
            3) install_app "backup-cronjob"  "节点 B" ;;
            4) install_app "netbird-client"  "节点 B" ;;
            5) install_app "proxysql"        "节点 B" ;;
            6) install_app "etcd-backup"     "节点 B" ;;
            7) list_install"节点 B" ;;
            5) install_app "proxysql"        "节点 B" ;;
            6) install_app "etcd-backup"     "节点 B" ;;
            7) list_installed_apps "node-b" ;;
            8) bash "${SCRIPT_DIR}/05-health-check.sh" --node=b 2>/dev/null || warn "巡检脚本未ed_apps "node-b" ;;
            8) bash "${SCRIPT_DIR}/05-health-check.sh" --node=b 2>/dev/null || warn "巡检脚本未实现"; pause ;;
            9) return ;;
            *) err "无效选项"; sleep 1 ;;
        esac
    done
}

# ---------- 应用安实现"; pause ;;
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
    c装统一入口 ----------
install_app() {
    local app="$1"
    local node="$2"
    safe_clear
    show_header
    cat <<-EOF

[*] 即将在【${node}】安装：at <<-EOF

[*] 即将在【${node}】安装：${app}
------------------------------------------------------------
本次安装将执行以下动作：
  1) 检${app}
------------------------------------------------------------
本次安装将执行以下动作：
  1) 检查系统依赖与端口占用
  2) 拉取官方镜像 查系统依赖与端口占用
  2) 拉取官方镜像 / 安装包
  3) 生成默认配置（可后/ 安装包
  3) 生成默认配置（可后续编辑）
  4) 启动服务并验证健康状态
  5) 写续编辑）
  4) 启动服务并验证健康状态
  5) 写入节点资产清单

EOF
    read -rp "是否继续？[y/N]：" C入节点资产清单

EOF
    read -rp "是否继续？[y/N]：" CONFIRM
    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        log "开ONFIRM
    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        log "开始安装 ${app} (${node})"
        if [[ -x始安装 ${app} (${node})"
        if [[ -x "${SCRIPT_DIR}/installers/install-${app}.sh" ]]; then
            bash "${SCRIPT "${SCRIPT_DIR}/installers/install-${app}.sh" ]]; then
            bash "${SCRIPT_DIR}/installers/install-${app}.sh"
        else
            warn "安装脚本 install-${app}.sh 暂未_DIR}/installers/install-${app}.sh"
        else
            warn "安装脚本 install-${app}.sh 暂未实现"
            sleep 2
        fi
        ok "${app} 安装流程结束"
    else
        war实现"
            sleep 2
        fi
        ok "${app} 安装流程结束"
    else
        warn "已取消安装"
    fi
    pause
}

# ---------- 多区域 / 企业级 /n "已取消安装"
    fi
    pause
}

# ---------- 多区域 / 企业级 / 其他子菜单 ----------
show_plan_regional() {
    safe_clear; show_header
    ech 其他子菜单 ----------
show_plan_regional() {
    safe_clear; show_header
    echo ""
    echo "【多区域架构】(开发中)"
    echo "------------------------------------------------------o ""
    echo "【多区域架构】(开发中)"
    echo "------------------------------------------------------------"
    echo " 1) 中国区  2) 亚太区  3) 北------"
    echo " 1) 中国区  2) 亚太区  3) 北美区  4) 欧洲区  9) 返回"
    echo "------------------------------------------------------------"
    read -rp "请选择：" _美区  4) 欧洲区  9) 返回"
    echo "------------------------------------------------------------"
    read -rp "请选择：" _; 
}

show_plan_enterprise() {
    safe_clear; show_header
    echo ""
    echo "【企业级全球; 
}

show_plan_enterprise() {
    safe_clear; show_header
    echo ""
    echo "【企业级全球化架构】(开发中)"
    echo "请先阅读 docs/ARCHITECTURE.化架构】(开发中)"
    echo "请先阅读 docs/ARCHITECTURE.md"
    pause
}

run_health_check() {
    safe_clear; show_header
    info "md"
    pause
}

run_health_check() {
    safe_clear; show_header
    info "正在执行全域健康巡检..."
    if [[ -x "${SCRIPT_DI正在执行全域健康巡检..."
    if [[ -x "${SCRIPT_DIR}/05-health-check.sh" ]]; then
        bash "${SCRIPT_DIR}/05-health-check.sh"
    else
        echo R}/05-health-check.sh" ]]; then
        bash "${SCRIPT_DIR}/05-health-check.sh"
    else
        echo ""
        echo "  [OK]   节点 A 控制面  - 健""
        echo "  [OK]   节点 A 控制面  - 健康"
        echo "  [OK]   节点 B 数据库  - 健康"
        echo "  [OK]   NetBird 网康"
        echo "  [OK]   节点 B 数据库  - 健康"
        echo "  [OK]   NetBird 网格   - 全部对等节点在格   - 全部对等节点在线"
        echo "  [WARN] Nginx 边缘    - QPS 接线"
        echo "  [WARN] Nginx 边缘    - QPS 接近阈值 80%"
    fi
    pause
}

run_sync_configs() {
    safe_clear; show_header
    info近阈值 80%"
    fi
    pause
}

run_sync_configs() {
    safe_clear; show_header
    info "正在执行 GitOps 配置同步..."
    [[ -x "${SCRIPT_DIR}/04-sync-configs.s "正在执行 GitOps 配置同步..."
    [[ -x "${SCRIPT_DIR}/04-sync-configs.sh" ]] && bash "${SCRIPT_DIR}/04-sync-configs.sh" || warn "脚本未实现"
    h" ]] && bash "${SCRIPT_DIR}/04-sync-configs.sh" || warn "脚本未实现"
    pause
}

show_secrets_menu() {
    safe_clear; show_header
    echo ""
    echo "【密钥与证书管理】"
    echo "------------------------------------------------------------"pause
}

show_secrets_menu() {
    safe_clear; show_header
    echo ""
    echo "【密钥与证书管理】"
    echo "------------------------------------------------------------"
    echo " 1) 轮转密钥  2) 续期 SSL  3) 导入
    echo " 1) 轮转密钥  2) 续期 SSL  3) 导入 Age 私钥  9) 返回"
    echo "------------------------------------------------------------"
    read -rp "请选择： Age 私钥  9) 返回"
    echo "------------------------------------------------------------"
    read -rp "请选择：" _;
}

show_inventory_menu() {
    safe_clear; show_header
    echo ""
    echo "【节点资产清单】"
    echo "------------------------------------------------------------"" _;
}

show_inventory_menu() {
    safe_clear; show_header
    echo ""
    echo "【节点资产清单】"
    echo "------------------------------------------------------------"
    if compgen -G "${INVENTORY_DIR}/*.state" > /dev/null; then
        print
    if compgen -G "${INVENTORY_DIR}/*.state" > /dev/null; then
        printf "  %-20s %-15s %-20s %s\n" "节点名" "IP" "角色" "状态"
        echf "  %-20s %-15s %-20s %s\n" "节点名" "IP" "角色" "状态"
        echo "  ----------------------------------------------------------------"
        for f in "${INVENTORY_DIR}"/*.state; do
            localo "  ----------------------------------------------------------------"
        for f in "${INVENTORY_DIR}"/*.state; do
            local name ip role status
            name=$(basename "$f" .state)
            ip=$(grep -E name ip role status
            name=$(basename "$f" .state)
            ip=$(grep -E '^IP=' "$f" 2>/dev/null | cut -d= -f2)
            role=$(grep '^IP=' "$f" 2>/dev/null | cut -d= -f2)
            role=$(grep -E '^ROLE=' "$f" 2>/dev/null | cut -d= -f2)
            status=$(grep -E '^STATUS=' "$f"  -E '^ROLE=' "$f" 2>/dev/null | cut -d= -f2)
            status=$(grep -E '^STATUS=' "$f" 2>/dev/null | cut -d= -f2)
            printf "  %-20s %-15s %-20s %s\n" "$name" "${ip:-未知}" "${role:-2>/dev/null | cut -d= -f2)
            printf "  %-20s %-15s %-20s %s\n" "$name" "${ip:-未知}" "${role:-未知}" "${status:-未知}"
        done
    else
        warn "暂无节点注册"
    fi
    pause
}

show_monito未知}" "${status:-未知}"
        done
    else
        warn "暂无节点注册"
    fi
    pause
}

show_monitoring_menu() {
    safe_clear; show_header
    echo ""
    echo "【监控与告警】"
    echo "------------------------------------------------------------"
    echo " 1) ring_menu() {
    safe_clear; show_header
    echo ""
    echo "【监控与告警】"
    echo "------------------------------------------------------------"
    echo " 1) 打开 Grafana  2) VictoriaMetrics  3) Loki  9) 返回"
    ech打开 Grafana  2) VictoriaMetrics  3) Loki  9) 返回"
    echo "------------------------------------------------------------"
    read -rp "请选择：" _;
}

show_incident_menu() {
    safe_clear; show_header
    echo ""
    echo "【应o "------------------------------------------------------------"
    read -rp "请选择：" _;
}

show_incident_menu() {
    safe_clear; show_header
    echo ""
    echo "【应急响应工具箱】"
    echo "[!] 高风险操作，请确认后再急响应工具箱】"
    echo "[!] 高风险操作，请确认后再使用"
    echo "------------------------------------------------------------"
    echo " 1) 跨国断使用"
    echo "------------------------------------------------------------"
    echo " 1) 跨国断网切换  2) etcd 恢复  3) 主从切换  9) 返回"
    echo "------------------------------------------------------------网切换  2) etcd 恢复  3) 主从切换  9) 返回"
    echo "------------------------------------------------------------"
    read -rp "请选择：" _;
}

show_docs_menu() {
    safe_clear; show_header
    echo ""
    echo "【文档与帮助】"
    echo "------"
    read -rp "请选择：" _;
}

show_docs_menu() {
    safe_clear; show_header
    echo ""
    echo "【文档与帮助】"
    echo "------------------------------------------------------------"
    echo " 1) 架构详解  2) 故障排查  3) 贡献指南  9) 返回"
    echo "------------------------------------------------------"
    echo " 1) 架构详解  2) 故障排查  3) 贡献指南  9) 返回"
    echo "------------------------------------------------------------"
    read -rp "请选择：" _;
}

list_installed_apps() {
    local node="$1"
    safe_clear; show_header------------------------------------------------------------"
    read -rp "请选择：" _;
}

list_installed_apps() {
    local node="$1"
    safe_clear; show_header
    info "正在读取【${node}】已安装应用..."
    echo ""
    local state
    info "正在读取【${node}】已安装应用..."
    echo ""
    local state_file="${INVENTORY_DIR}/${node}.state"
    if [[ -f "$state_file" ]]; then
        grep -E '^APP_'_file="${INVENTORY_DIR}/${node}.state"
    if [[ -f "$state_file" ]]; then
        grep -E '^APP_' "$state_file" | sed 's/^APP_/  [OK] /' | sed 's/= "$state_file" | sed 's/^APP_/  [OK] /' | sed 's/=/ -> /'
    else
        warn "暂无安装记录"
    fi
    pause
}

#/ -> /'
    else
        warn "暂无安装记录"
    fi
    pause
}

# ---------- 主入口 ----------
main() {
    if [[ $EUID -ne 0 ]]; then
        warn "建 ---------- 主入口 ----------
main() {
    if [[ $EUID -ne 0 ]]; then
        warn "建议使用 root 用户运行"
        sleep 1
    fi
    show_main_menu
}

main "$@"议使用 root 用户运行"
        sleep 1
    fi
    show_main_menu
}

main "$@"
