# 📱 iOS Payloads

> **DuckyScript payloads for iPhone/iPad**

---

## ⚠️ Important Limitations

iOS is heavily sandboxed. BadUSB payloads **cannot**:

- ❌ Access the terminal
- ❌ Run shell commands
- ❌ Install apps
- ❌ Access the file system
- ❌ Be modular (no remote script loading)

iOS payloads **can**:

- ✅ Open apps via Spotlight
- ✅ Type text in any field
- ✅ Use keyboard shortcuts
- ✅ Open URLs in Safari
- ✅ Take screenshots (with external keyboard)

---

## 📋 Requirements

1. **Device must be UNLOCKED**
2. **USB device must be trusted** (user accepted "Trust This Computer")
3. **Screen must be on**

---

## 📁 Categories

### ⚙️ Execution (`execution/`)

| Payload | Description | Config Required |
|---------|-------------|-----------------|
| `open_url.txt` | Open URL in Safari | URL |
| `open_settings.txt` | Open Settings app | None |

### 🎭 Pranks (`pranks/`)

| Payload | Description | Config Required |
|---------|-------------|-----------------|
| `rickroll.txt` | Rick Roll | None |
| `send_message.txt` | Send iMessage | Phone, Message |
| `take_screenshot.txt` | Take screenshot | None |

---

## 🎹 iOS Keyboard Shortcuts

When Flipper connects as a keyboard:

| Shortcut | Action |
|----------|--------|
| `GUI SPACE` | Open Spotlight Search |
| `GUI l` | Focus Safari address bar |
| `GUI n` | New item |
| `GUI ENTER` | Send message |
| `GUI SHIFT 3` | Screenshot |
| `GUI h` | Go to Home |

---

## 📝 Example: Open a Website

```duckyscript
REM Open Safari and navigate to URL
DELAY 1000
GUI SPACE
DELAY 800
STRING Safari
DELAY 500
ENTER
DELAY 2000
GUI l
DELAY 500
STRING https://example.com
ENTER
```

---

## ⚠️ Notes

- iOS payloads are NOT modular
- All logic must be in the DuckyScript
- Limited compared to desktop payloads
- Great for demos and pranks

