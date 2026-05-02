cat > ~/newapi-global-platform/newapi.sh << 'EOF'
#!/bin/bash
set -e

# 配置区（根据你的项目调整）
REPO_URL="https://github.com/cursor6525/newapi-global-platform.git"
CACHE_DIR="/tmp/newapi_cache_$(whoami)"
START_SCRIPT="start.sh"

# 优雅退出函数
cleanup() {
  echo -e "\n\033[33m[清理] 临时目录已保留在: $CACHE_DIR \033[0m"
  exit 0
}
trap cleanup INT TERM

# 1️⃣ 检测并更新仓库
if [ -d "$CACHE_DIR" ]; then
  echo -e "\033[36m[系统] 检测到本地缓存，尝试更新...\033[0m"
  cd "$CACHE_DIR" && git pull --quiet || echo -e "\033[33m[警告] 使用离线缓存\033[0m"
else
  echo -e "\033[36m[系统] 首次启动，克隆仓库中...\033[0m"
  git clone --depth 1 "$REPO_URL" "$CACHE_DIR"
fi

# 2️⃣ 自动修复（幂等操作，安全重复执行）
sed -i '/read -rp.*MAIN_OPT$/s/$/; MAIN_OPT=$(echo "$MAIN_OPT" | xargs)/' \
  "$CACHE_DIR/scripts/main.sh" 2>/dev/null || true

# 3️⃣ 启动中文界面
cd "$CACHE_DIR" && chmod +x "$START_SCRIPT" scripts/*.sh
echo -e "\n\033[32m[成功] 正在启动中文交互界面...\033[0m"
exec ./"$START_SCRIPT"
EOF
