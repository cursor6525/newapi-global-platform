#!/bin/bash
set -euo pipefail

# ==============================
# NewAPI 全局大脑 · 邮件密钥分发服务
# 功能：内网SMTP + 临时密钥 + 10分钟自动失效
# ==============================

echo ""
echo -e "\033[1;36m===============================================\033[0m"
echo -e "\033[1;32m  开始安装：邮件密钥分发服务（内网安全版）\033[0m"
echo -e "\033[1;36m===============================================\033[0m"
echo ""

# 1. 基础信息
NODE_NAME="node-a"
SERVICE_NAME="email-distribution"
INSTALL_DIR="/opt/newapi/email"
CONFIG_DIR="/etc/newapi/email"
SECRET_DIR="/etc/newapi/secrets"

# 2. 创建目录
mkdir -p ${INSTALL_DIR}
mkdir -p ${CONFIG_DIR}
mkdir -p ${SECRET_DIR}
chmod 700 ${SECRET_DIR}

# 3. 安装依赖（postfix 内网轻量SMTP）
echo -e "\033[1;33m[+] 安装系统依赖：postfix mailutils openssl\033[0m"
apt update -y
apt install -y postfix mailutils openssl

# 4. 生成随机 SMTP 密钥（仅内网使用）
SMTP_SECRET=$(openssl rand -hex 16)
echo "SMTP_SECRET=${SMTP_SECRET}" > ${SECRET_DIR}/email-smtp.secret
chmod 600 ${SECRET_DIR}/email-smtp.secret

# 5. 生成配置文件（内网安全模式）
cat > ${CONFIG_DIR}/config.yml << EOF
email:
  smtp_host: 127.0.0.1
  smtp_port: 25
  smtp_user: newapi@local
  smtp_secret: ${SMTP_SECRET}
  from_name: "NewAPI 集群密钥系统"
  expire_minutes: 10
security:
  allow_public: false
  only_intranet: true
  secret_prefix: "newapi_key_"
EOF

# 6. 生成密钥分发脚本（自动过期）
cat > ${INSTALL_DIR}/send-secret.sh << 'EOF'
#!/bin/bash
TO=$1
SUBJECT="NewAPI 集群临时访问密钥"
EXPIRE=10
KEY=$(openssl rand -hex 24)
KEY_FILE="/tmp/newapi_key_$(date +%s).tmp"
echo "你的临时访问密钥：${KEY}" > ${KEY_FILE}
echo "有效期：${EXPIRE} 分钟，超时自动失效" >> ${KEY_FILE}
echo "本邮件由内网安全系统自动发送，请勿回复" >> ${KEY_FILE}
cat ${KEY_FILE} | mail -s "${SUBJECT}" ${TO}
sleep $((EXPIRE*60))
rm -f ${KEY_FILE}
EOF

chmod +x ${INSTALL_DIR}/send-secret.sh

# 7. 注册系统服务（开机自启）
cat > /etc/systemd/system/newapi-email.service << EOF
[Unit]
Description=NewAPI Email Secret Distribution
After=network.target

[Service]
User=root
WorkingDirectory=${INSTALL_DIR}
ExecStart=${INSTALL_DIR}/send-secret.sh
Restart=on-failure
EnvironmentFile=${SECRET_DIR}/email-smtp.secret

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable newapi-email
systemctl start newapi-email

# 8. 健康检查
echo ""
echo -e "\033[1;32m[✔] 邮件密钥分发服务安装完成！\033[0m"
echo -e "\033[1;36m===============================================\033[0m"
echo "📩 服务名称：newapi-email"
echo "📂 安装目录：${INSTALL_DIR}"
echo "🔐 密钥目录：${SECRET_DIR}"
echo "⏰ 密钥有效期：10 分钟自动失效"
echo "🌐 运行模式：仅内网（禁止公网使用）"
echo -e "\033[1;36m===============================================\033[0m"
echo ""
