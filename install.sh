#!/bin/sh

set -e

BOT_TOKEN="$1"
CHAT_ID="$2"

if [ -z "$BOT_TOKEN" ]; then
    printf "Masukkan BOT_TOKEN Telegram: "
    read BOT_TOKEN
fi

if [ -z "$CHAT_ID" ]; then
    printf "Masukkan CHAT_ID Telegram: "
    read CHAT_ID
fi

apt update -y
apt install curl -y

cat > /root/vps-alert.sh << EOF
#!/bin/sh

BOT_TOKEN="$BOT_TOKEN"
CHAT_ID="$CHAT_ID"

CPU_LIMIT=90
RAM_LIMIT=90
COOLDOWN=300
LOCK_FILE="/tmp/vps_alert.lock"

NOW=\$(date +%s)

if [ -f "\$LOCK_FILE" ]; then
    LAST=\$(cat "\$LOCK_FILE")
    DIFF=\$((NOW - LAST))
    [ "\$DIFF" -lt "\$COOLDOWN" ] && exit 0
fi

read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
CPU_TOTAL1=\$((user + nice + system + idle + iowait + irq + softirq + steal))
CPU_IDLE1=\$((idle + iowait))

sleep 1

read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
CPU_TOTAL2=\$((user + nice + system + idle + iowait + irq + softirq + steal))
CPU_IDLE2=\$((idle + iowait))

CPU_TOTAL=\$((CPU_TOTAL2 - CPU_TOTAL1))
CPU_IDLE=\$((CPU_IDLE2 - CPU_IDLE1))

if [ "\$CPU_TOTAL" -gt 0 ]; then
    CPU_USAGE=\$((100 * (CPU_TOTAL - CPU_IDLE) / CPU_TOTAL))
else
    CPU_USAGE=0
fi

MEM_TOTAL=\$(awk '/MemTotal/ {print \$2}' /proc/meminfo)
MEM_AVAILABLE=\$(awk '/MemAvailable/ {print \$2}' /proc/meminfo)
RAM_USAGE=\$((100 * (MEM_TOTAL - MEM_AVAILABLE) / MEM_TOTAL))

MESSAGE=""

[ "\$CPU_USAGE" -ge "\$CPU_LIMIT" ] && MESSAGE="\${MESSAGE}🚨 CPU tinggi: \${CPU_USAGE}%\\n"
[ "\$RAM_USAGE" -ge "\$RAM_LIMIT" ] && MESSAGE="\${MESSAGE}🚨 RAM tinggi: \${RAM_USAGE}%\\n"

if [ -n "\$MESSAGE" ]; then
    echo "\$NOW" > "\$LOCK_FILE"

    curl -s --max-time 10 -X POST "https://api.telegram.org/bot\$BOT_TOKEN/sendMessage" \\
        -d chat_id="\$CHAT_ID" \\
        --data-urlencode text="\$(printf "\$MESSAGE")" >/dev/null 2>&1
fi
EOF

chmod +x /root/vps-alert.sh

(crontab -l 2>/dev/null | grep -v "/root/vps-alert.sh"; echo "* * * * * /root/vps-alert.sh") | crontab -

if command -v systemctl >/dev/null 2>&1; then
    systemctl enable cron >/dev/null 2>&1 || true
    systemctl restart cron >/dev/null 2>&1 || systemctl restart crond >/dev/null 2>&1 || true
fi

/root/vps-alert.sh

echo "Install selesai."
echo "Script: /root/vps-alert.sh"
echo "Cron: aktif tiap 1 menit"