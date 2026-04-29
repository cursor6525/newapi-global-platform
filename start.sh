#!/usr/bin/env bash
# 🚀 start.sh | NewAPI 总控台一键启动器
set -euo pipefail

REPO="${REPO:-cursor6525/newapi-global-platform}"
BRANCH="${BRANCH:-main}"
TARGET_DIR="${TARGET_DIR:-/opt/newapi-global-platform}"

echo -e "\033[1;36m🚀 正在初始化 NewAPI 总控台...\033[0m"

# 检查并安装基础依赖
command -v git >/dev/null || { echo "📦 安装 Git..."; apt update && apt install -y git curl; }

# 创建目标目录
mkdir -p "${TARGET_DIR}"
cd "${TARGET_DIR}"

# 克隆或更新代码
if [[ ! -d ".git" ]]; then
    echo "📥 首次拉取代码库..."
    git init -q
    git remote add origin "https://github.com/${REPO}.git"
    git fetch -q origin "${BRANCH}"
    git checkout -q -f "origin/${BRANCH}"
else
    echo "🔄 更新代码库..."
    git fetch -q origin "${BRANCH}"
    git checkout -q -f "origin/${BRANCH}"
fi

# 初始化运行时目录
mkdir -p inventory/nodes logs scripts/installers

# 赋予执行权限
chmod +x scripts/*.sh 2>/dev/null || true

# 启动中文交互式总控台
echo -e "\033[1;32m✅ 环境就绪，启动中文交互式总控台...\033[0m"
exec bash scripts/main.sh
