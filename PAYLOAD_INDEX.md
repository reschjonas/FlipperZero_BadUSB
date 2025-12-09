# 📋 Payload Index

> **Complete list of all payloads with configuration requirements**

---

## 🎯 Quick Legend

| Symbol | Meaning |
|--------|---------|
| ✅ | **PLUG & PLAY** - Works immediately, no changes needed |
| ⚙️ | **NEEDS CONFIG** - Requires user input before use |
| 🔴 | Critical/Dangerous |
| 🟡 | Moderate risk |
| 🟢 | Safe/Fun |

---

## 🪟 Windows Payloads

### ✅ Plug & Play (Ready to Use)

#### ASCII Art 🟢
| Payload | Description |
|---------|-------------|
| `ASCII/Selfwriting/AnonymousASCII.txt` | Types Anonymous mask in Notepad |
| `ASCII/Selfwriting/Hacked.txt` | Types "HACKED" message |
| `ASCII/Selfwriting/MonaLisa.txt` | Types Mona Lisa art |
| `ASCII/Selfwriting/PepeThonkASCII.txt` | Types thinking Pepe |
| `ASCII/Selfwriting/PepeWowASCII.txt` | Types surprised Pepe |
| `ASCII/Selfwriting/RickRoll.txt` | Types Rick Astley |
| `ASCII/Selfwriting/SimpleTroll.txt` | Types troll message |
| `ASCII/DownLoadAscii/*.txt` | Various downloadable ASCII art |

#### FUN 🟢🟡
| Payload | Description |
|---------|-------------|
| `FUN/FakeBluescreen/FakeBluescreen.txt` | Opens fake BSOD website |
| `FUN/FakeUpdateWindows/FakeUpdateWindows.txt` | Fake Windows update |
| `FUN/FakeVirus/FakeVirus.txt` | Fake virus popup |
| `FUN/ComputerTalks/ComputerTalks.txt` | Text-to-speech message |
| `FUN/Matrix_Rain_CMD/Matrix_Rain_CMD.txt` | Matrix effect in CMD |
| `FUN/Cartman/Cartman.txt` | Cartman soundboard |
| `FUN/NoMoreSound/NoMoreSound.txt` | Mutes system |
| `FUN/justdance/justdance.txt` | Opens Just Dance |

#### GoodUSB 🟢
| Payload | Description |
|---------|-------------|
| `GoodUSB/Clear_Explorer/clear_explorer.txt` | Clear File Explorer history |
| `GoodUSB/Disable_Cortana/disable_cortana.txt` | Disable Cortana |
| `GoodUSB/Enable_Cortana/enable_cortana.txt` | Re-enable Cortana |
| `GoodUSB/Bloatware_removal/bloatware_remover.txt` | Remove Windows bloat |
| `GoodUSB/OneDrive_Removal/uninstall_onedrive.txt` | Uninstall OneDrive |
| `GoodUSB/Privacy_Windows/privacy.txt` | Privacy settings |
| `GoodUSB/Activate_Windows/activate_windows.txt` | Activate Windows |

#### Reconnaissance 🟢
| Payload | Description |
|---------|-------------|
| `Exfiltration/General_PC_Information/*.txt` | System info gathering |
| `Exfiltration/ListWindowsUpdates/*.txt` | List updates |
| `Exfiltration/USB_And_Harddrive_Information/*.txt` | Drive info |
| `Exfiltration/Win_User_Info/*.txt` | User info |

---

### ⚙️ Needs Configuration

#### 🔴 Requires: `ATTACKER_IP` + `ATTACKER_PORT`
*For reverse shell connections - you need to set up a listener*

| Payload | Also Needs |
|---------|------------|
| `Execution/powershell_reverse_shell.txt` | - |
| `Windows_Badusb/Remote-Access/ReversePowershell/*.txt` | - |
| `Windows_Badusb/Remote-Access/CommandLineBackdoor/*.txt` | - |

**Setup:**
```bash
# On your attack machine:
nc -lvnp 4444
# Then configure payload with your IP
```

---

#### 🔴 Requires: `DISCORD_WEBHOOK_URL`
*For exfiltrating data to Discord*

| Payload | Description |
|---------|-------------|
| `Windows_Badusb/PasswordStuff/StealWifiKeys_Discord/*.txt` | WiFi passwords → Discord |
| `Windows_Badusb/PasswordStuff/ChromePasswords/*.txt` | Chrome passwords → Discord |
| `Exfiltration/IP_To_Discord/*.txt` | IP + WiFi → Discord |

**Setup:**
1. Create Discord server
2. Server Settings → Integrations → Webhooks
3. Create webhook, copy URL
4. Paste URL in payload

---

#### 🔴 Requires: `PAYLOAD_URL`
*For downloading and executing remote payloads*

| Payload | Description |
|---------|-------------|
| `Execution/DownloadAnyEXE/*.txt` | Download & run EXE |
| `Execution/Invisible_DownExec/*.txt` | Hidden download & execute |
| `Execution/Invisible_DownExec_Zip_Extract/*.txt` | Download ZIP, extract, run |
| `Execution/amsi_bypass_execute.txt` | AMSI bypass + execute |
| `GoodUSB/Win_Debloater/*.txt` | Download debloat script |
| `Persistence/scheduled_task.txt` | Persistent payload |
| `Persistence/startup_folder.txt` | Startup persistence |

**Setup:**
```bash
# Host your payload:
python3 -m http.server 8080
# Payload URL: http://YOUR_IP:8080/payload.ps1
```

---

#### 🟡 Requires: `USERNAME` + `PASSWORD`
*For creating backdoor accounts*

| Payload | Description |
|---------|-------------|
| `Execution/Create_New_Windows_Admin/*.txt` | Create admin account |
| `Execution/setWinPass/*.txt` | Change password |
| `Execution/ChangeWinUsername/*.txt` | Change username |

---

#### 🟡 Requires: Custom Values

| Payload | Requires | Description |
|---------|----------|-------------|
| `Execution/DNS_Cache_Poison/*.txt` | Domain + IP | Redirect domains |
| `Execution/OpenAnyPort/*.txt` | Port number | Open firewall port |
| `Execution/StartWifiAccessPoint/*.txt` | SSID + Password | Create hotspot |
| `Exfiltration/Keylogger/*.txt` | Keylogger URL | Install keylogger |

---

## 🐧 Linux Payloads

### ✅ Plug & Play

| Payload | Description | Risk |
|---------|-------------|------|
| `Reconnaissance/system_info.txt` | System information | 🟢 |
| `Reconnaissance/network_scan.txt` | Network scanning | 🟢 |
| `Reconnaissance/browser_history.txt` | Browser history | 🟡 |
| `Reconnaissance/installed_software.txt` | List packages | 🟢 |
| `Exfiltration/clipboard_dump.txt` | Clipboard contents | 🟡 |
| `Exfiltration/env_variables.txt` | Environment vars | 🟡 |
| `Exfiltration/ssh_keys.txt` | SSH keys (public) | 🟡 |
| `Exfiltration/wifi_passwords.txt` | WiFi passwords (needs sudo) | 🔴 |
| `FUN/rick_roll.txt` | Rick Roll | 🟢 |
| `FUN/wallpaper_change.txt` | Change wallpaper | 🟢 |
| `FUN/cmatrix.txt` | Matrix effect | 🟢 |
| `FUN/espeak_message.txt` | Text-to-speech | 🟢 |
| `FUN/fork_bomb.txt` | ⚠️ CRASHES SYSTEM | 🔴 |

### ⚙️ Needs Configuration

| Payload | Requires | Risk |
|---------|----------|------|
| `Execution/reverse_shell.txt` | `ATTACKER_IP` | 🔴 |
| `Execution/netcat_reverse.txt` | `ATTACKER_IP` | 🔴 |
| `Execution/download_execute.txt` | `PAYLOAD_URL` | 🔴 |
| `Persistence/ssh_backdoor.txt` | `SSH_PUBLIC_KEY` | 🔴 |
| `Persistence/cron_backdoor.txt` | `ATTACKER_IP` | 🔴 |

---

## 🍎 macOS Payloads

### ✅ Plug & Play

| Payload | Description | Risk |
|---------|-------------|------|
| `Reconnaissance/system_info.txt` | System information | 🟢 |
| `Reconnaissance/network_info.txt` | Network info | 🟢 |
| `Reconnaissance/browser_history.txt` | Safari/Chrome history | 🟡 |
| `Reconnaissance/installed_apps.txt` | List applications | 🟢 |
| `Exfiltration/clipboard_dump.txt` | Clipboard contents | 🟡 |
| `Exfiltration/ssh_keys.txt` | SSH keys | 🟡 |
| `Exfiltration/keychain_dump.txt` | List Keychain items | 🟡 |
| `Exfiltration/wifi_passwords.txt` | WiFi passwords | 🔴 |
| `FUN/rick_roll.txt` | Rick Roll | 🟢 |
| `FUN/say_hello.txt` | Text-to-speech | 🟢 |
| `FUN/notification_spam.txt` | Show notification | 🟢 |
| `FUN/volume_max.txt` | Max volume | 🟢 |
| `FUN/screensaver.txt` | Start screensaver | 🟢 |

### ⚙️ Needs Configuration

| Payload | Requires | Risk |
|---------|----------|------|
| `Execution/reverse_shell.txt` | `ATTACKER_IP` | 🔴 |
| `Execution/bash_reverse_shell.txt` | `ATTACKER_IP` | 🔴 |
| `Execution/download_execute.txt` | `PAYLOAD_URL` | 🔴 |
| `Execution/osascript_shell.txt` | `PAYLOAD_URL` | 🔴 |
| `Persistence/launch_agent.txt` | `PAYLOAD_URL` | 🔴 |

---

## 📱 iPhone Payloads

### ✅ Plug & Play

| Payload | Description | Risk |
|---------|-------------|------|
| `Pranks/rick_roll.txt` | Open Rick Roll | 🟢 |
| `Pranks/open_camera.txt` | Open Camera | 🟢 |
| `Pranks/set_alarm.txt` | Open Clock | 🟢 |
| `Execution/open_settings.txt` | Open Settings | 🟢 |
| `Exfiltration/take_screenshot.txt` | Take screenshot | 🟢 |
| `open-website/iPhone_open_website.txt` | Open Safari | 🟢 |

### ⚙️ Needs Configuration

| Payload | Requires | Risk |
|---------|----------|------|
| `Pranks/send_message.txt` | `PHONE_NUMBER` | 🟡 |
| `Execution/open_notes.txt` | Custom message | 🟢 |
| `Execution/open_url_shortcut.txt` | `URL` | 🟢 |

---

## 🔧 How To Configure Payloads

> **Just edit the file and copy to Flipper!** No tools needed.

### Step-by-Step

1. **Open** the `.txt` file in any text editor
2. **Find** the placeholder (e.g., `ATTACKER_IP`)  
3. **Replace** with your value (e.g., `192.168.1.100`)
4. **Save** the file
5. **Copy** to Flipper Zero (`SD Card → badusb/`)
6. **Run** from Flipper!

---

## 📝 Configuration Values

### `ATTACKER_IP` - Your IP Address

Find your IP:
```bash
ip addr          # Linux
ifconfig         # macOS  
ipconfig         # Windows
```
Replace `ATTACKER_IP` → `192.168.1.100` (your actual IP)

Also start a listener: `nc -lvnp 4444`

### `DISCORD_WEBHOOK_URL` - Discord Webhook

1. Discord → Server Settings → Integrations → Webhooks
2. New Webhook → Copy URL
3. Replace `DISCORD_WEBHOOK_URL` → paste the URL

### `PAYLOAD_URL` - URL to Your Payload

Host a file:
```bash
python3 -m http.server 8080
```
Replace `PAYLOAD_URL` → `http://YOUR_IP:8080/script.ps1`

---

## 🔧 Optional: Configurator Tool

*If you prefer a guided setup:*

```bash
python3 tools/payload_configurator.py
```

> **Note:** This tool is optional! Most users just edit files directly.

---

**Last Updated**: December 2025

