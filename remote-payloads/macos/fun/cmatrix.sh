#!/bin/bash
# ============================================================
# CMatrix Effect for macOS - Modular Remote Payload
# ============================================================
# Creates Matrix-style falling text effect in Terminal
# ============================================================

SYSID=$(get_sysid)

# Check if cmatrix is installed
if command -v cmatrix &>/dev/null; then
    # Open Terminal with cmatrix
    osascript -e 'tell application "Terminal"
        activate
        do script "cmatrix -b -s"
    end tell'
    send_discord "🟢 **Matrix Rain on $SYSID** (cmatrix)"
else
    # Fallback: Pure bash matrix effect
    osascript -e 'tell application "Terminal"
        activate
        do script "while true; do echo -ne \"\\033[32m\$(cat /dev/urandom | LC_ALL=C tr -dc \"0-9a-zA-Z\" | head -c1)\"; done"
    end tell'
    send_discord "🟢 **Matrix Rain on $SYSID** (bash fallback)\nTip: \`brew install cmatrix\` for better effect"
fi

