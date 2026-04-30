cat > /opt/newapi-global-platform/scripts/main_fixed.sh << 'MAINEOF'
#!/usr/bin/env bash
# NewAPI 总控台（修复版 - 兼容所有终端）
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
INVENTORY_DIR="${ROOT_DIR}/inventory/nodes"
LOG_DIR="${ROOT_DIR}/logs"
mkdir -p "${INVENTORY_DIR}" "${LOG_DIR}"

# 禁用颜色
RED=''
GREEN=''
YELLOW=''
BLUE=''
PURPLE=''
CYAN=''
WHITE=''
GRAY=''
NC=''

log()    { echo "[$(date '+%H:%M:%S')] $*" | tee -a "${LOG_DIR}/main.log"; }
ok()     { echo "[OK] $*"; }
warn()   { echo "[WARN] $*"; }
err()    { echo "[ERROR] $*"; }
info()   { echo "[INFO] $*"; }
pause()  { echo ""; echo -n "按回车键继续... "; read _; }

get_sys_info() {
    CPU_COUNT=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || echo "未知")
    MEM_INFO=$(free -h 2>/dev/null | awk '/Mem/{print $2}' || echo "未知")
    DISK_INFO=$(df -h / 2>/dev/null | awk '/\//{print $2}' | head -n1 || echo "未知")
    OS_INFO=$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2 || echo "未知")
    KERNEL_VER=$(uname -r 2>/dev/null || echo "未知")
    NOW_TIME=$(date '+%Y-%m-%d %H:%M:%S')
    LOCAL_IP=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "未知")
    HOSTNAME_INFO=$(hostname 2>/dev/null || echo "未知")
}

check_app_status() {
    local app="$1"
    case "$app" in
        k3s)        systemctl is-active --quiet k3s 2>/dev/null && echo "[OK] 已安装" || echo "[ ] 未安装" ;;
        netbird)    systemctl is-active --quiet netbird 2>/dev/null && echo "[OK] 已安装" || echo "[ ] 未安装" ;;
        nginx)      systemctl is-active --quiet nginx 2>/dev/null && echo "[OK] 已安装" || echo "[ ] 未安装" ;;
        newapi)     kubectl get pod -n newapi 2>/dev/null | grep -q Running && echo "[OK] 已部署" || echo "[ ] 未安装" ;;
        mysql)      systemctl is-active --quiet mysql 2>/dev/null && echo "[OK] 已安装" || echo "[ ] 未安装" ;;
        redis)      systemctl is-active --quiet redis 2>/dev/null && echo "[OK] 已安装" || echo "[ ] 未安装" ;;
        monitoring) kubectl get pod -n monitoring 2>/dev/null | grep -q Running && echo "[OK] 已部署" || echo "[ ] 未安装" ;;
        *)          echo "[ ] 未安装" ;;
    esac
}

show_header() {
    echo "+==============================================================+"
    echo "|     NewAPI 全球化平台 · 中文交互式总控台                    |"
    echo "|     多区域 | 零信任 | GitOps | 高可用                       |"
    echo "+==============================================================+"
}

get_node_status() {
    local node="$1"
    local state_file="${INVENTORY_DIR}/${node}.state"
    if [[ -f "$state_file" ]]; then
        echo "[OK] 部署完成"
    else
        echo "[ ] 未部署"
    fi
}

show_main_menu() {
    while true; do
        clear
        show_header
        get_sys_info
        echo ""
        echo "【主菜单 · 请选择运维场景】"
        echo "============================================================"
        echo " [1] 部署架构选型      （最小生产 / 多区域 / 企业级）"
        echo " [2] 全域健康巡检      （节点状态 / 服务连通性）"
        echo " [3] 配置同步 (GitOps) （Flux 拉取 / 热更新）"
        echo " [4] 密钥与证书管理    （轮转 / 续期 / 销毁）"
        echo " [5] 节点资产清单      （查看 / 注册 / 退服）"
        echo " [6] 监控与告警        （Grafana / 告警路由）"
        echo " [7] 应急响应工具箱    （断网 / 降级 / 灾备）"
        echo " [8] 查看文档与帮助    （架构 / 故障排查 / 术语）"
        echo " [0] 退出总控台"
        echo "============================================================"
        echo "本机：${HOSTNAME_INFO} | IP：${LOCAL_IP} | ${OS_INFO} | ${NOW_TIME}"
        echo "============================================================"
        echo -n "请输入选项序号: "
        read MAIN_OPT
        
        case "$MAIN_OPT" in
            1) show_plan_menu ;;
            2) info "健康巡检功能开发中"; pause ;;
            3) info "配置同步功能开发中"; pause ;;
            4) info "密钥管理功能开发中"; pause ;;
            5) info "资产清单功能开发中"; pause ;;
            6) info "监控告警功能开发中"; pause ;;
            7) info "应急响应功能开发中"; pause ;;
            8) info "文档查看功能开发中"; pause ;;
            0) echo "[OK] 已退出总控台，再见！"; exit 0 ;;
            *) err "无效选项，请重新输入"; sleep 1 ;;
        esac
    done
}

show_plan_menu() {
    while true; do
        clear
        show_header
        echo ""
        echo "【部署架构选型】"
        echo "============================================================"
        echo "请根据您的业务规模选择部署方案："
        echo ""
        echo " [1] 最小生产架构 (2 台服务器)"
        echo "        └─ 业务数据分离 | 适合 MVP / 中小团队"
        echo ""
        echo " [2] 多区域架构 (3-6 台服务器)"
        echo "        └─ 跨区高可用 | 适合区域级 SaaS"
        echo ""
        echo " [3] 企业级全球化 (7+ 台服务器)"
        echo "        └─ 多云多活 | 合规审计 | 适合跨国企业"
        echo ""
        echo " [9] 返回主菜单"
        echo "============================================================"
        echo -n "请选择部署方案: "
        read PLAN_OPT
        
        case "$PLAN_OPT" in
            1) show_plan_minimal ;;
            2) info "多区域架构功能开发中"; pause ;;
            3) info "企业级架构功能开发中"; pause ;;
            9) return ;;
            *) err "无效选项，请重新输入"; sleep 1 ;;
        esac
    done
}

show_plan_minimal() {
    while true; do
        clear
        show_header
        echo ""
        echo "【2 台服务器 | 最小生产架构 · 业务数据分离】"
        echo "============================================================"
        echo "请选择要操作的服务器节点："
        echo ""
        echo " [1] 节点 A（总控机：当前服务器）  $(get_node_status node-a)"
        echo " [2] 节点 B（数据节点：远程服务器）  $(get_node_status node-b)"
        echo ""
        echo " [9] 返回上一级"
        echo "============================================================"
        echo -n "请选择节点: "
        read NODE_OPT
        
        case "$NODE_OPT" in
            1) show_node_a_menu ;;
            2) show_node_b_menu ;;
            9) return ;;
            *) err "无效选项，请重新输入"; sleep 1 ;;
        esac
    done
}

show_node_a_menu() {
    while true; do
        clear
        show_header
        get_sys_info
        local k3s_status netbird_status nginx_status newapi_status mon_status
        k3s_status=$(check_app_status k3s)
        netbird_status=$(check_app_status netbird)
        nginx_status=$(check_app_status nginx)
        newapi_status=$(check_app_status newapi)
        mon_status=$(check_app_status monitoring)
        
        echo ""
        echo "=========================================================="
        echo "节点 A（总控机：当前服务器）"
        echo "=========================================================="
        echo "【主机名】：${HOSTNAME_INFO}"
        echo "【内网 IP】：${LOCAL_IP}"
        echo "【系统】  ：${OS_INFO} (内核 ${KERNEL_VER})"
        echo "【配置】  ：CPU ${CPU_COUNT} 核 | 内存 ${MEM_INFO} | 磁盘 ${DISK_INFO}"
        echo "【时间】  ：${NOW_TIME}"
        echo "=========================================================="
        echo "[!] 角色定义：总控 + 控制面 + 业务网关 + 边缘入口"
        echo "[!] 严禁在本节点安装数据库/Redis 等数据组件"
        echo "=========================================================="
        echo ""
        echo "可安装应用清单（仅节点 A 允许）："
        echo ""
        echo " [1] K3s 控制面（集群核心）         → ${k3s_status}"
        echo " [2] NetBird 控制端（零信任组网）   → ${netbird_status}"
        echo " [3] Nginx 边缘网关（公网入口）     → ${nginx_status}"
        echo " [4] NewAPI 网关服务（核心业务）   → ${newapi_status}"
        echo " [5] 监控系统（VM + Loki + 告警）   → ${mon_status}"
        echo " [6] 模型推理服务（可选）           → [ ] 未安装"
        echo " [7] 查看本节点已安装应用清单"
        echo " [8] 一键巡检本节点健康状态"
        echo " [9] 返回节点选择"
        echo "=========================================================="
        echo -n "请输入要安装的应用序号: "
        read APP_OPT
        
        case "$APP_OPT" in
            1) install_app "k3s-server" "节点 A" ;;
            2) install_app "netbird-server" "节点 A" ;;
            3) install_app "nginx-edge" "节点 A" ;;
            4) install_app "newapi-gateway" "节点 A" ;;
            5) install_app "monitoring-stack" "节点 A" ;;
            6) install_app "model-inference" "节点 A" ;;
            7) list_installed_apps "node-a" ;;
            8) info "健康检查功能开发中"; pause ;;
            9) return ;;
            *) err "无效选项，请重新输入"; sleep 1 ;;
        esac
    done
}

show_node_b_menu() {
    while true; do
        clear
        show_header
        get_sys_info
        local mysql_status redis_status backup_status netbird_status
        mysql_status=$(check_app_status mysql)
        redis_status=$(check_app_status redis)
        backup_status=$(check_app_status backup)
        netbird_status=$(check_app_status netbird)
        
        echo ""
        echo "=========================================================="
        echo "节点 B（数据节点：远程服务器）"
        echo "=========================================================="
        echo "【主机名】：${HOSTNAME_INFO}"
        echo "【内网 IP】：${LOCAL_IP}"
        echo "【系统】  ：${OS_INFO} (内核 ${KERNEL_VER})"
        echo "【配置】  ：CPU ${CPU_COUNT} 核 | 内存 ${MEM_INFO} | 磁盘 ${DISK_INFO}"
        echo "【时间】  ：${NOW_TIME}"
        echo "=========================================================="
        echo "[!] 角色定义：专属纯数据节点"
        echo "[!] 禁止安装业务服务 / K3s 控制面 / Nginx 网关"
        echo "=========================================================="
        echo ""
        echo "可安装应用清单（仅数据节点允许）："
        echo ""
        echo " [1] MySQL 数据库（主从 + 半同步）     → ${mysql_status}"
        echo " [2] Redis 缓存（哨兵模式）             → ${redis_status}"
        echo " [3] 自动备份服务（异地 + 加密）       → ${backup_status}"
        echo " [4] NetBird 客户端（加入加密网格）   → ${netbird_status}"
        echo " [5] ProxySQL 读写分离（可选）         → [ ] 未安装"
        echo " [6] etcd 备份代理（可选）             → [ ] 未安装"
        echo " [7] 查看本节点已安装应用清单"
        echo " [8] 一键巡检本节点健康状态"
        echo " [9] 返回节点选择"
        echo "=========================================================="
        echo -n "请输入要安装的应用序号: "
        read APP_OPT
        
        case "$APP_OPT" in
            1) install_app "mysql-ha" "节点 B" ;;
            2) install_app "redis-sentinel" "节点 B" ;;
            3) install_app "backup-cronjob" "节点 B" ;;
            4) install_app "netbird-client" "节点 B" ;;
            5) install_app "proxysql" "节点 B" ;;
            6) install_app "etcd-backup" "节点 B" ;;
            7) list_installed_apps "node-b" ;;
            8) info "健康检查功能开发中"; pause ;;
            9) return ;;
            *) err "无效选项，请重新输入"; sleep 1 ;;
        esac
    done
}

install_app() {
    local app="$1"
    local node="$2"
    clear
    show_header
    echo ""
    echo "[INFO] 即将在【${node}】安装：${app}"
    echo "=========================================================="
    info "本次安装将执行以下动作："
    echo "   1) 检查系统依赖与端口占用"
    echo "   2) 拉取官方镜像 / 安装包"
    echo "   3) 生成默认配置（可后续编辑）"
    echo "   4) 启动服务并验证健康状态"
    echo "   5) 写入节点资产清单"
    echo ""
    echo -n "是否继续？[y/N]: "
    read CONFIRM
    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        log "开始安装 ${app} (${node})"
        warn "安装脚本暂未实现，仅做演示"
        sleep 2
        ok "${app} 安装流程结束"
    else
        warn "已取消安装"
    fi
    pause
}

list_installed_apps() {
    local node="$1"
    clear
    show_header
    info "正在读取【${node}】已安装应用..."
    echo ""
    local state_file="${INVENTORY_DIR}/${node}.state"
    if [[ -f "$state_file" ]]; then
        grep -E '^APP_' "$state_file" | sed 's/^APP_/  [OK] /' | sed 's/=/ -> /'
    else
        warn "暂无安装记录"
    fi
    pause
}

main() {
    if [[ $EUID -ne 0 ]]; then
        warn "建议使用 root 用户运行（部分操作需要管理员权限）"
        sleep 1
    fi
    show_main_menu
}

main "$@"
MAINEOF

chmod +x /opt/newapi-global-platform/scripts/main_fixed.sh
