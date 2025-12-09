#!/usr/bin/env python3
"""
Batch Fix Tool for DuckyScript Files

Automatically fixes common issues in all BadUSB scripts:
- CTRL-SHIFT → CTRL SHIFT (remove hyphens)
- Remove trailing whitespace
- Remove empty lines at end of file
- Update author contact info

Usage:
    python batch_fix.py --dry-run    # Preview changes
    python batch_fix.py --apply      # Apply fixes

Author: dil1thium
License: CC BY-NC-SA 4.0
"""

import os
import re
import sys
from pathlib import Path

# ANSI Colors
class Colors:
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    BOLD = '\033[1m'
    RESET = '\033[0m'


def find_all_scripts(base_path: str) -> list:
    """Find all .txt payload files."""
    scripts = []
    for root, dirs, files in os.walk(base_path):
        dirs[:] = [d for d in dirs if not d.startswith('.') and d.lower() not in ('tools', '__pycache__', 'venv')]
        for file in files:
            if file.endswith('.txt') and not file.lower().startswith('readme'):
                scripts.append(os.path.join(root, file))
    return sorted(scripts)


def fix_script(filepath: str, dry_run: bool = True) -> dict:
    """Fix common issues in a DuckyScript file."""
    changes = {
        'hyphen_fixes': 0,
        'whitespace_fixes': 0,
        'empty_line_fixes': 0,
        'contact_updates': 0,
        'delay_increases': 0,
    }
    
    try:
        with open(filepath, 'r', encoding='utf-8', errors='replace') as f:
            content = f.read()
    except Exception as e:
        print(f"{Colors.RED}Error reading {filepath}: {e}{Colors.RESET}")
        return changes
    
    original = content
    lines = content.split('\n')
    fixed_lines = []
    
    for line in lines:
        original_line = line
        
        # Fix 1: CTRL-SHIFT → CTRL SHIFT (but not in REM lines for descriptions)
        if not line.strip().upper().startswith('REM'):
            # Fix modifier hyphens
            new_line = re.sub(r'(CTRL|ALT|SHIFT|GUI|WINDOWS)-', r'\1 ', line, flags=re.IGNORECASE)
            if new_line != line:
                changes['hyphen_fixes'] += 1
                line = new_line
        
        # Fix 2: Remove trailing whitespace
        stripped = line.rstrip()
        if len(stripped) < len(line):
            changes['whitespace_fixes'] += 1
            line = stripped
        
        # Fix 3: Update old author references
        if 'UNC0V3R3D' in line:
            line = line.replace('UNC0V3R3D', 'dil1thium')
            # Clean up double spaces
            line = re.sub(r'\s+', ' ', line).strip()
            if line.startswith('REM '):
                line = 'REM ' + line[4:].strip()
            changes['contact_updates'] += 1
        
        fixed_lines.append(line)
    
    # Fix 4: Remove multiple consecutive empty lines
    content = '\n'.join(fixed_lines)
    new_content = re.sub(r'\n{3,}', '\n\n', content)
    if new_content != content:
        changes['empty_line_fixes'] += 1
        content = new_content
    
    # Remove trailing empty lines
    content = content.rstrip() + '\n'
    
    # Check if anything changed
    if content != original:
        if not dry_run:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
        return changes
    
    return {}


def main():
    import argparse
    
    parser = argparse.ArgumentParser(description="Batch fix DuckyScript files")
    parser.add_argument('--dry-run', '-n', action='store_true', help='Preview changes without applying')
    parser.add_argument('--apply', '-a', action='store_true', help='Apply fixes')
    parser.add_argument('--path', '-p', default=None, help='Path to scripts directory')
    
    args = parser.parse_args()
    
    if not args.dry_run and not args.apply:
        print(f"{Colors.YELLOW}Specify --dry-run to preview or --apply to fix{Colors.RESET}")
        parser.print_help()
        sys.exit(1)
    
    # Find scripts directory
    if args.path:
        scripts_dir = args.path
    else:
        script_dir = Path(__file__).parent.parent
        scripts_dir = script_dir / 'BadUSB-Scripts'
    
    if not os.path.exists(scripts_dir):
        print(f"{Colors.RED}Scripts directory not found: {scripts_dir}{Colors.RESET}")
        sys.exit(1)
    
    scripts = find_all_scripts(str(scripts_dir))
    
    print(f"\n{Colors.BOLD}🔧 DuckyScript Batch Fixer{Colors.RESET}")
    print(f"{'='*60}")
    print(f"Mode: {'DRY RUN (preview only)' if args.dry_run else 'APPLYING FIXES'}")
    print(f"Scripts found: {len(scripts)}")
    print(f"{'='*60}\n")
    
    total_changes = {
        'hyphen_fixes': 0,
        'whitespace_fixes': 0,
        'empty_line_fixes': 0,
        'contact_updates': 0,
        'delay_increases': 0,
    }
    files_changed = 0
    
    for filepath in scripts:
        changes = fix_script(filepath, dry_run=args.dry_run)
        
        if changes:
            files_changed += 1
            rel_path = os.path.relpath(filepath, scripts_dir)
            
            change_list = []
            for key, count in changes.items():
                if count > 0:
                    total_changes[key] += count
                    change_list.append(f"{key.replace('_', ' ')}: {count}")
            
            if change_list:
                action = "Would fix" if args.dry_run else "Fixed"
                print(f"{Colors.GREEN}✓ {action}: {rel_path}{Colors.RESET}")
                for change in change_list:
                    print(f"   - {change}")
    
    # Summary
    print(f"\n{Colors.BOLD}{'='*60}{Colors.RESET}")
    print(f"{Colors.BOLD}📊 SUMMARY{Colors.RESET}")
    print(f"{Colors.BOLD}{'='*60}{Colors.RESET}")
    print(f"Files {'to fix' if args.dry_run else 'fixed'}: {files_changed}/{len(scripts)}")
    print(f"\nChanges:")
    for key, count in total_changes.items():
        if count > 0:
            print(f"   {key.replace('_', ' ').title()}: {count}")
    
    if args.dry_run and files_changed > 0:
        print(f"\n{Colors.CYAN}Run with --apply to apply these fixes{Colors.RESET}")


if __name__ == '__main__':
    main()

