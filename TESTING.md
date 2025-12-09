# 🧪 Testing Guide

> **Test safely, test smart, test ethically.**

This guide covers everything you need to test BadUSB payloads without a Flipper Zero device and best practices for safe testing.

---

## 📋 Table of Contents

- [Testing Without Hardware](#-testing-without-hardware)
- [Virtual Machine Setup](#-virtual-machine-setup)
- [DuckyScript Validator](#-duckyscript-validator)
- [Testing Best Practices](#-testing-best-practices)
- [Troubleshooting](#-troubleshooting)
- [Script Categories by Risk](#-script-categories-by-risk)

---

## 🖥️ Testing Without Hardware

You don't need a Flipper Zero to test and validate your scripts! Here are several methods:

### Method 1: Quackinter (Recommended)

**Quackinter** is a Python-based DuckyScript 1.0 interpreter that executes scripts directly on your computer.

```bash
# Install Quackinter
pip install quackinter

# Run a script
quackinter your_script.txt
```

⚠️ **Warning**: This will actually execute the keystrokes on YOUR computer. Use with caution!

### Method 2: DuckyScript Validator (Safe - Syntax Only)

Use our custom validator to check syntax without execution:

```bash
# Install dependencies
pip install -r tools/requirements.txt

# Validate a single script
python tools/validate_ducky.py BadUSB-Scripts/Windows_BadUSB/FUN/FakeBluescreen/FakeBluescreen.txt

# Validate all scripts
python tools/validate_ducky.py --all
```

### Method 3: Manual Review + VM Execution

1. Read and understand the script
2. Set up an isolated VM
3. Manually type the commands to see what happens
4. Or use a USB Rubber Ducky / Flipper Zero connected to VM

---

## 🖥️ Virtual Machine Setup

**ALWAYS test potentially dangerous scripts in an isolated virtual machine!**

### Recommended Platforms

| Platform | Free? | Best For |
|----------|-------|----------|
| **VirtualBox** | ✅ Yes | Beginners, cross-platform |
| **VMware Workstation Player** | ✅ Yes | Better USB pass-through |
| **Hyper-V** | ✅ Built-in | Windows Pro/Enterprise users |
| **QEMU/KVM** | ✅ Yes | Linux users, advanced |

### Quick VirtualBox Setup

```bash
# Ubuntu/Debian
sudo apt install virtualbox virtualbox-ext-pack

# Fedora
sudo dnf install VirtualBox

# macOS (via Homebrew)
brew install --cask virtualbox
```

### Windows VM Configuration

1. **Download Windows ISO**: [Microsoft Evaluation Center](https://www.microsoft.com/en-us/evalcenter/)
2. **Create VM**:
   - RAM: 4GB minimum (8GB recommended)
   - Storage: 50GB dynamic
   - Enable USB 2.0/3.0 controller
3. **Install VirtualBox Guest Additions** for better USB support
4. **Take a snapshot** before any testing

### USB Pass-through Setup

To test with actual BadUSB hardware in a VM:

```bash
# Add your user to vboxusers group (Linux)
sudo usermod -aG vboxusers $USER

# Log out and back in, then:
# VirtualBox → Settings → USB → Add Filter → Select Flipper Zero
```

---

## ✅ DuckyScript Validator

Our custom validator checks your scripts for:

- ✅ Valid DuckyScript 1.0 syntax
- ✅ Proper command formatting
- ✅ Common mistakes and typos
- ✅ Flipper Zero compatibility

### Valid DuckyScript 1.0 Commands

```
REM           - Comment
DELAY xxx     - Wait xxx milliseconds
STRING xxx    - Type the string xxx
ENTER         - Press Enter key
GUI/WINDOWS   - Windows/Super key
CTRL          - Control key
ALT           - Alt key
SHIFT         - Shift key
TAB           - Tab key
ESCAPE/ESC    - Escape key
SPACE         - Space bar
CAPSLOCK      - Caps Lock
NUMLOCK       - Num Lock
SCROLLLOCK    - Scroll Lock
PRINTSCREEN   - Print Screen
PAUSE         - Pause/Break
BREAK         - Break key
INSERT        - Insert key
DELETE        - Delete key
HOME          - Home key
END           - End key
PAGEUP        - Page Up
PAGEDOWN      - Page Down
UP/DOWN/LEFT/RIGHT    - Arrow keys
UPARROW/DOWNARROW/LEFTARROW/RIGHTARROW - Arrow keys (alternate)
F1-F12        - Function keys
MENU/APP      - Application/Menu key
```

### Key Combinations

```duckyscript
REM Single modifier + key
CTRL c
ALT F4
GUI r
SHIFT TAB

REM Multiple modifiers + key  
CTRL SHIFT ENTER
CTRL ALT DELETE
GUI SHIFT s
```

### Common Mistakes to Avoid

```duckyscript
REM ❌ WRONG - No hyphen in modifier combos
CTRL-SHIFT ENTER

REM ✅ CORRECT - Use spaces
CTRL SHIFT ENTER

REM ❌ WRONG - LOCALE not supported in DuckyScript 1.0
LOCALE US

REM ❌ WRONG - Empty lines can cause issues
STRING hello

STRING world

REM ✅ CORRECT - Use REM for spacing
STRING hello
REM
STRING world
```

---

## 🛡️ Testing Best Practices

### Before Running ANY Script

1. **📖 READ THE ENTIRE SCRIPT** - Understand what it does
2. **🔍 CHECK FOR PLACEHOLDERS** - Look for `YOUR_URL_HERE`, `WEBHOOK_URL`, etc.
3. **📸 TAKE A VM SNAPSHOT** - Easy rollback if something breaks
4. **🔌 DISCONNECT NETWORK** - For dangerous scripts, go offline
5. **📝 DOCUMENT YOUR TESTING** - Keep notes for legitimate purposes

### Testing Workflow

```
┌─────────────────────────────────────────────────────┐
│  1. Read Script                                      │
│     └─► Understand purpose and commands             │
├─────────────────────────────────────────────────────┤
│  2. Validate Syntax                                  │
│     └─► Run through DuckyScript validator           │
├─────────────────────────────────────────────────────┤
│  3. Prepare Environment                              │
│     └─► VM snapshot, network config, etc.           │
├─────────────────────────────────────────────────────┤
│  4. Execute Script                                   │
│     └─► Run in isolated VM environment              │
├─────────────────────────────────────────────────────┤
│  5. Observe & Document                               │
│     └─► Record behavior, take screenshots           │
├─────────────────────────────────────────────────────┤
│  6. Cleanup                                          │
│     └─► Restore snapshot or clean up changes        │
└─────────────────────────────────────────────────────┘
```

### Network Isolation Levels

| Script Type | Network Setting |
|-------------|-----------------|
| ASCII Art, FUN (harmless) | Connected OK |
| System Changes | NAT or Host-only |
| Exfiltration | **DISCONNECTED** |
| Reverse Shells | Isolated network only |

---

## 🔧 Troubleshooting

### Script Opens Wrong Applications

**Problem**: Commands execute but wrong apps open or nothing happens.

**Solution**: Increase delays. Modern systems (especially Windows 11) are slower to respond.

```duckyscript
REM Before (too fast)
GUI r
DELAY 200
STRING cmd

REM After (more reliable)
GUI r
DELAY 500
STRING cmd
DELAY 200
ENTER
```

### UAC Prompt Blocks Script

**Problem**: Script fails when UAC (User Account Control) appears.

**Solutions**:

```duckyscript
REM Option 1: Accept UAC with ALT+Y
DELAY 1500
ALT y
DELAY 1000

REM Option 2: Use Left Arrow + Enter (works on non-English systems)
DELAY 1500
LEFT
ENTER
DELAY 1000
```

### PowerShell Window Closes Immediately

**Problem**: PowerShell opens and closes before commands run.

**Solution**: Add `-NoExit` flag or increase delays:

```duckyscript
REM Keep PowerShell open
STRING powershell -NoExit -Command "your-command"

REM Or increase delay after opening
GUI r
DELAY 500
STRING powershell
ENTER
DELAY 2000
STRING your-command
```

### Flipper Shows "ERROR: line X"

**Common Causes & Fixes**:

| Error Cause | Fix |
|-------------|-----|
| Blank lines between commands | Remove empty lines or use `REM` |
| `LOCALE` command | Remove it (not supported) |
| Leading spaces | Remove indentation |
| Windows line endings | Convert to Unix (LF only) |
| Invalid command | Check DuckyScript 1.0 syntax |

### Script Works in VM but Not Real Hardware

**Possible Issues**:
- Timing differences (real hardware may be faster/slower)
- USB enumeration delays
- Different Windows version/configuration
- Antivirus blocking execution

**Solution**: Add delays after critical steps and test on target-similar hardware.

---

## ⚠️ Script Categories by Risk

### 🟢 Safe (No System Changes)

- **ASCII Art** - Opens Notepad, types art
- **FakeBluescreen** - Opens website in browser
- **ComputerTalks** - Uses text-to-speech

**Testing**: Can test on host machine with care.

### 🟡 Moderate (Reversible Changes)

- **Disable Cortana** - Registry changes (reversible)
- **Change Wallpaper** - Cosmetic only
- **Browser Pranks** - Opens tabs/pages

**Testing**: Use VM, take snapshot first.

### 🔴 Dangerous (System Modifications)

- **Disable Defender** - Lowers security
- **Create Admin User** - Adds backdoor account
- **Disable Firewall** - Network exposure
- **RDP Activation** - Remote access enabled

**Testing**: **VM ONLY**, network disconnected, snapshot required.

### ⚫ Critical (Data Exfiltration/Destruction)

- **WiFi Password Stealer** - Extracts credentials
- **SAM Exfil** - Password database theft
- **Keylogger** - Records keystrokes
- **Delete32** - System destruction

**Testing**: **ISOLATED VM ONLY**, air-gapped, authorized systems only.

---

## 📚 Additional Resources

- [Flipper Zero BadUSB Docs](https://docs.flipper.net/bad-usb)
- [DuckyScript 1.0 Reference](https://docs.flipper.net/bad-usb)
- [VirtualBox Manual](https://www.virtualbox.org/manual/)
- [DISCLAIMER.md](DISCLAIMER.md) - Legal information
- [SECURITY.md](SECURITY.md) - Security policy

---

## 🎯 Remember

**Test responsibly. Document everything. Stay legal.**

The goal is to learn and improve security - not to cause harm.

---

**Last Updated**: December 2025

