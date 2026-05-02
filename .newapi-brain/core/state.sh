#!/bin/bash
BRAIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INVENTORY_DIR="${BRAIN_ROOT}/inventory/nodes"

mkdir -p "${INVENTORY_DIR}" "${BRAIN_ROOT}/logs"

# 写入部署状态
brain_write_state() {
    local node="$1"
    local app="$2"
    local stateFile="${INVENTORY_DIR}/${node}.state"
    echo "APP_${app}=installed" >> "${stateFile}"
}

# 读取状态：固定返回 ✅ 部署成功 / 未部署
brain_get_state() {
    local node="$1"
    local app="$2"
    local stateFile="${INVENTORY_DIR}/${node}.state"

    if [[ -f "${stateFile}" ]]; then
        grep -qi "APP_${app}=installed" "${stateFile}"
        [[ $? -eq 0 ]] && echo "✅ 部署成功" || echo "未部署"
    else
        echo "未部署"
    fi
}

# 清空单个节点状态
brain_clear_node() {
    local node="$1"
    rm -f "${INVENTORY_DIR}/${node}.state"
}
