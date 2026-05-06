#!/bin/bash
set -euo pipefail
echo "==============================================="
echo "  开始安装：邮件密钥分发服务（内网安全版）"
echo "==============================================="

echo "[+] 安装系统依赖：postfix mailutils openssl"

# 🔥 关键：无交互安装，不弹出任何配置窗口
export DEBIAN_FRONTEND=noninteractive

apt update -y
apt install -y -q postfix mailutils openssl

# 自动配置为本地邮件（不对外，安全）
cat > /etc/postfix/main.cf <<EOF
smtpd_banner = \$myhostname ESMTP
biff = no
append_dot_mydomain = no
readme_directory = no
compatibility_level = 3.6
myhostname = localhost
mydomain = localdomain
myorigin = /etc/mailname
mydestination = \$myhostname, localhost.\$mydomain, localhost
relayhost =
mynetworks = 127.0.0.0/8 [::1]/128
mailbox_size_limit = 0
recipient_delimiter = +
inet_interfaces = loopback-only
inet_protocols = ipv4
EOF

# 重启生效
systemctl restart postfix
sleep 2

# 验证
if systemctl is-active --quiet postfix; then
  echo "✅ postfix 邮件服务启动成功"
else
  echo "❌ postfix 启动失败"
  exit 1
fi

echo "✅ 邮件服务安装完成（本地安全模式，无外网访问）"
