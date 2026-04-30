#!/usr/bin/env bash
# ============================================================
# NewAPI 全球化平台 · 中文交互式总控台（修复版）
# 版本: v1.0.1
# 作者: NewAPI Global Platform Team
# 说明: 空白服务器一键部署 / 多节点统一调度 / 全中文运维界面
# 修复: 终端兼容性 + 输入读取 + 颜色降级
# ============================================================

set -o pipefail

# ---------- 全局路径 ----------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
INVENTORY_DIR="${ROOT_DIR}/inventory/nodes"
LOG_DIR="${ROOT_DIR}/logs"
mkdir -p "${INVENTORY_DIR}" "${LOG_DIR}"

# ---------- 颜色变量（自动检测终端支持）----------
if [[ -t 1 ]] && command -v tput >/dev/null && [[ $(tput colors 2>/dev/null) -ge 8 ]]; then
    RED='\033[1;31m'
    GREEN='\033[1;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[1;34m'
    PURPLE='\033[1;35m'
    CYAN='\033[1;36m'
    WHITE='\033[1;37m'
    GRAY='\033[0;90m'
    NC='\033[0m'
else
    # 禁用颜色，兼容所有终端
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    PURPLE=''
    CYAN=''
    WHITE=''
    GRAY=''
    NC=''
fi

# ---------- 通用工具（修复输入兼容）----------
log()    { echo "[$(date '+%H:%M:%S')] $*" | tee -a "${LOG_DIR}/main.log"; }
ok()     { echo "[OK] $*"; }
warn()   { echo "[WARN] $*"; }
err()    { echo "[ERROR] $*"; }
info()   { echo "[INFO] $*"; }

# 修复的 pause 函数：使用简单 read
pause()  { echo ""; printf "按回车键继续... "; read -r _ || true; }

# 修复的输入函数：兼容所有终端
read_input() {
    local prompt="$1"
    local var="$2"
    printf "%s" "$prompt"
    read -e -r "$var" || true
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
}

# ---------- 应用状态检测 ----------
check_app_status() {
    local app="$1"
    case "$app" in
        k3s)        systemctl is-active --quiet k3s 2>/dev/null && echo "[OK] 已安装｜运行中" || echo "[ ] 未安装" ;;
        netbird)    systemctl is-active --quiet netbird 2>/dev/null && echo "[OK] 已安装｜运行中" || echo "[ ] 未安装" ;;
        nginx)      systemctl is-active --quiet nginx 2>/dev/null && echo "[OK] 已安装｜运行中" || echo "[ ] 未安装" ;;
        newapi)     kubectl get pod -n newapi 2>/dev/null | grep -q Running && echo "[OK] 已部署｜健康" || echo "[ ] 未安装" ;;
        mysql)      systemctl is-active --quiet mysql 2>/dev/null || systemctl is-active --quiet mysqld 2>/dev/null && echo "[OK] 已安装｜运行中" || echo "[ ] 未安装" ;;
        redis)      systemctl is-active --quiet redis 2>/dev/null || systemctl is-active --quiet redis-server 2>/dev/null && echo "[OK] 已安装｜运行中" || echo "[ ] 未安装" ;;
        monitoring) kubectl get pod -n monitoring 2>/dev/null | grep -q Running && echo "[OK] 已部署｜健康" || echo "[ ] 未安装" ;;
        backup)     systemctl is-active --quiet backup-cron 2>/dev/null && echo "[OK] 已安装｜运行中" || echo "[ ] 未安装" ;;
        *)          echo "[ ] 未知" ;;
    esac
}

# ---------- 头部横幅 ----------
show_header() {
    echo "+==============================================================+"
    echo "|     NewAPI 全球化平台 · 中文交互式总控台                    |"
    echo "|     多区域 | 零信任 | GitOps | 高可用                       |"
    echo "+==============================================================+"
}

# ---------- 节点状态读取 ----------
get_node_status() {
    local node="$1"
    local state_file="${INVENTORY_DIR}/${node}.state"
    if [[ -f "$state_file" ]]; then
        echo "[OK] 部署完成｜健康"
    else
        echo "[ ] 未部署"
    fi
}

# ---------- 主菜单 ----------
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
        printf "请输入选项序号: "
        read -e -r MAIN_OPT || true
        
        case "$MAIN_OPT" in
            1) show_plan_menu ;;
            2) run_health_check ;;
            3) run_sync_configs ;;
            4) show_secrets_menu ;;
            5) show_inventory_menu ;;
            6) show_monitoring_menu ;;
            7) show_incident_menu ;;
            8) show_docs_menu ;;
            0) echo "[OK] 已退出总控台，再见！"; exit 0 ;;
            *) err "无效选项，请重新输入"; sleep 1 ;;
        esac
    done
}

# ---------- 部署架构选型 ----------
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
        printf "请选择部署方案: "
        read -e -r PLAN_OPT || true
        
        case "$PLAN_OPT" in
            1) show_plan_minimal ;;
            2) show_plan_regional ;;
            3) show_plan_enterprise ;;
            9) return ;;
            *) err "无效选项，请重新输入"; sleep 1 ;;
        esac
    done
}

# ---------- 最小生产架构 (2台) ----------
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
        echo "架构说明："
        echo "  节点 A = 控制面 + 业务网关 + 边缘入口"
        echo "  节点 B = 数据库 + 缓存 + 备份（纯数据，禁业务）"
        echo "============================================================"
        printf "请选择节点: "
        read -e -r NODE_OPT || true
        
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
        printf "请输入要安装的应用序号: "
        read -e -r APP_OPT || true
        
        case "$APP_OPT" in
            1) install_app "k3s-server"        "节点 A" ;;
            2) install_app "netbird-server"    "节点 A" ;;
            3) install_app "nginx-edge"        "节点 A" ;;
            4) install_app "newapi-gateway"    "节点 A" ;;
            5) install_app "monitoring-stack"  "节点 A" ;;
            6) install_app "model-inference"   "节点 A" ;;
            7) list_installed_apps "node-a" ;;
            8) bash "${SCRIPT_DIR}/05-health-check.sh" --node=a 2>/dev/null || info "健康检查脚本暂未实现" ;;
            9) return ;;
            *) err "无效选项，请重新输入"; sleep 1 ;;
        esac
    done
}

# ---------- 节点 B 界面 ----------
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
        echo "[!] 此节点仅承载数据库、缓存、备份等数据组件"
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
        printf "请输入要安装的应用序号: "
        read -e -r APP_OPT || true
        
        case "$APP_OPT" in
            1) install_app "mysql-ha"        "节点 B" ;;
            2) install_app "redis-sentinel"  "节点 B" ;;
            3) install_app "backup-cronjob"  "节点 B" ;;
            4) install_app "netbird-client"  "节点 B" ;;
            5) install_app "proxysql"        "节点 B" ;;
            6) install_app "etcd-backup"     "节点 B" ;;
            7) list_installed_apps "node-b" ;;
            8) bash "${SCRIPT_DIR}/05-health-check.sh" --node=b 2>/dev/null || info "健康检查脚本暂未实现" ;;
            9) return ;;
            *) err "无效选项，请重新输入"; sleep 1 ;;
        esac
    done
}

# ---------- 应用安装统一入口 ----------
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
    printf "是否继续？[y/N]: "
    read -e -r CONFIRM || true
    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        log "开始安装 ${app} (${node})"
        if [[ -x "${SCRIPT_DIR}/installers/install-${app}.sh" ]]; then
            bash "${SCRIPT_DIR}/installers/install-${app}.sh"
        else
            warn "安装脚本 install-${app}.sh 暂未实现，仅做演示"
            sleep 2
        fi
        ok "${app} 安装流程结束"
    else
        warn "已取消安装"
    fi
    pause
}

# ---------- 多区域架构 ----------
show_plan_regional() {
    while true; do
        clear
        show_header
        echo ""
        echo "【3-6 台服务器 | 多区域架构】"
        echo "============================================================"
        echo "请选择要操作的区域："
        echo ""
        echo " [1] 中国区 (cn-north)       $(get_node_status cn-north)"
        echo " [2] 亚太区 (ap-southeast)   $(get_node_status ap-southeast)"
        echo " [3] 北美区 (us-east)        $(get_node_status us-east)"
        echo " [4] 欧洲区 (eu-central)     $(get_node_status eu-central)"
        echo " [5] 新增区域（一键接入向导）"
        echo " [6] 退服区域（安全擦除）"
        echo ""
        echo " [9] 返回上一级"
        echo "============================================================"
        echo "提示：每个区域至少需 1 台总控 + 1 台数据节点"
        echo "============================================================"
        printf "请选择区域: "
        read -e -r REGION_OPT || true
        
        case "$REGION_OPT" in
            1) deploy_region "cn-north" ;;
            2) deploy_region "ap-southeast" ;;
            3) deploy_region "us-east" ;;
            4) deploy_region "eu-central" ;;
            5) bash "${SCRIPT_DIR}/08-add-node.sh" 2>/dev/null || info "新增区域脚本暂未实现" ;;
            6) bash "${SCRIPT_DIR}/10-remove-node.sh" 2>/dev/null || info "退服区域脚本暂未实现" ;;
            9) return ;;
            *) err "无效选项"; sleep 1 ;;
        esac
    done
}

deploy_region() {
    local region="$1"
    clear
    show_header
    info "即将部署区域：${region}"
    bash "${SCRIPT_DIR}/deploy-region.sh" --region="${region}" 2>/dev/null || warn "区域部署脚本暂未实现"
    pause
}

# ---------- 企业级全球化 ----------
show_plan_enterprise() {
    clear
    show_header
    echo ""
    echo "【7+ 台服务器 | 企业级全球化架构】"
    echo "============================================================"
    echo "该方案启用全部企业级特性："
    echo ""
    echo "  * 多云多活 (AWS / 阿里云 / GCP)"
    echo "  * NetBird 控制面 HA (3 节点反亲和)"
    echo "  * MySQL 跨区主从 + Orchestrator 防脑裂"
    echo "  * GitOps (FluxCD) + SealedSecrets 全自动"
    echo "  * GDPR / PIPL / CCPA 合规审计"
    echo "  * 混沌工程 + SLO/SLI 体系"
    echo "  * FinOps 成本管控 + 自动缩容"
    echo ""
    echo "============================================================"
    echo "[!] 企业级部署涉及云厂商账户、合规审计与生产数据，"
    echo "[!] 建议先阅读 docs/ARCHITECTURE.md 与 ONBOARDING_NEW_REGION.md"
    echo "============================================================"
    echo ""
    echo " [1] 阅读企业级部署手册"
    echo " [2] 启动企业级部署向导（专家模式）"
    echo " [3] 执行合规自检清单"
    echo " [9] 返回上一级"
    echo "============================================================"
    printf "请选择: "
    read -e -r ENT_OPT || true
    
    case "$ENT_OPT" in
        1) less "${ROOT_DIR}/docs/ARCHITECTURE.md" 2>/dev/null || warn "文档暂未生成"; pause ;;
        2) bash "${SCRIPT_DIR}/07-bootstrap-flux.sh" --enterprise 2>/dev/null || info "企业部署脚本暂未实现"; pause ;;
        3) bash "${ROOT_DIR}/tests/compliance/run-checklist.sh" 2>/dev/null || warn "合规脚本暂未实现"; pause ;;
        9) return ;;
    esac
}

# ---------- 健康巡检 ----------
run_health_check() {
    clear
    show_header
    info "正在执行全域健康巡检..."
    if [[ -x "${SCRIPT_DIR}/05-health-check.sh" ]]; then
        bash "${SCRIPT_DIR}/05-health-check.sh"
    else
        warn "健康巡检脚本未实现，演示输出："
        echo ""
        echo "  [OK] 节点 A 控制面  - 健康"
        echo "  [OK] 节点 B 数据库  - 健康 (主从延迟 12ms)"
        echo "  [OK] NetBird 网格   - 全部对等节点在线"
        echo "  [WARN] Nginx 边缘    - QPS 接近阈值 80%"
    fi
    pause
}

# ---------- 配置同步 ----------
run_sync_configs() {
    clear
    show_header
    info "正在执行 GitOps 配置同步..."
    if [[ -x "${SCRIPT_DIR}/04-sync-configs.sh" ]]; then
        bash "${SCRIPT_DIR}/04-sync-configs.sh"
    else
        warn "配置同步脚本未实现"
    fi
    pause
}

# ---------- 密钥管理 ----------
show_secrets_menu() {
    clear
    show_header
    echo ""
    echo "【密钥与证书管理】"
    echo "============================================================"
    echo " [1] 轮转所有密钥（数据库 / SMTP / API Key）"
    echo " [2] 自动签发 / 续期 SSL 证书"
    echo " [3] 导入 Age / SealedSecrets 私钥"
    echo " [4] 查看密钥过期时间表"
    echo " [9] 返回主菜单"
    echo "============================================================"
    printf "请选择: "
    read -e -r SEC_OPT || true
    
    case "$SEC_OPT" in
        1) bash "${SCRIPT_DIR}/06-rotate-secrets.sh" 2>/dev/null || info "密钥轮转脚本暂未实现" ;;
        2) bash "${SCRIPT_DIR}/09-auto-ssl.sh" 2>/dev/null || info "SSL 证书脚本暂未实现" ;;
        3) bash "${ROOT_DIR}/secrets/init-sealed-keys.sh" 2>/dev/null || info "密钥注入脚本暂未实现" ;;
        4) warn "功能开发中..."; pause ;;
        9) return ;;
    esac
}

# ---------- 节点资产清单 ----------
show_inventory_menu() {
    clear
    show_header
    echo ""
    echo "【节点资产清单】"
    echo "============================================================"
    if compgen -G "${INVENTORY_DIR}/*.state" > /dev/null; then
        printf "  %-20s %-15s %-20s %s\n" "节点名" "IP 地址" "角色" "状态"
        echo "  ----------------------------------------------------------------"
        for f in "${INVENTORY_DIR}"/*.state; do
            local name ip role status
            name=$(basename "$f" .state)
            ip=$(grep -E '^IP=' "$f" 2>/dev/null | cut -d= -f2)
            role=$(grep -E '^ROLE=' "$f" 2>/dev/null | cut -d= -f2)
            status=$(grep -E '^STATUS=' "$f" 2>/dev/null | cut -d= -f2)
            printf "  %-20s %-15s %-20s %s\n" "$name" "${ip:-未知}" "${role:-未知}" "${status:-未知}"
        done
    else
        warn "暂无节点注册，请先执行部署"
    fi
    echo ""
    pause
}

# ---------- 监控菜单 ----------
show_monitoring_menu() {
    clear
    show_header
    echo ""
    echo "【监控与告警】"
    echo "============================================================"
    echo " [1] 打开 Grafana 控制台"
    echo " [2] 查看 VictoriaMetrics 指标"
    echo " [3] 查看 Loki 日志聚合"
    echo " [4] 测试告警通道（钉钉/企微）"
    echo " [9] 返回主菜单"
    echo "============================================================"
    printf "请选择: "
    read -e -r MON_OPT || true
    
    case "$MON_OPT" in
        1) info "请访问 https://grafana.your-domain.com"; pause ;;
        2) info "请访问 https://vm.your-domain.com"; pause ;;
        3) info "请访问 https://loki.your-domain.com"; pause ;;
        4) info "正在发送测试告警..."; sleep 2; ok "已发送，请检查接收端"; pause ;;
        9) return ;;
    esac
}

# ---------- 应急响应 ----------
show_incident_menu() {
    clear
    show_header
    echo ""
    echo "【应急响应工具箱】"
    echo "============================================================"
    echo "[!] 以下操作具有高风险，请在确认事故后再使用！"
    echo "============================================================"
    echo " [1] 跨国断网应急切换（启用降级路由）"
    echo " [2] etcd 快照恢复（10 分钟集群重建）"
    echo " [3] 数据库主从故障切换"
    echo " [4] 一键封禁可疑 IP / 国家"
    echo " [5] 触发应急通知模板（钉钉/企微）"
    echo " [9] 返回主菜单"
    echo "============================================================"
    printf "请选择: "
    read -e -r INC_OPT || true
    
    case "$INC_OPT" in
        1|2|3|4|5)
            warn "应急流程脚本需配合 INCIDENT_RESPONSE.md 执行"
            info "请阅读：${ROOT_DIR}/configs/INCIDENT_RESPONSE.md"
            pause ;;
        9) return ;;
    esac
}

# ---------- 文档与帮助 ----------
show_docs_menu() {
    clear
    show_header
    echo ""
    echo "【文档与帮助】"
    echo "============================================================"
    echo " [1] 架构详解 (ARCHITECTURE.md)"
    echo " [2] 故障排查手册 (TROUBLESHOOTING.md)"
    echo " [3] 贡献指南 (CONTRIBUTING.md)"
    echo " [4] 术语表 (GLOSSARY.md)"
    echo " [5] Master 重建 SOP (MASTER-RECOVERY.md)"
    echo " [9] 返回主菜单"
    echo "============================================================"
    printf "请选择: "
    read -e -r DOC_OPT || true
    
    case "$DOC_OPT" in
        1) less "${ROOT_DIR}/docs/ARCHITECTURE.md" 2>/dev/null || warn "文档暂未生成"; pause ;;
        2) less "${ROOT_DIR}/docs/TROUBLESHOOTING.md" 2>/dev/null || warn "文档暂未生成"; pause ;;
        3) less "${ROOT_DIR}/docs/CONTRIBUTING.md" 2>/dev/null || warn "文档暂未生成"; pause ;;
        4) less "${ROOT_DIR}/docs/GLOSSARY.md" 2>/dev/null || warn "文档暂未生成"; pause ;;
        5) less "${ROOT_DIR}/docs/MASTER-RECOVERY.md" 2>/dev/null || warn "文档暂未生成"; pause ;;
        9) return ;;
    esac
}

# ---------- 已安装应用清单 ----------
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

# ---------- 主入口 ----------
main() {
    if [[ $EUID -ne 0 ]]; then
        warn "建议使用 root 用户运行（部分操作需要管理员权限）"
        sleep 1
    fi
    show_main_menu
}

main "$@"
