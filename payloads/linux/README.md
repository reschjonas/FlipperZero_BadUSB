# 🐧 Linux Payloads

> **Modular DuckyScript payloads for Linux systems**

---

## 📁 Categories

### 💾 Exfiltration (`exfiltration/`)

| Payload | Description | Config Required |
|---------|-------------|-----------------|
| `wifi_grabber.txt` | NetworkManager WiFi passwords | Discord webhook |
| `system_info.txt` | System information | Discord webhook |
| `ssh_keys.txt` | SSH keys & config | Discord webhook |
| `full_exfil.txt` | All exfil modules | Discord webhook |

### ⚙️ Execution (`execution/`)

| Payload | Description | Config Required |
|---------|-------------|-----------------|
| `reverse_shell.txt` | Bash/Python reverse shell | IP, Port |

### 🎪 Fun (`fun/`)

| Payload | Description | Config Required |
|---------|-------------|-----------------|
| `rickroll.txt` | Rick Roll | None |
| `wallpaper.txt` | Change wallpaper | Optional: image URL |
| `tts_message.txt` | Text to speech | Optional: message |

### 🔍 Recon (`recon/`)

| Payload | Description | Config Required |
|---------|-------------|-----------------|
| `full_recon.txt` | Full reconnaissance | Discord webhook |

### 🔒 Persistence (`persistence/`)

| Payload | Description | Config Required |
|---------|-------------|-----------------|
| `cron_backdoor.txt` | Cron-based persistence | IP, Port |

---

## 🖥️ Supported Distributions

| Distro | Support | Terminal Shortcut |
|--------|---------|-------------------|
| Ubuntu/Debian | ✅ Full | `CTRL ALT t` |
| Fedora/RHEL | ✅ Full | `CTRL ALT t` |
| Arch Linux | ✅ Full | `CTRL ALT t` |
| Linux Mint | ✅ Full | `CTRL ALT t` |
| Pop!_OS | ✅ Full | `CTRL ALT t` |

---

## 🔑 Requirements

- `curl` installed (usually default)
- Some payloads need `sudo` access
- Internet connection required

---

## ⚠️ Notes

- WiFi passwords may require root/sudo
- Some DEs may use different terminal shortcuts
- Test the terminal shortcut first!

