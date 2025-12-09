#!/usr/bin/env python3
"""
🔧 Payload Configurator - Configure BadUSB Payloads Easily

This tool helps you configure payloads that require user input.
Interactive payload configuration tool.

Usage:
    python payload_configurator.py                    # Interactive mode
    python payload_configurator.py --payload <path>   # Configure specific payload

Author: dil1thium
License: CC BY-NC-SA 4.0
"""

import os
import sys
import re
import argparse
from pathlib import Path
from dataclasses import dataclass
from typing import List, Dict, Optional, Tuple

# ANSI Colors
class Colors:
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    MAGENTA = '\033[95m'
    CYAN = '\033[96m'
    WHITE = '\033[97m'
    BOLD = '\033[1m'
    DIM = '\033[2m'
    RESET = '\033[0m'

# Configuration field definitions with descriptions and examples
CONFIG_FIELDS = {
    # Network/Connection
    'ATTACKER_IP': {
        'description': 'Your IP address where you\'re listening for connections',
        'example': '192.168.1.100',
        'category': 'Network',
        'required': True,
    },
    'ATTACKER_PORT': {
        'description': 'Port number for reverse shell listener',
        'example': '4444',
        'category': 'Network',
        'required': True,
    },
    
    # URLs
    'PAYLOAD_URL': {
        'description': 'URL to your hosted payload file',
        'example': 'http://192.168.1.100:8080/payload.ps1',
        'category': 'URL',
        'required': True,
    },
    'DISCORD_WEBHOOK_URL': {
        'description': 'Discord webhook URL for data exfiltration',
        'example': 'https://discord.com/api/webhooks/123456/abcdef',
        'category': 'URL',
        'required': True,
    },
    'DISCORD WEBHOOK LINK': {
        'description': 'Discord webhook URL for data exfiltration',
        'example': 'https://discord.com/api/webhooks/123456/abcdef',
        'category': 'URL',
        'required': True,
    },
    'DISCORD WEBHOOK URL': {
        'description': 'Discord webhook URL for data exfiltration',
        'example': 'https://discord.com/api/webhooks/123456/abcdef',
        'category': 'URL',
        'required': True,
    },
    
    # Credentials
    'YOUR_SSH_PUBLIC_KEY_HERE': {
        'description': 'Your SSH public key for backdoor access',
        'example': 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA... user@host',
        'category': 'Credentials',
        'required': True,
    },
    
    # Target Info
    'PHONE_NUMBER_HERE': {
        'description': 'Phone number to send message to',
        'example': '+1234567890',
        'category': 'Target',
        'required': True,
    },
    
    # Generic placeholders
    'YOUR_URL_HERE': {
        'description': 'URL to open or download from',
        'example': 'https://example.com',
        'category': 'URL',
        'required': True,
    },
    'PUT PATH HERE': {
        'description': 'File path for saving output',
        'example': 'C:\\Users\\Public\\output',
        'category': 'Path',
        'required': True,
    },
}

@dataclass
class PayloadInfo:
    name: str
    path: str
    platform: str
    category: str
    description: str
    plug_and_play: bool
    required_config: List[str]
    optional_config: List[str]

def detect_config_fields(content: str) -> Tuple[List[str], List[str]]:
    """Detect configuration fields in payload content."""
    required = []
    optional = []
    
    content_upper = content.upper()
    
    for field in CONFIG_FIELDS.keys():
        if field in content or field.upper() in content_upper:
            required.append(field)
    
    # Also check for generic patterns
    generic_patterns = [
        (r'ATTACKER_IP', 'ATTACKER_IP'),
        (r'ATTACKER_PORT', 'ATTACKER_PORT'),
        (r'PAYLOAD_URL', 'PAYLOAD_URL'),
        (r'DISCORD.?WEBHOOK', 'DISCORD_WEBHOOK_URL'),
        (r'YOUR_.*_HERE', 'CUSTOM_VALUE'),
        (r'PUT.*HERE', 'CUSTOM_PATH'),
        (r'LINK TO \w+', 'CUSTOM_URL'),
    ]
    
    for pattern, field_name in generic_patterns:
        if re.search(pattern, content, re.IGNORECASE):
            if field_name not in required:
                required.append(field_name)
    
    return required, optional

def analyze_payload(filepath: str) -> PayloadInfo:
    """Analyze a payload file and determine its configuration needs."""
    try:
        with open(filepath, 'r', encoding='utf-8', errors='replace') as f:
            content = f.read()
    except Exception as e:
        return None
    
    # Extract metadata
    lines = content.split('\n')
    metadata = {'description': '', 'category': '', 'target': ''}
    
    for line in lines[:20]:
        line = line.strip()
        if line.upper().startswith('REM'):
            rem_content = line[3:].strip()
            for key in metadata.keys():
                if rem_content.lower().startswith(f'{key}:'):
                    metadata[key] = rem_content.split(':', 1)[1].strip()
    
    # Detect platform
    path_lower = filepath.lower()
    if 'windows' in path_lower:
        platform = 'Windows'
    elif 'linux' in path_lower:
        platform = 'Linux'
    elif 'macos' in path_lower or 'mac' in path_lower:
        platform = 'macOS'
    elif 'iphone' in path_lower or 'ios' in path_lower:
        platform = 'iPhone'
    else:
        platform = 'Unknown'
    
    # Detect category
    parts = Path(filepath).parts
    category = 'Unknown'
    for part in parts:
        if part in ['Execution', 'Exfiltration', 'Reconnaissance', 'Persistence', 
                    'FUN', 'ASCII', 'GoodUSB', 'Pranks', 'PasswordStuff']:
            category = part
            break
    
    # Detect configuration requirements
    required_config, optional_config = detect_config_fields(content)
    
    # Determine if plug-and-play
    plug_and_play = len(required_config) == 0
    
    name = Path(filepath).stem
    
    return PayloadInfo(
        name=name,
        path=filepath,
        platform=platform,
        category=category,
        description=metadata.get('description', f'{name} payload'),
        plug_and_play=plug_and_play,
        required_config=required_config,
        optional_config=optional_config
    )

def configure_payload(payload: PayloadInfo, output_dir: Optional[str] = None) -> str:
    """Interactive configuration wizard for a payload."""
    print(f"\n{Colors.BOLD}{'='*70}{Colors.RESET}")
    print(f"{Colors.CYAN}🔧 PAYLOAD CONFIGURATOR{Colors.RESET}")
    print(f"{Colors.BOLD}{'='*70}{Colors.RESET}")
    
    # Payload info
    print(f"\n{Colors.WHITE}📄 Payload: {Colors.BOLD}{payload.name}{Colors.RESET}")
    print(f"{Colors.WHITE}📁 Platform: {payload.platform}{Colors.RESET}")
    print(f"{Colors.WHITE}📂 Category: {payload.category}{Colors.RESET}")
    print(f"{Colors.WHITE}📝 Description: {payload.description}{Colors.RESET}")
    
    if payload.plug_and_play:
        print(f"\n{Colors.GREEN}✅ PLUG AND PLAY - No configuration needed!{Colors.RESET}")
        print(f"{Colors.DIM}This payload works immediately without any changes.{Colors.RESET}")
        
        # Just copy to output
        with open(payload.path, 'r', encoding='utf-8') as f:
            content = f.read()
    else:
        print(f"\n{Colors.YELLOW}⚙️  CONFIGURATION REQUIRED{Colors.RESET}")
        print(f"{Colors.DIM}This payload needs the following values:{Colors.RESET}")
        
        # Show required fields
        for field in payload.required_config:
            info = CONFIG_FIELDS.get(field, {'description': 'Custom value', 'example': 'your_value'})
            print(f"\n   {Colors.CYAN}• {field}{Colors.RESET}")
            print(f"     {Colors.DIM}{info.get('description', 'Enter value')}{Colors.RESET}")
        
        print(f"\n{Colors.BOLD}Enter configuration values:{Colors.RESET}")
        
        # Read original content
        with open(payload.path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Get user input for each field
        replacements = {}
        for field in payload.required_config:
            info = CONFIG_FIELDS.get(field, {'description': 'Custom value', 'example': 'your_value', 'category': 'Other'})
            
            print(f"\n{Colors.CYAN}{field}{Colors.RESET}")
            print(f"  {Colors.DIM}Description: {info.get('description', 'Enter value')}{Colors.RESET}")
            print(f"  {Colors.DIM}Example: {info.get('example', 'value')}{Colors.RESET}")
            
            while True:
                value = input(f"  {Colors.GREEN}Enter value: {Colors.RESET}").strip()
                if value:
                    replacements[field] = value
                    break
                else:
                    use_example = input(f"  {Colors.YELLOW}Use example value? (y/n): {Colors.RESET}").strip().lower()
                    if use_example == 'y':
                        replacements[field] = info.get('example', 'value')
                        print(f"  {Colors.DIM}Using: {replacements[field]}{Colors.RESET}")
                        break
                    print(f"  {Colors.RED}Value is required!{Colors.RESET}")
        
        # Apply replacements
        for old, new in replacements.items():
            content = content.replace(old, new)
            # Also try case variations
            content = content.replace(old.upper(), new)
            content = content.replace(old.lower(), new)
    
    # Save configured payload
    if output_dir:
        output_path = Path(output_dir)
    else:
        output_path = Path.home() / 'Desktop' / 'FlipperZero_Payloads'
    
    output_path.mkdir(parents=True, exist_ok=True)
    
    suffix = "" if payload.plug_and_play else "_configured"
    output_file = output_path / f"{payload.name}{suffix}.txt"
    
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"\n{Colors.GREEN}{'='*70}{Colors.RESET}")
    print(f"{Colors.GREEN}✅ PAYLOAD READY!{Colors.RESET}")
    print(f"{Colors.GREEN}{'='*70}{Colors.RESET}")
    print(f"\n{Colors.WHITE}📁 Saved to: {Colors.BOLD}{output_file}{Colors.RESET}")
    
    print(f"\n{Colors.CYAN}📋 Next Steps:{Colors.RESET}")
    print(f"   1. Copy file to Flipper Zero: SD Card → badusb/")
    print(f"   2. On Flipper: Bad USB → Select → Run")
    
    if not payload.plug_and_play and 'ATTACKER_IP' in payload.required_config:
        print(f"\n{Colors.YELLOW}⚠️  Don't forget to start your listener:{Colors.RESET}")
        print(f"   {Colors.DIM}nc -lvnp {replacements.get('ATTACKER_PORT', '4444')}{Colors.RESET}")
    
    return str(output_file)

def list_payloads_by_type(payloads: List[PayloadInfo]):
    """List payloads grouped by plug-and-play status."""
    plug_play = [p for p in payloads if p.plug_and_play]
    need_config = [p for p in payloads if not p.plug_and_play]
    
    print(f"\n{Colors.BOLD}{'='*70}{Colors.RESET}")
    print(f"{Colors.GREEN}✅ PLUG AND PLAY ({len(plug_play)} payloads){Colors.RESET}")
    print(f"{Colors.DIM}Ready to use immediately - no configuration needed{Colors.RESET}")
    print(f"{Colors.BOLD}{'='*70}{Colors.RESET}")
    
    # Group by platform
    for platform in ['Windows', 'Linux', 'macOS', 'iPhone']:
        platform_payloads = [p for p in plug_play if p.platform == platform]
        if platform_payloads:
            print(f"\n{Colors.CYAN}📁 {platform}{Colors.RESET}")
            for p in platform_payloads[:10]:  # Show first 10
                print(f"   • {p.name} ({p.category})")
            if len(platform_payloads) > 10:
                print(f"   {Colors.DIM}... and {len(platform_payloads) - 10} more{Colors.RESET}")
    
    print(f"\n{Colors.BOLD}{'='*70}{Colors.RESET}")
    print(f"{Colors.YELLOW}⚙️  NEEDS CONFIGURATION ({len(need_config)} payloads){Colors.RESET}")
    print(f"{Colors.DIM}Requires user input before use{Colors.RESET}")
    print(f"{Colors.BOLD}{'='*70}{Colors.RESET}")
    
    # Group by config type
    config_types = {}
    for p in need_config:
        for field in p.required_config:
            if field not in config_types:
                config_types[field] = []
            config_types[field].append(p)
    
    for config_field, payloads_list in sorted(config_types.items()):
        info = CONFIG_FIELDS.get(config_field, {})
        print(f"\n{Colors.MAGENTA}🔧 Requires {config_field}:{Colors.RESET}")
        print(f"   {Colors.DIM}{info.get('description', 'Custom value')}{Colors.RESET}")
        for p in payloads_list[:5]:
            print(f"   • {p.platform}/{p.name}")
        if len(payloads_list) > 5:
            print(f"   {Colors.DIM}... and {len(payloads_list) - 5} more{Colors.RESET}")

def find_all_payloads(base_path: str) -> List[PayloadInfo]:
    """Find and analyze all payload files."""
    payloads = []
    for root, dirs, files in os.walk(base_path):
        dirs[:] = [d for d in dirs if not d.startswith('.')]
        for file in files:
            if file.endswith('.txt') and not file.lower().startswith('readme'):
                filepath = os.path.join(root, file)
                payload = analyze_payload(filepath)
                if payload:
                    payloads.append(payload)
    return sorted(payloads, key=lambda p: (not p.plug_and_play, p.platform, p.name))

def interactive_mode(payloads: List[PayloadInfo]):
    """Interactive configuration wizard."""
    while True:
        print(f"\n{Colors.BOLD}{'='*70}{Colors.RESET}")
        print(f"{Colors.CYAN}🔧 PAYLOAD CONFIGURATOR{Colors.RESET}")
        print(f"{Colors.BOLD}{'='*70}{Colors.RESET}")
        
        plug_play = [p for p in payloads if p.plug_and_play]
        need_config = [p for p in payloads if not p.plug_and_play]
        
        print(f"\n{Colors.WHITE}Total payloads: {len(payloads)}{Colors.RESET}")
        print(f"  {Colors.GREEN}✅ Plug & Play: {len(plug_play)}{Colors.RESET}")
        print(f"  {Colors.YELLOW}⚙️  Needs Config: {len(need_config)}{Colors.RESET}")
        
        print(f"\n{Colors.YELLOW}Options:{Colors.RESET}")
        print("  [1] View all PLUG & PLAY payloads")
        print("  [2] View payloads that NEED CONFIGURATION")
        print("  [3] Configure a payload (by number)")
        print("  [4] Search payloads")
        print("  [5] Quick configure: Reverse Shell")
        print("  [6] Quick configure: WiFi Stealer + Discord")
        print("  [q] Quit")
        
        choice = input(f"\n{Colors.GREEN}Select: {Colors.RESET}").strip().lower()
        
        if choice == 'q':
            print(f"\n{Colors.CYAN}Goodbye! 🦆{Colors.RESET}\n")
            break
        
        elif choice == '1':
            print(f"\n{Colors.GREEN}{'='*70}{Colors.RESET}")
            print(f"{Colors.GREEN}✅ PLUG AND PLAY PAYLOADS{Colors.RESET}")
            print(f"{Colors.GREEN}{'='*70}{Colors.RESET}")
            for i, p in enumerate(plug_play, 1):
                print(f"  {i:3}. [{p.platform:8}] {p.category:15} {p.name}")
        
        elif choice == '2':
            print(f"\n{Colors.YELLOW}{'='*70}{Colors.RESET}")
            print(f"{Colors.YELLOW}⚙️  PAYLOADS NEEDING CONFIGURATION{Colors.RESET}")
            print(f"{Colors.YELLOW}{'='*70}{Colors.RESET}")
            for i, p in enumerate(need_config, 1):
                config_str = ', '.join(p.required_config[:2])
                if len(p.required_config) > 2:
                    config_str += f" +{len(p.required_config)-2}"
                print(f"  {i:3}. [{p.platform:8}] {p.name:25} → {Colors.DIM}{config_str}{Colors.RESET}")
        
        elif choice == '3':
            print(f"\n{Colors.WHITE}All payloads:{Colors.RESET}")
            for i, p in enumerate(payloads, 1):
                status = "✅" if p.plug_and_play else "⚙️"
                print(f"  {i:3}. {status} [{p.platform:8}] {p.name}")
            
            try:
                num = int(input(f"\n{Colors.GREEN}Enter payload number: {Colors.RESET}"))
                if 1 <= num <= len(payloads):
                    configure_payload(payloads[num - 1])
            except ValueError:
                print(f"{Colors.RED}Invalid number{Colors.RESET}")
        
        elif choice == '4':
            query = input(f"{Colors.GREEN}Search: {Colors.RESET}").strip().lower()
            results = [p for p in payloads if query in p.name.lower() or query in p.category.lower()]
            print(f"\n{Colors.WHITE}Results for '{query}':{Colors.RESET}")
            for i, p in enumerate(results, 1):
                status = "✅" if p.plug_and_play else "⚙️"
                print(f"  {i:3}. {status} [{p.platform:8}] {p.name}")
            
            if results:
                try:
                    num = int(input(f"\n{Colors.GREEN}Configure which? (0 to skip): {Colors.RESET}"))
                    if 1 <= num <= len(results):
                        configure_payload(results[num - 1])
                except ValueError:
                    pass
        
        elif choice == '5':
            # Quick configure reverse shell
            reverse_shells = [p for p in payloads if 'reverse' in p.name.lower() or 'shell' in p.name.lower()]
            if reverse_shells:
                print(f"\n{Colors.CYAN}Available Reverse Shells:{Colors.RESET}")
                for i, p in enumerate(reverse_shells, 1):
                    print(f"  {i}. [{p.platform}] {p.name}")
                try:
                    num = int(input(f"\n{Colors.GREEN}Select: {Colors.RESET}"))
                    if 1 <= num <= len(reverse_shells):
                        configure_payload(reverse_shells[num - 1])
                except ValueError:
                    pass
        
        elif choice == '6':
            # Quick configure WiFi stealer
            wifi_payloads = [p for p in payloads if 'wifi' in p.name.lower() and 'discord' in p.name.lower()]
            if wifi_payloads:
                configure_payload(wifi_payloads[0])
            else:
                wifi_payloads = [p for p in payloads if 'wifi' in p.name.lower()]
                if wifi_payloads:
                    print(f"\n{Colors.CYAN}WiFi Payloads:{Colors.RESET}")
                    for i, p in enumerate(wifi_payloads, 1):
                        print(f"  {i}. [{p.platform}] {p.name}")
                    try:
                        num = int(input(f"\n{Colors.GREEN}Select: {Colors.RESET}"))
                        if 1 <= num <= len(wifi_payloads):
                            configure_payload(wifi_payloads[num - 1])
                    except ValueError:
                        pass

def main():
    parser = argparse.ArgumentParser(description="🔧 Payload Configurator")
    parser.add_argument('--payload', '-p', help='Configure specific payload')
    parser.add_argument('--list', '-l', action='store_true', help='List all payloads by type')
    parser.add_argument('--output', '-o', help='Output directory')
    
    args = parser.parse_args()
    
    # Find payloads directory
    script_dir = Path(__file__).parent.parent
    payloads_dir = script_dir / 'BadUSB-Scripts'
    
    if not payloads_dir.exists():
        print(f"{Colors.RED}BadUSB-Scripts directory not found!{Colors.RESET}")
        sys.exit(1)
    
    print(f"{Colors.DIM}Loading payloads...{Colors.RESET}")
    payloads = find_all_payloads(str(payloads_dir))
    
    plug_play = len([p for p in payloads if p.plug_and_play])
    need_config = len([p for p in payloads if not p.plug_and_play])
    
    print(f"{Colors.GREEN}Found {len(payloads)} payloads ({plug_play} plug&play, {need_config} need config){Colors.RESET}")
    
    if args.list:
        list_payloads_by_type(payloads)
    elif args.payload:
        matches = [p for p in payloads if args.payload.lower() in p.name.lower() or args.payload.lower() in p.path.lower()]
        if matches:
            configure_payload(matches[0], args.output)
        else:
            print(f"{Colors.RED}Payload not found: {args.payload}{Colors.RESET}")
    else:
        interactive_mode(payloads)

if __name__ == '__main__':
    main()

