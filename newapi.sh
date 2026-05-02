#!/bin/bash
# ==================================================================
# ✅ NewAPI 单文件启动器｜v1.0（专为 scripts/main.sh 设计）
# ⚡ 无需克隆仓库｜自动缓存｜智能修复｜秒启中文界面
# ==================================================================
set -e

# —— 配置区（按需修改）——
REPO_URL="https://github.com/cursor6525/newapi-global-platform.git"
CACHE_DIR="/tmp/newapi_$(id -u)_$(date +%s)"  # 每次唯一，避免冲突
MAIN_SCRIPT="scripts/main.sh"

# —— 彩色日志 ——
RED='\033[1;31m' GREEN='\033[1;32m' YELLOW='\033[1;33m' BLUE='\033[1;34m' NC='\033[0m'
log() { echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $*" >&2; }
ok()  { echo -e "${GREEN}✅ $*${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $*${NC}"; }

# —— 清理函数（优雅退出）——
cleanup() {
  [ -d "$CACHE_DIR" ] && rm -rf "$CACHE_DIR"
}
trap cleanup EXIT INT TERM

# —— 步骤 1：获取代码（优先用缓存，失败则克隆）——
if [ -d "$CACHE_DIR" ] && [ -f "$CACHE_DIR/$MAIN_SCRIPT" ]; then
  log "使用本地缓存: $CACHE_DIR"
else
  log "正在克隆仓库..."
  git clone --depth 1 "$REPO_URL" "$CACHE_DIR" 2>/dev/null || {
    warn "❌ 克隆失败！尝试从缓存恢复..."
    if [ -d "/tmp/newapi_$(id -u)_"* ]; then
      CACHE_DIR=$(ls -td /tmp/newapi_$(id -u)_* | head -n1)
      log "✅ 使用最近缓存: $CACHE_DIR"
    else
      err "网络不可用且无缓存，请检查网络或手动克隆"
      exit 1
    fi
  }
fi

# —— 步骤 2：自动修复 MAIN_OPT 空格问题（精准匹配你当前的 read 行）——
MAIN_SH="$CACHE_DIR/$MAIN_SCRIPT"
if grep -q "read -rp.*MAIN_OPT" "$MAIN_SH"; then
  # ✅ 精准修复：在 read 行末追加去空格逻辑（不破坏缩进/注释/多行）
  sed -i '/read -rp.*MAIN_OPT/s/$/; MAIN_OPT=\$(echo "\$MAIN_OPT" | xargs)/' "$MAIN_SH"
  ok "已启用输入空格兼容：' 1'、'1 '、'  1  ' 均可识别"
else
  warn "⚠️  未找到 MAIN_OPT 输入行（可能已修复）"
fi

# —— 步骤 3：授权并启动（保持原始交互体验）——
chmod +x "$CACHE_DIR/start.sh" "$CACHE_DIR/scripts/"*.sh 2>/dev/null || true
log "正在启动中文总控台..."
exec "$CACHE_DIR/start.sh"
