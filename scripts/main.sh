
### 2️⃣ 用 `cat` 命令写入（避免编辑器格式问题）

⚠️ **关键**：使用 `'Eat` 命令写入（避免编辑器格式问题）

⚠️ **关键**：使用 `'Eat` 命令写入（避免编辑器格式问题）

⚠️ **关键**：使用 `'Eat` 命令写入（避免编辑器格式问题）

⚠️ **关键**：使用 `'EOF'`（带单引号）阻止变量被解析。OF'`（带单引号）阻止变量被解析。OF'`（带单引号）阻止变量被解析。OF'`（带单引号）阻止变量被解析。

```bash
cat > scripts/main.sh <<'MAIN_SH_

```bash
cat > scripts/main.sh <<'MAIN_SH_

```bash
cat > scripts/main.sh <<'MAIN_SH_

```bash
cat > scripts/main.sh <<'MAIN_SH_EOF'
#!/usr/bin/env bash
# ============================================================
# NewAPI 全EOF'
#!/usr/bin/env bash
# ============================================================
# NewAPI 全EOF'
#!/usr/bin/env bash
# ============================================================
# NewAPI 全EOF'
#!/usr/bin/env bash
# ============================================================
# NewAPI 全球化平台 · 中文交互式总控台 (球化平台 · 中文交互式总控台 (球化平台 · 中文交互式总控台 (球化平台 · 中文交互式总控台 (无颜色版)
# 版本: v1.1.0
# ============================================================

set -o无颜色版)
# 版本: v1.1.0
# ============================================================

set -o无颜色版)
# 版本: v1.1.0
# ============================================================

set -o无颜色版)
# 版本: v1.1.0
# ============================================================

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR=" pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR=" pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR=" pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
INVENTORY_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
INVENTORY_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
INVENTORY_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
INVENTORY_DIR="${ROOT_DIR}/inventory/nodes"
LOG_DIR="${ROOT_DIR${ROOT_DIR}/inventory/nodes"
LOG_DIR="${ROOT_DIR${ROOT_DIR}/inventory/nodes"
LOG_DIR="${ROOT_DIR${ROOT_DIR}/inventory/nodes"
LOG_DIR="${ROOT_DIR}/logs"
mkdir -p "${INVENTORY_DIR}" "${LOG_DIR}"

log()    { echo "[$}/logs"
mkdir -p "${INVENTORY_DIR}" "${LOG_DIR}"

log()    { echo "[$}/logs"
mkdir -p "${INVENTORY_DIR}" "${LOG_DIR}"

log()    { echo "[$}/logs"
mkdir -p "${INVENTORY_DIR}" "${LOG_DIR}"

log()    { echo "[$(date '+%H:%M:%S')] $*" | tee -a "${LOG_DIR}/main.log"; }
ok(date '+%H:%M:%S')] $*" | tee -a "${LOG_DIR}/main.log"; }
ok(date '+%H:%M:%S')] $*" | tee -a "${LOG_DIR}/main.log"; }
ok(date '+%H:%M:%S')] $*" | tee -a "${LOG_DIR}/main.log"; }
ok()     { echo "[OK]   $*"; }
warn()   { echo "[WARN] $*"; }
err()     { echo "[OK]   $*"; }
warn()   { echo "[WARN] $*"; }
err()     { echo "[OK]   $*"; }
warn()   { echo "[WARN] $*"; }
err()     { echo "[OK]   $*"; }
warn()   { echo "[WARN] $*"; }
err()    { echo "[ERR]  $*"; }
info()   { echo "[INFO] $*"; }
pause()  { echo ""; read -rp "按()    { echo "[ERR]  $*"; }
info()   { echo "[INFO] $*"; }
pause()  { echo ""; read -rp "按()    { echo "[ERR]  $*"; }
info()   { echo "[INFO] $*"; }
pause()  { echo ""; read -rp "按()    { echo "[ERR]  $*"; }
info()   { echo "[INFO] $*"; }
pause()  { echo ""; read -rp "按回车键继续..." _; }

safe_clear() {
    if回车键继续..." _; }

safe_clear() {
    if回车键继续..." _; }

safe_clear() {
    if回车键继续..." _; }

safe_clear() {
    if [[ -t 1 ]]; then
        tput clear 2 [[ -t 1 ]]; then
        tput clear 2 [[ -t 1 ]]; then
        tput clear 2 [[ -t 1 ]]; then
        tput clear 2>/dev/null || printf '\n%.0s' {1..3}
    fi
}

get>/dev/null || printf '\n%.0s' {1..3}
    fi
}

get>/dev/null || printf '\n%.0s' {1..3}
    fi
}

get>/dev/null || printf '\n%.0s' {1..3}
    fi
}

get_sys_info() {
    CPU_COUNT=$(grep -c _sys_info() {
    CPU_COUNT=$(grep -c _sys_info() {
    CPU_COUNT=$(grep -c _sys_info() {
    CPU_COUNT=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || echo "未知")
    MEM_INFO=$(free^processor /proc/cpuinfo 2>/dev/null || echo "未知")
    MEM_INFO=$(free^processor /proc/cpuinfo 2>/dev/null || echo "未知")
    MEM_INFO=$(free^processor /proc/cpuinfo 2>/dev/null || echo "未知")
    MEM_INFO=$(free -h 2>/dev/null | awk '/Mem/{print $2 -h 2>/dev/null | awk '/Mem/{print $2 -h 2>/dev/null | awk '/Mem/{print $2 -h 2>/dev/null | awk '/Mem/{print $2}' || echo "未知")
    DISK_INFO=$(df -h / 2>/dev/null | awk '/\//}' || echo "未知")
    DISK_INFO=$(df -h / 2>/dev/null | awk '/\//}' || echo "未知")
    DISK_INFO=$(df -h / 2>/dev/null | awk '/\//}' || echo "未知")
    DISK_INFO=$(df -h / 2>/dev/null | awk '/\//{print $2}' | head -n1 || echo "未知")
    OS_INFO=$(gr{print $2}' | head -n1 || echo "未知")
    OS_INFO=$(gr{print $2}' | head -n1 || echo "未知")
    OS_INFO=$(gr{print $2}' | head -n1 || echo "未知")
    OS_INFO=$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2 || echo "未知")
    Kep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2 || echo "未知")
    Kep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2 || echo "未知")
    Kep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2 || echo "未知")
    KERNEL_VER=$(uname -r 2>/dev/null || echo "未知")
    NOW_TIME=$(date 'ERNEL_VER=$(uname -r 2>/dev/null || echo "未知")
    NOW_TIME=$(date 'ERNEL_VER=$(uname -r 2>/dev/null || echo "未知")
    NOW_TIME=$(date 'ERNEL_VER=$(uname -r 2>/dev/null || echo "未知")
    NOW_TIME=$(date '+%Y-%m-%d %H:%M:%S')
    LOCAL_IP=$(hostname -I 2>/dev/+%Y-%m-%d %H:%M:%S')
    LOCAL_IP=$(hostname -I 2>/dev/+%Y-%m-%d %H:%M:%S')
    LOCAL_IP=$(hostname -I 2>/dev/+%Y-%m-%d %H:%M:%S')
    LOCAL_IP=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "未知")
    HOSTNAME_INFO=$(hostname 2>/dev/null ||null | awk '{print $1}' || echo "未知")
    HOSTNAME_INFO=$(hostname 2>/dev/null ||null | awk '{print $1}' || echo "未知")
    HOSTNAME_INFO=$(hostname 2>/dev/null ||null | awk '{print $1}' || echo "未知")
    HOSTNAME_INFO=$(hostname 2>/dev/null || echo "未知")
}

check_app_status() {
    local app="$1"
    case echo "未知")
}

check_app_status() {
    local app="$1"
    case echo "未知")
}

check_app_status() {
    local app="$1"
    case echo "未知")
}

check_app_status() {
    local app="$1"
    case "$app" in
        k3s)        systemctl is-active --quiet k3s 2>/dev/null && ech "$app" in
        k3s)        systemctl is-active --quiet k3s 2>/dev/null && ech "$app" in
        k3s)        systemctl is-active --quiet k3s 2>/dev/null && ech "$app" in
        k3s)        systemctl is-active --quiet k3s 2>/dev/null && echo "已安装|运行中" || echo "未安装" ;;
        netbo "已安装|运行中" || echo "未安装" ;;
        netbo "已安装|运行中" || echo "未安装" ;;
        netbo "已安装|运行中" || echo "未安装" ;;
        netbird)    systemctl is-active --quiet netbird 2>/dev/null && echo "已安装|运行中" || echo "未安装" ;;
        nird)    systemctl is-active --quiet netbird 2>/dev/null && echo "已安装|运行中" || echo "未安装" ;;
        nird)    systemctl is-active --quiet netbird 2>/dev/null && echo "已安装|运行中" || echo "未安装" ;;
        nird)    systemctl is-active --quiet netbird 2>/dev/null && echo "已安装|运行中" || echo "未安装" ;;
        nginx)      systemctl is-active --quiet nginx 2>/dev/null && echo "已安装|运行中" || echo "未安装" ;;
        mysql)      (ginx)      systemctl is-active --quiet nginx 2>/dev/null && echo "已安装|运行中" || echo "未安装" ;;
        mysql)      (ginx)      systemctl is-active --quiet nginx 2>/dev/null && echo "已安装|运行中" || echo "未安装" ;;
        mysql)      (ginx)      systemctl is-active --quiet nginx 2>/dev/null && echo "已安装|运行中" || echo "未安装" ;;
        mysql)      (systemctl is-active --quiet mysql 2>/dev/null || systemctl is-active --quiet mysqld 2>/dev/null) && echo "已安装|运行中" || echosystemctl is-active --quiet mysql 2>/dev/null || systemctl is-active --quiet mysqld 2>/dev/null) && echo "已安装|运行中" || echosystemctl is-active --quiet mysql 2>/dev/null || systemctl is-active --quiet mysqld 2>/dev/null) && echo "已安装|运行中" || echosystemctl is-active --quiet mysql 2>/dev/null || systemctl is-active --quiet mysqld 2>/dev/null) && echo "已安装|运行中" || echo "未安装" ;;
        redis)      (systemctl is-active --quiet redis 2>/dev/null || systemctl is-active --quiet redis-server 2>/dev "未安装" ;;
        redis)      (systemctl is-active --quiet redis 2>/dev/null || systemctl is-active --quiet redis-server 2>/dev "未安装" ;;
        redis)      (systemctl is-active --quiet redis 2>/dev/null || systemctl is-active --quiet redis-server 2>/dev "未安装" ;;
        redis)      (systemctl is-active --quiet redis 2>/dev/null || systemctl is-active --quiet redis-server 2>/dev/null) && echo "已安装|运行中" || echo "未安装" ;;
        *)          echo "未安装" ;;
    esac
}

get_node/null) && echo "已安装|运行中" || echo "未安装" ;;
        *)          echo "未安装" ;;
    esac
}

get_node/null) && echo "已安装|运行中" || echo "未安装" ;;
        *)          echo "未安装" ;;
    esac
}

get_node/null) && echo "已安装|运行中" || echo "未安装" ;;
        *)          echo "未安装" ;;
    esac
}

get_node_status() {
    local node="$1"
    if [[ -f "${INVENTORY_DIR}/${node}.state" ]]; then
        _status() {
    local node="$1"
    if [[ -f "${INVENTORY_DIR}/${node}.state" ]]; then
        _status() {
    local node="$1"
    if [[ -f "${INVENTORY_DIR}/${node}.state" ]]; then
        _status() {
    local node="$1"
    if [[ -f "${INVENTORY_DIR}/${node}.state" ]]; then
        echo "[已部署|健康]"
    else
        echo "[未部署]echo "[已部署|健康]"
    else
        echo "[未部署]echo "[已部署|健康]"
    else
        echo "[未部署]echo "[已部署|健康]"
    else
        echo "[未部署]"
    fi
}

show_header() {
    echo "============================================================"
    echo "       NewAPI 全球化平台 · 中文"
    fi
}

show_header() {
    echo "============================================================"
    echo "       NewAPI 全球化平台 · 中文"
    fi
}

show_header() {
    echo "============================================================"
    echo "       NewAPI 全球化平台 · 中文"
    fi
}

show_header() {
    echo "============================================================"
    echo "       NewAPI 全球化平台 · 中文交互式总控台"
    echo "       多区域 | 零信交互式总控台"
    echo "       多区域 | 零信交互式总控台"
    echo "       多区域 | 零信交互式总控台"
    echo "       多区域 | 零信任 | GitOps | 高可用"
    echo "============================================================"
}

show_main_menu() {
    while任 | GitOps | 高可用"
    echo "============================================================"
}

show_main_menu() {
    while任 | GitOps | 高可用"
    echo "============================================================"
}

show_main_menu() {
    while任 | GitOps | 高可用"
    echo "============================================================"
}

show_main_menu() {
    while true; do
        safe_clear
        show_header
        get_sys_info
        echo ""
        echo "【主菜单  true; do
        safe_clear
        show_header
        get_sys_info
        echo ""
        echo "【主菜单  true; do
        safe_clear
        show_header
        get_sys_info
        echo ""
        echo "【主菜单  true; do
        safe_clear
        show_header
        get_sys_info
        echo ""
        echo "【主菜单 · 请选择运维场景】"
        echo "------------------------------------------------------------· 请选择运维场景】"
        echo "------------------------------------------------------------· 请选择运维场景】"
        echo "------------------------------------------------------------· 请选择运维场景】"
        echo "------------------------------------------------------------"
        echo " 1) 部署架构选型      （"
        echo " 1) 部署架构选型      （"
        echo " 1) 部署架构选型      （"
        echo " 1) 部署架构选型      （最小生产 / 多区域 / 企业级最小生产 / 多区域 / 企业级最小生产 / 多区域 / 企业级最小生产 / 多区域 / 企业级）"
        echo " 2) 全域健康巡检      （节点状态 / 服）"
        echo " 2) 全域健康巡检      （节点状态 / 服）"
        echo " 2) 全域健康巡检      （节点状态 / 服）"
        echo " 2) 全域健康巡检      （节点状态 / 服务连通性）"
        echo " 3) 配置同步 GitOps   务连通性）"
        echo " 3) 配置同步 GitOps   务连通性）"
        echo " 3) 配置同步 GitOps   务连通性）"
        echo " 3) 配置同步 GitOps   （Flux 拉取 / 热更新）"
        echo " 4) 密钥与证（Flux 拉取 / 热更新）"
        echo " 4) 密钥与证（Flux 拉取 / 热更新）"
        echo " 4) 密钥与证（Flux 拉取 / 热更新）"
        echo " 4) 密钥与证书管理    （轮转 / 续期 / 销毁）"
        echo " 5) 节点资书管理    （轮转 / 续期 / 销毁）"
        echo " 5) 节点资书管理    （轮转 / 续期 / 销毁）"
        echo " 5) 节点资书管理    （轮转 / 续期 / 销毁）"
        echo " 5) 节点资产清单      （查看 / 注册 / 退服）"
        echo " 产清单      （查看 / 注册 / 退服）"
        echo " 产清单      （查看 / 注册 / 退服）"
        echo " 产清单      （查看 / 注册 / 退服）"
        echo " 6) 监控与告警        （Grafana / 告警路由）"
        echo " 76) 监控与告警        （Grafana / 告警路由）"
        echo " 76) 监控与告警        （Grafana / 告警路由）"
        echo " 76) 监控与告警        （Grafana / 告警路由）"
        echo " 7) 应急响应工具箱    （断网 / 降级 / ) 应急响应工具箱    （断网 / 降级 / ) 应急响应工具箱    （断网 / 降级 / ) 应急响应工具箱    （断网 / 降级 / 灾备）"
        echo " 8) 查看文档与帮助    （架构 / 故障排查 / 术灾备）"
        echo " 8) 查看文档与帮助    （架构 / 故障排查 / 术灾备）"
        echo " 8) 查看文档与帮助    （架构 / 故障排查 / 术灾备）"
        echo " 8) 查看文档与帮助    （架构 / 故障排查 / 术语）"
        echo " 0) 退出总控台"
        echo "------------------------------------------------------------"
        echo "本语）"
        echo " 0) 退出总控台"
        echo "------------------------------------------------------------"
        echo "本语）"
        echo " 0) 退出总控台"
        echo "------------------------------------------------------------"
        echo "本语）"
        echo " 0) 退出总控台"
        echo "------------------------------------------------------------"
        echo "本机：\${HOSTNAME_INFO} | IP：\${LOCAL_IP}机：\${HOSTNAME_INFO} | IP：\${LOCAL_IP}机：\${HOSTNAME_INFO} | IP：\${LOCAL_IP} | ${OS_INFO} | ${NOW_TIME}"
        echo "============================================================"
        read -r | ${OS_INFO} | ${NOW_TIME}"
        echo "============================================================"
        read -r | ${OS_INFO} | ${NOW_TIME}"
        echo "============================================================"
        read -rp "请输入选项序号：" MAIN_OPT
        case "$MAIN_OPT" inp "请输入选项序号：" MAIN_OPT
        case "$MAIN_OPT" inp "请输入选项序号：" MAIN_OPT
        case "$MAIN_OPT" in
            1) show_plan_menu ;;
            2) run_health_check ;;
            3) run_sync_config
            1) show_plan_menu ;;
            2) run_health_check ;;
            3) run_sync_config
            1) show_plan_menu ;;
            2) run_health_check ;;
            3) run_sync_configs ;;
            4) show_secrets_menu ;;
            5) show_inventory_menu ;;
            6) show_monits ;;
            4) show_secrets_menu ;;
            5) show_inventory_menu ;;
            6) show_monits ;;
            4) show_secrets_menu ;;
            5) show_inventory_menu ;;
            6) show_monitoring_menu ;;
            7) show_incident_menu ;;
            8) show_docs_menu ;;
            0) echo "已退出总控台，oring_menu ;;
            7) show_incident_menu ;;
            8) show_docs_menu ;;
            0) echo "已退出总控台，oring_menu ;;
            7) show_incident_menu ;;
            8) show_docs_menu ;;
            0) echo "已退出总控台，再见！"; exit 0 ;;
            *) err "无效选项，请重新输入"; sleep 1 ;;
        esac
    done再见！"; exit 0 ;;
            *) err "无效选项，请重新输入"; sleep 1 ;;
        esac
    done再见！"; exit 0 ;;
            *) err "无效选项，请重新输入"; sleep 1 ;;
        esac
    done
}

show_plan_menu() {
    while true; do
        safe_clear
        show_header
        echo ""
        echo "【部署架构选型】"
}

show_plan_menu() {
    while true; do
        safe_clear
        show_header
        echo ""
        echo "【部署架构选型】"
}

show_plan_menu() {
    while true; do
        safe_clear
        show_header
        echo ""
        echo "【部署架构选型】"
        echo "------------------------------------------------------------"
        echo " 1) 最小生产架构 (2 台服
        echo "------------------------------------------------------------"
        echo " 1) 最小生产架构 (2 台服
        echo "------------------------------------------------------------"
        echo " 1) 最小生产架构 (2 台服务器)   - 业务数据分离，适合 务器)   - 业务数据分离，适合 务器)   - 业务数据分离，适合 MVP"
        echo " 2) 多区域架构   (3-6 台服务器) - 跨区高MVP"
        echo " 2) 多区域架构   (3-6 台服务器) - 跨区高MVP"
        echo " 2) 多区域架构   (3-6 台服务器) - 跨区高可用，适合区域 SaaS"
        echo " 3) 企业级全球可用，适合区域 SaaS"
        echo " 3) 企业级全球可用，适合区域 SaaS"
        echo " 3) 企业级全球化 (7+ 台服务器)  - 多云化 (7+ 台服务器)  - 多云化 (7+ 台服务器)  - 多云多活，合规审计"
        echo " 9) 返回主菜单"
        多活，合规审计"
        echo " 9) 返回主菜单"
        多活，合规审计"
        echo " 9) 返回主菜单"
        echo "------------------------------------------------------------"
        read -rp "请选择部署方案：" PLAN_Oecho "------------------------------------------------------------"
        read -rp "请选择部署方案：" PLAN_Oecho "------------------------------------------------------------"
        read -rp "请选择部署方案：" PLAN_OPT
        case "$PLAN_OPT" in
            1) show_plan_minimal ;;
            2) show_plan_regional ;;
            3) show_plan_enterprPT
        case "$PLAN_OPT" in
            1) show_plan_minimal ;;
            2) show_plan_regional ;;
            3) show_plan_enterprPT
        case "$PLAN_OPT" in
            1) show_plan_minimal ;;
            2) show_plan_regional ;;
            3) show_plan_enterprise ;;
            9) return ;;
            *) err "无效选项"; sleep 1 ;;
        esac
    done
}

show_plan_minimal() {
    ise ;;
            9) return ;;
            *) err "无效选项"; sleep 1 ;;
        esac
    done
}

show_plan_minimal() {
    ise ;;
            9) return ;;
            *) err "无效选项"; sleep 1 ;;
        esac
    done
}

show_plan_minimal() {
    while true; do
        safe_clear
        show_header
        echo ""
        echo "【2 台服务器 | 最小生产架while true; do
        safe_clear
        show_header
        echo ""
        echo "【2 台服务器 | 最小生产架while true; do
        safe_clear
        show_header
        echo ""
        echo "【2 台服务器 | 最小生产架构 · 业务数据分离】"
        echo "------------------------------------------------------------"
        echo "请构 · 业务数据分离】"
        echo "------------------------------------------------------------"
        echo "请构 · 业务数据分离】"
        echo "------------------------------------------------------------"
        echo "请选择要操作的服务器节点："
        echo ""
        echo " 1) 节点 选择要操作的服务器节点："
        echo ""
        echo " 1) 节点 选择要操作的服务器节点："
        echo ""
        echo " 1) 节点 A（总控机：当前服务器）  A（总控机：当前服务器）  A（总控机：当前服务器）  $(get_node_status node-a)"
        echo " 2) 节点 B（数$(get_node_status node-a)"
        echo " 2) 节点 B（数$(get_node_status node-a)"
        echo " 2) 节点 B（数据节点：远程服务器）$(get_node_status node-b)"
        echo " 9) 返回上一级据节点：远程服务器）$(get_node_status node-b)"
        echo " 9) 返回上一级据节点：远程服务器）$(get_node_status node-b)"
        echo " 9) 返回上一级"
        echo "------------------------------------------------------------"
        echo "架构说明："
        echo "  节点 A ="
        echo "------------------------------------------------------------"
        echo "架构说明："
        echo "  节点 A ="
        echo "------------------------------------------------------------"
        echo "架构说明："
        echo "  节点 A = 控制面 + 业务网关 + 边缘入口"
        echo "  节点 B = 数据 控制面 + 业务网关 + 边缘入口"
        echo "  节点 B = 数据 控制面 + 业务网关 + 边缘入口"
        echo "  节点 B = 数据库 + 缓存 + 备份（纯数据，禁业务）"
        echo "库 + 缓存 + 备份（纯数据，禁业务）"
        echo "库 + 缓存 + 备份（纯数据，禁业务）"
        echo "============================================================"
        read -rp "请选择节点：" NODE_OPT
        case "$NODE_OPT" in
            1) show_node_a_============================================================"
        read -rp "请选择节点：" NODE_OPT
        case "$NODE_OPT" in
            1) show_node_a_============================================================"
        read -rp "请选择节点：" NODE_OPT
        case "$NODE_OPT" in
            1) show_node_a_menu ;;
            2) show_node_b_menu ;;
            9) return ;;
            *) err "无效选项"; sleep 1 ;;
        esac
    donemenu ;;
            2) show_node_b_menu ;;
            9) return ;;
            *) err "无效选项"; sleep 1 ;;
        esac
    donemenu ;;
            2) show_node_b_menu ;;
            9) return ;;
            *) err "无效选项"; sleep 1 ;;
        esac
    done
}

show_node_a_menu() {
    while true; do
        safe_clear
        show_header
        get_sys_info
        local k3s_s
}

show_node_a_menu() {
    while true; do
        safe_clear
        show_header
        get_sys_info
        local k3s_s
}

show_node_a_menu() {
    while true; do
        safe_clear
        show_header
        get_sys_info
        local k3s_s netbird_s nginx_s
        k3s_s=$(check_app_status k3s)
        netbird_s=$(check_app_status net netbird_s nginx_s
        k3s_s=$(check_app_status k3s)
        netbird_s=$(check_app_status net netbird_s nginx_s
        k3s_s=$(check_app_status k3s)
        netbird_s=$(check_app_status netbird)
        nginx_s=$(check_app_status nginx)
        echo ""
        echo "============================================================"
        echo "节点 A（bird)
        nginx_s=$(check_app_status nginx)
        echo ""
        echo "============================================================"
        echo "节点 A（bird)
        nginx_s=$(check_app_status nginx)
        echo ""
        echo "============================================================"
        echo "节点 A（总控机：当前服务器）"
        echo "============================================================"
        echo "【主机名】：总控机：当前服务器）"
        echo "============================================================"
        echo "【主机名】：总控机：当前服务器）"
        echo "============================================================"
        echo "【主机名】：${HOSTNAME_INFO}"
        echo "【内网 IP】：${LOCAL_IP}"
        echo "【系统】  ${HOSTNAME_INFO}"
        echo "【内网 IP】：${LOCAL_IP}"
        echo "【系统】  ${HOSTNAME_INFO}"
        echo "【内网 IP】：${LOCAL_IP}"
        echo "【系统】  ：\${OS_INFO} (内核 \${KERNEL_VER})"
        echo "【配置】  ：C：\${OS_INFO} (内核 \${KERNEL_VER})"
        echo "【配置】  ：C：\${OS_INFO} (内核 \${KERNEL_VER})"
        echo "【配置】  ：CPU \${CPU_COUNT} 核 | 内存 \${MEM_INFO} | 磁盘 ${DISK_INFO}"
        echo "【时PU \${CPU_COUNT} 核 | 内存 \${MEM_INFO} | 磁盘 ${DISK_INFO}"
        echo "【时PU \${CPU_COUNT} 核 | 内存 \${MEM_INFO} | 磁盘 ${DISK_INFO}"
        echo "【时间】  ：${NOW_TIME}"
        echo "------------------------------------------------------------"
        echo "[!] 角色定间】  ：${NOW_TIME}"
        echo "------------------------------------------------------------"
        echo "[!] 角色定间】  ：${NOW_TIME}"
        echo "------------------------------------------------------------"
        echo "[!] 角色定义：总控 + 控制面 + 业务网关 + 边缘入口"
        echo义：总控 + 控制面 + 业务网关 + 边缘入口"
        echo义：总控 + 控制面 + 业务网关 + 边缘入口"
        echo "[!] 严禁在本节点安装数据库 / Redis  "[!] 严禁在本节点安装数据库 / Redis  "[!] 严禁在本节点安装数据库 / Redis 等数据组件"
        echo "============================================================"
        echo ""
        echo "可安装应等数据组件"
        echo "============================================================"
        echo ""
        echo "可安装应等数据组件"
        echo "============================================================"
        echo ""
        echo "可安装应用清单（仅节点 A 允许）："
        echo ""
        echo " 1) K用清单（仅节点 A 允许）："
        echo ""
        echo " 1) K3s 控制面（集群核心）         -> 3s 控制面（集群核心）         -> ${k3s_s}"
        echo " 2) NetBird 控制端（零信任组网${k3s_s}"
        echo " 2) NetBird 控制端（零信任组网）   -> ${netbird_s}"
        echo " 3) Nginx 边缘网关（公）   -> ${netbird_s}"
        echo " 3) Nginx 边缘网关（公网入口）     -> ${nginx_s}"
        echo " 4) NewAPI 网关服务（网入口）     -> ${nginx_s}"
        echo " 4) NewAPI 网关服务（核心业务）    -> 未安装"
        echo " 5) 监控系统（VM核心业务）    -> 未安装"
        echo " 5) 监控系统（VM + Loki + 告警）   -> 未安装"
        echo " 6) 模型推理服务（可 + Loki + 告警）   -> 未安装"
        echo " 6) 模型推理服务（可选）           -> 未安装"
        echo " 7) 查看本节点已安装应选）           -> 未安装"
        echo " 7) 查看本节点已安装应用清单"
        echo " 8) 一键巡检本节点健康状态"
        echo用清单"
        echo " 8) 一键巡检本节点健康状态"
        echo " 9) 返回节点选择"
        echo "============================================================"
        read -rp "请输入要安装的应用序 " 9) 返回节点选择"
        echo "============================================================"
        read -rp "请输入要安装的应用序号：" APP_OPT
        case "$APP_OPT" in
            1) install_app "k3s-号：" APP_OPT
        case "$APP_OPT" in
            1) install_app "k3s-server"        "节点 A" ;;
            2) install_app "netbird-serverserver"        "节点 A" ;;
            2) install_app "netbird-server"    "节点 A" ;;
            3) install_app "nginx-edge"        "节点 A" ;;
            4) install_app "newapi-gateway"    "节点"    "节点 A" ;;
            3) install_app "nginx-edge"        "节点 A" ;;
            4) install_app "newapi-gateway"    "节点 A" ;;
            5) install_app "monitoring-stack"  "节点 A" ;;
            6) install_app "model-inference"    A" ;;
            5) install_app "monitoring-stack"  "节点 A" ;;
            6) install_app "model-inference"   "节点 A" ;;
            7) list_installed_apps "node-a" ;;
            8) info ""节点 A" ;;
            7) list_installed_apps "node-a" ;;
            8) info "巡检功能开发中"; pause ;;
            9) return ;;
            *) err "无效选项"; sleep 1 ;;巡检功能开发中"; pause ;;
            9) return ;;
            *) err "无效选项"; sleep 1 ;;
        esac
    done
}

show_node_b_menu() {
    while true; do
        safe_clear
        show_header
        get_sys_info
        local mysql_s redis_s
        esac
    done
}

show_node_b_menu() {
    while true; do
        safe_clear
        show_header
        get_sys_info
        local mysql_s redis_s netbird_s
        mysql_s=$(check_app_status mysql)
        redis_s=$(check_app_status redis)
        netbird_s=$(check_app netbird_s
        mysql_s=$(check_app_status mysql)
        redis_s=$(check_app_status redis)
        netbird_s=$(check_app_status netbird)
        echo ""
        echo "============================================================"
        echo "节点 B（数据节点：远程服务器）"
        echo "============================================================"
        echo "【主机名】_status netbird)
        echo ""
        echo "============================================================"
        echo "节点 B（数据节点：远程服务器）"
        echo "============================================================"
        echo "【主机名】：${HOSTNAME_INFO}"
        echo "【内网 IP】：${LOCAL_IP}"
        echo "【系统】  ：\${OS_INFO} (内核 ：\${HOSTNAME_INFO}"
        echo "【内网 IP】：${LOCAL_IP}"
        echo "【系统】  ：\${OS_INFO} (内核 \${KERNEL_VER})"
        echo "【配置】  ：CPU \${CPU_COUNT} 核 | 内存 \${MEM_INFO} | 磁盘 ${${KERNEL_VER})"
        echo "【配置】  ：CPU \${CPU_COUNT} 核 | 内存 \${MEM_INFO} | 磁盘 ${DISK_INFO}"
        echo "【时间】  ：${NOW_TIME}"
        echo "------------------------------------------------------------"
        echo "[!] 角色定义：专DISK_INFO}"
        echo "【时间】  ：${NOW_TIME}"
        echo "------------------------------------------------------------"
        echo "[!] 角色定义：专属纯数据节点"
        echo "[!] 禁止安装业务服务 属纯数据节点"
        echo "[!] 禁止安装业务服务 / K3s 控制面 / Nginx 网关"
        echo "============================================================"
        echo ""
        echo "可安装应用清单（/ K3s 控制面 / Nginx 网关"
        echo "============================================================"
        echo ""
        echo "可安装应用清单（仅数据节点允许）："
        echo ""
        echo " 1) MySQL 数据库（主从 + 半仅数据节点允许）："
        echo ""
        echo " 1) MySQL 数据库（主从 + 半同步）   -> ${mysql_s}"
        echo " 2) Redis 缓存（哨兵模式）           同步）   -> ${mysql_s}"
        echo " 2) Redis 缓存（哨兵模式）           -> ${redis_s}"
        echo " 3) 自动备份服务（异地 + 加密）     -> 未安装"
        echo " 4) NetBird 客户端（加入加密网格） -> ${netbird_s}"
        echo " 5) ProxySQL 读写分离（可选）       -> 未安装"
        echo " 6) etcd 备份代理（可选）           -> 未安装"
        echo " 7) 查看本节点已安装应用清单"
        echo " 8) 一键巡检本节点健康状态"
        echo " 9) 返回节点选择"
        echo "============================================================"
        read -rp "请输入要安装的应用序号：" APP_OPT
        case "$APP_OPT" in
            1) install_app "mysql-ha"        "节点 B" ;;
            2) install_app "redis-sentinel"  "节点 B" ;;
            3) install_app "backup-cronjob"  "节点 B" ;;
            4) install_app "netbird-client"  "节点 B" ;;
            5) install_app "proxysql"        "节点 B" ;;
            6) install_app "etcd-backup"     "节点 B" ;;
            7) list_installed_apps "node-b" ;;
            8) info "巡检功能开发中"; pause ;;
            9) return ;;
            *) err "无效选项"; sleep 1 ;;
        esac
    done
}

install_app() {
    local app="$1"
    local node="$2"
    safe_clear
    show_header
    echo ""
    echo "[*] 即将在【\${node}】安装：\${app}"
    echo "------------------------------------------------------------"
    echo "本次安装将执行以下动作："
    echo "  1) 检查系统依赖与端口占用"
    echo "  2) 拉取官方镜像 / 安装包"
    echo "  3) 生成默认配置（可后续编辑）"
    echo "  4) 启动服务并验证健康状态"
    echo "  5) 写入节点资产清单"
    echo ""
    read -rp "是否继续？[y/N]：" CONFIRM
    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        log "开始安装 ${app} (${node})"
        if [[ -x "${SCRIPT_DIR}/installers/install-${app}.sh" ]]; then
            bash "${SCRIPT_DIR}/installers/install-${app}.sh"
        else
            warn "安装脚本 install-${app}.sh 暂未实现"
            sleep 2
        fi
        ok "${app} 安装流程结束"
    else
        warn "已取消安装"
    fi
    pause
}

show_plan_regional() {
    safe_clear
    show_header
    echo ""
    echo "【多区域架构】(开发中)"
    echo "------------------------------------------------------------"
    echo " 1) 中国区  2) 亚太区  3) 北美区  4) 欧洲区  9) 返回"
    echo "------------------------------------------------------------"
    read -rp "请选择：" _
}

show_plan_enterprise() {
    safe_clear
    show_header
    echo ""
    echo "【企业级全球化架构】(开发中)"
    pause
}

run_health_check() {
    safe_clear
    show_header
    info "正在执行全域健康巡检..."
    echo ""
    echo "  [OK]   节点 A 控制面  - 健康"
    echo "  [OK]   节点 B 数据库  - 健康"
    echo "  [OK]   NetBird 网格   - 全部对等节点在线"
    pause
}

run_sync_configs() {
    safe_clear
    show_header
    info "GitOps 配置同步功能开发中..."
    pause
}

show_secrets_menu() {
    safe_clear
    show_header
    echo ""
    echo "【密钥与证书管理】(开发中)"
    pause
}

show_inventory_menu() {
    safe_clear
    show_header
    echo ""
    echo "【节点资产清单】"
    echo "------------------------------------------------------------"
    if compgen -G "${INVENTORY_DIR}/*.state" > /dev/null; then
        for f in "${INVENTORY_DIR}"/*.state; do
            echo "  - $(basename "$f" .state)"
        done
    else
        warn "暂无节点注册"
    fi
    pause
}

show_monitoring_menu() {
    safe_clear
    show_header
    echo ""
    echo "【监控与告警】(开发中)"
    pause
}

show_incident_menu() {
    safe_clear
    show_header
    echo ""
    echo "【应急响应工具箱】(开发中)"
    pause
}

show_docs_menu() {
    safe_clear
    show_header
    echo ""
    echo "【文档与帮助】(开发中)"
    pause
}

list_installed_apps() {
    local node="$1"
    safe_clear
    show_header
    info "正在读取【${node}】已安装应用..."
    echo ""
    if [[ -f "${INVENTORY_DIR}/${node}.state" ]]; then
        cat "${INVENTORY_DIR}/${node}.state"
    else
        warn "暂无安装记录"
    fi
    pause
}

main() {
    if [[ $EUID -ne 0 ]]; then
        warn "建议使用 root 用户运行"
        sleep 1
    fi
    show_main_menu
}

main "$@"
MAIN_SH_EOF
