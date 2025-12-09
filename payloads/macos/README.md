# 🍎 macOS Payloads

> **Modular DuckyScript payloads for macOS**

---

## 📁 Categories

### 💾 Exfiltration (`exfiltration/`)

| Payload | Description | Config Required |
|---------|-------------|-----------------|
| `wifi_grabber.txt` | Keychain WiFi passwords | Discord webhook |
| `system_info.txt` | System information | Discord webhook |

### ⚙️ Execution (`execution/`)

| Payload | Description | Config Required |
|---------|-------------|-----------------|
| `reverse_shell.txt` | Python/Ruby reverse shell | IP, Port |

### 🎪 Fun (`fun/`)

| Payload | Description | Config Required |
|---------|-------------|-----------------|
| `rickroll.txt` | Rick Roll | None |
| `tts_message.txt` | macOS 'say' command | Optional: message |

### 🔍 Recon (`recon/`)

| Payload | Description | Config Required |
|---------|-------------|-----------------|
| `full_recon.txt` | Full reconnaissance | Discord webhook |

---

## 🖥️ Supported Versions

| macOS | Support |
|-------|---------|
| Sonoma (14) | ✅ Full |
| Ventura (13) | ✅ Full |
| Monterey (12) | ✅ Full |
| Big Sur (11) | 🟡 Partial |

---

## 🎹 How It Works

All payloads use Spotlight to open Terminal:

```duckyscript
GUI SPACE          # Open Spotlight
STRING Terminal    # Type "Terminal"
ENTER              # Open Terminal
```

---

## 🛡️ macOS Security Notes

- **SIP** (System Integrity Protection) - Limits system modifications
- **Gatekeeper** - May block unsigned scripts
- **Keychain** - Prompts for password to access WiFi passwords
- **TCC** - Requires permissions for certain operations

---

## ⚠️ Notes

- WiFi passwords will prompt for Keychain access
- Some operations may require admin password
- SIP limits what can be modified

