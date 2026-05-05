#!/bin/bash
set -euo pipefail
echo "====================================="
echo "💾 安装自动备份任务（双兼容）"
echo "====================================="

mkdir -p /backup
chmod 700 /backup

cat > /backup/mysql-backup.sh <<EOF
#!/bin/bash
docker exec mysql-ha mysqldump -uroot -pNewAPI@2025 --all-databases | gzip > /backup/all-\$(date +%Y%m%d).sql.gz
find /backup -mtime +7 -delete
EOF

chmod +x /backup/mysql-backup.sh

# 双兼容添加定时任务
if command -v crontab &>/dev/null; then
  (crontab -l 2>/dev/null | grep -v mysql-backup; echo "0 2 * * * /backup/mysql-backup.sh") | crontab -
  echo "✅ 每日 2 点自动备份已配置"
else
  echo "⚠️  无 crontab，已生成备份脚本：/backup/mysql-backup.sh"
fi
