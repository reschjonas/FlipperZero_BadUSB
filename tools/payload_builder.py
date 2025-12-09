#!/usr/bin/env python3
"""
🦆 BadUSB Payload Builder - Easy Payload Customization

Interactive tool for browsing, customizing, and deploying BadUSB payloads.
Much easier than manually editing scripts!

Usage:
    python payload_builder.py                    # Interactive mode
    python payload_builder.py --list             # List all payloads
    python payload_builder.py --search wifi      # Search payloads
    python payload_builder.py --build reverse    # Build specific payload

Author: dil1thium
License: CC BY-NC-SA 4.0
"""

import os
import sys
import re
import argparse
from pathlib import Path
from dataclasses import dataclass
from typing import List, Dict, Optional

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

@dataclass
class Payload:
    name: str
    path: str
    platform: str
    category: str
    description: str
    danger_level: str
    requires_config: bool
    config_fields: List[str]

def get_danger_emoji(level: str) -> str:
    """Get emoji for danger level."""
    levels = {
        'safe': '🟢',
        'low': '🟢',
        'moderate': '🟡',
        'high': '🔴',
        'critical': '⚫'
    }
    return levels.get(level.lower(), '⚪')

def parse_payload(filepath: str) -> Optional[Payload]:
    """Parse a payload file and extract metadata."""
    try:
        with open(filepath, 'r', encoding='utf-8', errors='replace') as f:
            content = f.read()
            lines = content.split('\n')
    except Exception:
        return None
    
    # Extract metadata from REM comments
    metadata = {
        'description': '',
        'target': '',
        'category': '',
        'version': '',
    }
    
    for line in lines[:15]:  # Check first 15 lines for metadata
        line = line.strip()
        if line.upper().startswith('REM'):
            rem_content = line[3:].strip()
            for key in metadata.keys():
                if rem_content.lower().startswith(f'{key}:'):
                    metadata[key] = rem_content.split(':', 1)[1].strip()
    
    # Detect platform from path
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
    
    # Detect category from path
    parts = Path(filepath).parts
    category = 'Unknown'
    for part in parts:
        if part in ['Execution', 'Exfiltration', 'Reconnaissance', 'Persistence', 
                    'FUN', 'ASCII', 'GoodUSB', 'Pranks']:
            category = part
            break
    
    # Determine danger level
    danger_keywords = {
        'critical': ['sam', 'password', 'keylog', 'reverse', 'shell', 'backdoor', 'persist'],
        'high': ['disable', 'defender', 'firewall', 'admin', 'rdp', 'exfil'],
        'moderate': ['discord', 'delete', 'prank'],
        'low': ['info', 'recon', 'scan'],
        'safe': ['ascii', 'fun', 'rick', 'hello', 'note']
    }
    
    content_lower = content.lower()
    danger = 'moderate'
    for level, keywords in danger_keywords.items():
        if any(kw in content_lower or kw in filepath.lower() for kw in keywords):
            danger = level
            break
    
    # Find configuration placeholders
    config_patterns = [
        r'ATTACKER_IP', r'ATTACKER_PORT', r'PAYLOAD_URL', r'DISCORD[_\s]?WEBHOOK',
        r'YOUR_[A-Z_]+', r'PHONE_NUMBER', r'PUT[_\s]PATH[_\s]HERE'
    ]
    config_fields = []
    for pattern in config_patterns:
        if re.search(pattern, content, re.IGNORECASE):
            config_fields.append(pattern.replace(r'[_\s]?', '_').replace(r'[A-Z_]+', 'VALUE'))
    
    name = Path(filepath).stem
    
    return Payload(
        name=name,
        path=filepath,
        platform=platform,
        category=category,
        description=metadata['description'] or f'{name} payload',
        danger_level=danger,
        requires_config=len(config_fields) > 0,
        config_fields=list(set(config_fields))
    )

def find_all_payloads(base_path: str) -> List[Payload]:
    """Find and parse all payload files."""
    payloads = []
    for root, dirs, files in os.walk(base_path):
        dirs[:] = [d for d in dirs if not d.startswith('.')]
        for file in files:
            if file.endswith('.txt') and not file.lower().startswith('readme'):
                filepath = os.path.join(root, file)
                payload = parse_payload(filepath)
                if payload:
                    payloads.append(payload)
    return sorted(payloads, key=lambda p: (p.platform, p.category, p.name))

def print_payload_table(payloads: List[Payload], show_path: bool = False):
    """Print payloads in a formatted table."""
    if not payloads:
        print(f"{Colors.YELLOW}No payloads found.{Colors.RESET}")
        return
    
    print(f"\n{Colors.BOLD}{'#':<4} {'Platform':<10} {'Category':<15} {'Name':<30} {'Danger':<8} {'Config':<6}{Colors.RESET}")
    print("-" * 80)
    
    for i, p in enumerate(payloads, 1):
        danger_emoji = get_danger_emoji(p.danger_level)
        config_mark = "⚙️" if p.requires_config else "✅"
        
        print(f"{i:<4} {p.platform:<10} {p.category:<15} {p.name:<30} {danger_emoji:<8} {config_mark:<6}")
        
        if show_path:
            print(f"     {Colors.DIM}{p.path}{Colors.RESET}")

def search_payloads(payloads: List[Payload], query: str) -> List[Payload]:
    """Search payloads by name, description, or category."""
    query = query.lower()
    return [p for p in payloads if 
            query in p.name.lower() or 
            query in p.description.lower() or
            query in p.category.lower() or
            query in p.platform.lower()]

def build_payload(payload: Payload, output_path: Optional[str] = None) -> str:
    """Interactive payload builder with configuration."""
    print(f"\n{Colors.BOLD}{'='*60}{Colors.RESET}")
    print(f"{Colors.CYAN}🔧 Building: {payload.name}{Colors.RESET}")
    print(f"{Colors.BOLD}{'='*60}{Colors.RESET}")
    print(f"\n{Colors.WHITE}Platform: {payload.platform}")
    print(f"Category: {payload.category}")
    print(f"Danger: {get_danger_emoji(payload.danger_level)} {payload.danger_level.upper()}")
    print(f"Description: {payload.description}{Colors.RESET}")
    
    # Read original content
    with open(payload.path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Configuration
    if payload.requires_config:
        print(f"\n{Colors.YELLOW}⚙️  Configuration Required:{Colors.RESET}")
        
        replacements = {}
        
        # Common placeholders
        common_placeholders = {
            'ATTACKER_IP': ('Your IP address (listener)', '192.168.1.100'),
            'ATTACKER_PORT': ('Port number', '4444'),
            'PAYLOAD_URL': ('URL to your payload', 'http://192.168.1.100/payload.ps1'),
            'DISCORD_WEBHOOK': ('Discord webhook URL', 'https://discord.com/api/webhooks/xxx/yyy'),
            'DISCORD WEBHOOK LINK': ('Discord webhook URL', 'https://discord.com/api/webhooks/xxx/yyy'),
            'PHONE_NUMBER_HERE': ('Phone number', '+1234567890'),
        }
        
        for placeholder, (desc, example) in common_placeholders.items():
            if placeholder in content:
                print(f"\n   {Colors.CYAN}{placeholder}{Colors.RESET}")
                print(f"   {Colors.DIM}{desc} (example: {example}){Colors.RESET}")
                value = input(f"   Enter value [{example}]: ").strip()
                if not value:
                    value = example
                replacements[placeholder] = value
        
        # Apply replacements
        for old, new in replacements.items():
            content = content.replace(old, new)
    
    # Output
    if output_path:
        output_file = output_path
    else:
        output_dir = Path.home() / 'Desktop' / 'BadUSB_Output'
        output_dir.mkdir(exist_ok=True)
        output_file = output_dir / f"{payload.name}_configured.txt"
    
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"\n{Colors.GREEN}✅ Payload saved to: {output_file}{Colors.RESET}")
    print(f"\n{Colors.CYAN}📋 Next steps:{Colors.RESET}")
    print(f"   1. Copy to Flipper Zero: SD Card → badusb/")
    print(f"   2. On Flipper: Bad USB → Select script → Run")
    
    return str(output_file)

def interactive_mode(payloads: List[Payload]):
    """Interactive menu for browsing and building payloads."""
    while True:
        print(f"\n{Colors.BOLD}{'='*60}{Colors.RESET}")
        print(f"{Colors.CYAN}🦆 BadUSB Payload Builder{Colors.RESET}")
        print(f"{Colors.BOLD}{'='*60}{Colors.RESET}")
        print(f"\n{Colors.WHITE}Total payloads: {len(payloads)}{Colors.RESET}")
        print(f"\n{Colors.YELLOW}Commands:{Colors.RESET}")
        print("  [1] List all payloads")
        print("  [2] Filter by platform (Windows/Linux/macOS/iPhone)")
        print("  [3] Filter by category")
        print("  [4] Search payloads")
        print("  [5] Build/customize a payload")
        print("  [6] Quick deploy (common payloads)")
        print("  [q] Quit")
        
        choice = input(f"\n{Colors.GREEN}Enter choice: {Colors.RESET}").strip().lower()
        
        if choice == 'q':
            print(f"\n{Colors.CYAN}Goodbye! Happy hacking (ethically)! 🦆{Colors.RESET}\n")
            break
        
        elif choice == '1':
            print_payload_table(payloads)
        
        elif choice == '2':
            print(f"\n{Colors.YELLOW}Platforms: Windows, Linux, macOS, iPhone{Colors.RESET}")
            platform = input("Enter platform: ").strip()
            filtered = [p for p in payloads if platform.lower() in p.platform.lower()]
            print_payload_table(filtered)
        
        elif choice == '3':
            categories = sorted(set(p.category for p in payloads))
            print(f"\n{Colors.YELLOW}Categories: {', '.join(categories)}{Colors.RESET}")
            category = input("Enter category: ").strip()
            filtered = [p for p in payloads if category.lower() in p.category.lower()]
            print_payload_table(filtered)
        
        elif choice == '4':
            query = input("Search query: ").strip()
            if query:
                results = search_payloads(payloads, query)
                print_payload_table(results)
        
        elif choice == '5':
            print_payload_table(payloads)
            try:
                num = int(input(f"\n{Colors.GREEN}Enter payload number: {Colors.RESET}"))
                if 1 <= num <= len(payloads):
                    build_payload(payloads[num - 1])
                else:
                    print(f"{Colors.RED}Invalid number{Colors.RESET}")
            except ValueError:
                print(f"{Colors.RED}Please enter a number{Colors.RESET}")
        
        elif choice == '6':
            print(f"\n{Colors.BOLD}Quick Deploy - Popular Payloads:{Colors.RESET}")
            quick_payloads = [
                ("WiFi Password Stealer (Windows)", "StealWifiKeys"),
                ("Reverse Shell (Windows)", "powershell_reverse_shell"),
                ("System Info (Linux)", "system_info"),
                ("Rick Roll (Any)", "rick_roll"),
                ("Fake BSOD (Windows)", "FakeBluescreen"),
            ]
            for i, (desc, name) in enumerate(quick_payloads, 1):
                print(f"  [{i}] {desc}")
            
            try:
                num = int(input(f"\n{Colors.GREEN}Select: {Colors.RESET}"))
                if 1 <= num <= len(quick_payloads):
                    name = quick_payloads[num - 1][1]
                    matches = [p for p in payloads if name.lower() in p.name.lower()]
                    if matches:
                        build_payload(matches[0])
                    else:
                        print(f"{Colors.RED}Payload not found{Colors.RESET}")
            except ValueError:
                pass

def main():
    parser = argparse.ArgumentParser(
        description="🦆 BadUSB Payload Builder - Easy payload customization",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    parser.add_argument('--list', '-l', action='store_true', help='List all payloads')
    parser.add_argument('--search', '-s', help='Search payloads')
    parser.add_argument('--build', '-b', help='Build specific payload by name')
    parser.add_argument('--platform', '-p', help='Filter by platform')
    parser.add_argument('--output', '-o', help='Output path for built payload')
    
    args = parser.parse_args()
    
    # Find payloads directory
    script_dir = Path(__file__).parent.parent
    payloads_dir = script_dir / 'BadUSB-Scripts'
    
    if not payloads_dir.exists():
        print(f"{Colors.RED}BadUSB-Scripts directory not found!{Colors.RESET}")
        sys.exit(1)
    
    # Load payloads
    print(f"{Colors.DIM}Loading payloads...{Colors.RESET}")
    payloads = find_all_payloads(str(payloads_dir))
    print(f"{Colors.GREEN}Found {len(payloads)} payloads{Colors.RESET}")
    
    # Handle arguments
    if args.list:
        if args.platform:
            payloads = [p for p in payloads if args.platform.lower() in p.platform.lower()]
        print_payload_table(payloads, show_path=True)
    
    elif args.search:
        results = search_payloads(payloads, args.search)
        print_payload_table(results, show_path=True)
    
    elif args.build:
        matches = [p for p in payloads if args.build.lower() in p.name.lower()]
        if matches:
            build_payload(matches[0], args.output)
        else:
            print(f"{Colors.RED}No payload found matching '{args.build}'{Colors.RESET}")
    
    else:
        # Interactive mode
        interactive_mode(payloads)

if __name__ == '__main__':
    main()

