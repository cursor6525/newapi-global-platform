#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/state.sh"

# 全局服务总览看板
brain_show_global_table() {
    echo ""
    echo "【📊 全局服务部署总览｜NEWAPI全局大脑数据看板】"
    echo "======================================================================"
    printf "%-8s %-8s %-8s %-8s %-10s %-8s %-8s\n" "节点" "K3s" "NetBird" "Nginx" "NewAPI" "MySQL" "Redis"
    echo "----------------------------------------------------------------------"

    printf "节点A   %-8s %-8s %-8s %-10s %-8s %-8s\n" \
    $(brain_get_state node-a k3s) $(brain_get_state node-a netbird) $(brain_get_state node-a nginx) \
    $(brain_get_state node-a newapi) $(brain_get_state node-a mysql) $(brain_get_state node-a redis)

    printf "节点B   %-8s %-8s %-8s %-10s %-8s %-8s\n" \
    $(brain_get_state node-b k3s) $(brain_get_state node-b netbird) $(brain_get_state node-b nginx) \
    $(brain_get_state node-b newapi) $(brain_get_state node-b mysql) $(brain_get_state node-b redis)

    printf "节点C   %-8s %-8s %-8s %-10s %-8s %-8s\n" \
    $(brain_get_state node-c k3s) $(brain_get_state node-c netbird) $(brain_get_state node-c nginx) \
    $(brain_get_state node-c newapi) $(brain_get_state node-c mysql) $(brain_get_state node-c redis)

    printf "节点D   %-8s %-8s %-8s %-10s %-8s %-8s\n" \
    $(brain_get_state node-d k3s) $(brain_get_state node-d netbird) $(brain_get_state node-d nginx) \
    $(brain_get_state node-d newapi) $(brain_get_state node-d mysql) $(brain_get_state node-d redis)

    printf "节点E   %-8s %-8s %-8s %-10s %-8s %-8s\n" \
    $(brain_get_state node-e k3s) $(brain_get_state node-e netbird) $(brain_get_state node-e nginx) \
    $(brain_get_state node-e newapi) $(brain_get_state node-e mysql) $(brain_get_state node-e redis)

    printf "节点F   %-8s %-8s %-8s %-10s %-8s %-8s\n" \
    $(brain_get_state node-f k3s) $(brain_get_state node-f netbird) $(brain_get_state node-f nginx) \
    $(brain_get_state node-f newapi) $(brain_get_state node-f mysql) $(brain_get_state node-f redis)

    printf "节点G   %-8s %-8s %-8s %-10s %-8s %-8s\n" \
    $(brain_get_state node-g k3s) $(brain_get_state node-g netbird) $(brain_get_state node-g nginx) \
    $(brain_get_state node-g newapi) $(brain_get_state node-g mysql) $(brain_get_state node-g redis)

    echo "======================================================================"
    echo "说明：✅部署成功 | 未部署 | 数据源：.newapi-brain 全局大脑"
}
