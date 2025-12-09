# 🪟 Windows Payloads

> **Modular DuckyScript payloads for Windows 10/11**

---

## 📁 Categories

### 💾 Exfiltration (`exfiltration/`)
**Danger Level:** 🔴 Critical

| Payload | Description | Config Required |
|---------|-------------|-----------------|
| `wifi_grabber.txt` | Extract WiFi passwords | Discord webhook |
| `screenshot.txt` | Capture screen | Discord webhook |
| `system_info.txt` | System information | Discord webhook |
| `browser_data.txt` | Browser history/data | Discord webhook |
| `ip_info.txt` | IP + geolocation | Discord webhook |
| `full_exfil.txt` | All of the above | Discord webhook |

### ⚙️ Execution (`execution/`)
**Danger Level:** 🔴 High

| Payload | Description | Config Required |
|---------|-------------|-----------------|
| `reverse_shell.txt` | PowerShell reverse shell | IP, Port, (Discord) |
| `create_admin.txt` | Hidden admin account | Discord webhook |
| `enable_rdp.txt` | Enable Remote Desktop | Discord webhook |
| `disable_defender.txt` | Disable Windows Defender | Discord webhook |
| `disable_firewall.txt` | Disable firewall | Discord webhook |

### 🎪 Fun (`fun/`)
**Danger Level:** 🟢 Low

| Payload | Description | Config Required |
|---------|-------------|-----------------|
| `rickroll.txt` | 🎵 Rick Roll | None (plug & play) |
| `fake_bsod.txt` | Fake Blue Screen | None (plug & play) |
| `wallpaper.txt` | Change wallpaper | Optional: image URL |
| `tts_message.txt` | Computer speaks | Optional: message |

### 🔍 Recon (`recon/`)
**Danger Level:** 🟡 Medium

| Payload | Description | Config Required |
|---------|-------------|-----------------|
| `full_recon.txt` | Full reconnaissance | Discord webhook |

### 🔒 Persistence (`persistence/`)
**Danger Level:** 🔴 Critical

| Payload | Description | Config Required |
|---------|-------------|-----------------|
| `persist.txt` | Multiple persistence methods | Discord webhook |

### ✅ GoodUSB (`goodusb/`)
**Danger Level:** 🟢 Safe

Helpful scripts for system maintenance:

| Payload | Description |
|---------|-------------|
| `activate_windows.txt` | Activate Windows |
| `win_debloater.txt` | Run debloater script |
| `disable_cortana.txt` | Disable Cortana |
| `remove_bloatware.txt` | Remove Windows bloat |

---

## ⚙️ Configuration

Replace these placeholders in the payload files:

```
YOUR_DISCORD_WEBHOOK → https://discord.com/api/webhooks/123/abc
YOUR_IP → 192.168.1.100
YOUR_PORT → 4444
```

---

## 🔑 Requirements

- **Most payloads:** No admin needed
- **Admin payloads:** Will show UAC prompt (user must click Yes)
- **Internet:** Required for all modular payloads

---

## ⚠️ Notes

- Defender may block some actions
- Tamper Protection must be OFF for defender disable
- Test in VM first!

