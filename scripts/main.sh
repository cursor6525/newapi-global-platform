bash <(curl -fsSL https://raw.githubusercontent.com/cursor6525/newapi-global-platform/main/scripts/main.sh 2>/dev/null || cat << 'EOF'
#!/usr/bin/env bash
# NewAPI 总控台 - 一键启动版
set -o pipefail

mkdir -p /opt/newapi-global-platform/{inventory/nodes,logs}
cd /opt/newapi-global-platform

# 如果脚本不存在，创建简化版
if [[ ! -f scripts/main.sh ]]; then
    cat > scripts/main.sh << 'SCRIPTEOF'
#!/usr/bin/env bash
set -o pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
INVENTORY_DIR="${ROOT_DIR}/inventory/nodes"
LOG_DIR="${ROOT_DIR}/logs"
mkdir -p "${INVENTORY_DIR}" "${LOG_DIR}"

get_sys_info() {
    CPU_COUNT=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || echo "?")
    MEM_INFO=$(free -h 2>/dev/null | awk '/Mem/{print $2}' || echo "?")
    DISK_INFO=$(df -h / 2>/dev/null | awk '/\//{print $2}' || echo "?")
    OS_INFO=$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2 || echo "?")
    NOW_TIME=$(date '+%Y-%m-%d %H:%M:%S')
    HOSTNAME_INFO=$(hostname 2>/dev/null || echo "?")
    LOCAL_IP=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "?")
}

get_node_status() {
    local state_file="${INVENTORY_DIR}/${1}.state"
    [[ -f "$state_file" ]] && echo "[OK] 已部署" || echo "[ ] 未部署"
}

show_header() {
    echo "+==============================================================+"
    echo "|     NewAPI 全球化平台 · 中文交互式总控台                    |"
    echo "|     多区域 | 零信任 | GitOps | 高可用                       |"
    echo "+==============================================================+"
}

show_main_menu() {
    while true; do
        clear
        show_header
        get_sys_info
        echo ""
        echo "【主菜单】"
        echo "============================================================"
        echo " [1] 部署架构选型      （最小生产 / 多区域 / 企业级）"
        echo " [2] 全域健康巡检"
        echo " [3] 配置同步 (GitOps)"
        echo " [4] 密钥与证书管理"
        echo " [5] 节点资产清单"
        echo " [6] 监控与告警"
        echo " [7] 应急响应工具箱"
        echo " [8] 查看文档与帮助"
        echo " [0] 退出总控台"
        echo "============================================================"
        echo "本机：${HOSTNAME_INFO} | IP：${LOCAL_IP} | ${NOW_TIME}"
        echo -n "请输入选项序号: "
        read -e -r OPT || true
        case "$OPT" in
            1) show_deploy_menu ;;
            0) echo "再见！"; exit 0 ;;
            *) echo "[INFO] 功能开发中"; echo -n "按回车继续..."; read _ ;;
        esac
    done
}

show_deploy_menu() {
    while true; do
        clear
        show_header
        echo ""
        echo "【部署架构选型】"
        echo "============================================================"
        echo " [1] 最小生产架构 (2 台服务器)"
        echo " [2] 多区域架构 (3-6 台服务器)"
        echo " [3] 企业级全球化 (7+ 台服务器)"
        echo " [9] 返回主菜单"
        echo -n "请选择: "
        read -e -r OPT || true
        case "$OPT" in
            1) show_minimal_arch ;;
            9) return ;;
            *) echo "[INFO] 功能开发中"; echo -n "按回车继续..."; read _ ;;
        esac
    done
}

show_minimal_arch() {
    while true; do
        clear
        show_header
        echo ""
        echo "【2 台服务器 | 最小生产架构】"
        echo "============================================================"
        echo " [1] 节点 A（总控机）  $(get_node_status node-a)"
        echo " [2] 节点 B（数据节点）  $(get_node_status node-b)"
        echo " [9] 返回"
        echo -n "请选择节点: "
        read -e -r OPT || true
        case "$OPT" in
            1) show_node_a ;;
            2) show_node_b ;;
            9) return ;;
            *) echo "[INFO] 无效选项"; echo -n "按回车继续..."; read _ ;;
        esac
    done
}

show_node_a() {
    while true; do
        clear
        show_header
        get_sys_info
        echo ""
        echo "节点 A（总控机）"
        echo "配置：CPU ${CPU_COUNT}核 | 内存 ${MEM_INFO} | 磁盘 ${DISK_INFO}"
        echo "============================================================"
        echo " [1] K3s 控制面"
        echo " [2] NetBird 控制端"
        echo " [3] Nginx 边缘网关"
        echo " [4] NewAPI 网关服务"
        echo " [5] 监控系统"
        echo " [9] 返回"
        echo -n "请选择: "
        read -e -r OPT || true
        case "$OPT" in
            [1-5]) echo "[OK] 安装功能开发中"; echo "${OPT}=installed" >> "${INVENTORY_DIR}/node-a.state"; echo -n "按回车继续..."; read _ ;;
            9) return ;;
            *) echo "[INFO] 无效选项"; echo -n "按回车继续..."; read _ ;;
        esac
    done
}

show_node_b() {
    while true; do
        clear
        show_header
        get_sys_info
        echo ""
        echo "节点 B（数据节点）"
        echo "配置：CPU ${CPU_COUNT}核 | 内存 ${MEM_INFO} | 磁盘 ${DISK_INFO}"
        echo "============================================================"
        echo " [1] MySQL 数据库"
        echo " [2] Redis 缓存"
        echo " [3] 自动备份服务"
        echo " [4] NetBird 客户端"
        echo " [9] 返回"
        echo -n "请选择: "
        read -e -r OPT || true
        case "$OPT" in
            [1-4]) echo "[OK] 安装功能开发中"; echo "${OPT}=installed" >> "${INVENTORY_DIR}/node-b.state"; echo -n "按回车继续..."; read _ ;;
            9) return ;;
            *) echo "[INFO] 无效选项"; echo -n "按回车继续..."; read _ ;;
        esac
    done
}

show_main_menu
SCRIPTEOF
    chmod +x scripts/main.sh
fi

# 执行脚本
exec bash scripts/main.sh
EOF
)
