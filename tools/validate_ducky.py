#!/usr/bin/env python3
"""
DuckyScript 1.0 Validator for Flipper Zero BadUSB

This tool validates DuckyScript 1.0 syntax without executing the scripts.
Perfect for checking payloads before deploying to Flipper Zero.

Usage:
    python validate_ducky.py <script.txt>           # Validate single file
    python validate_ducky.py --all                  # Validate all scripts
    python validate_ducky.py --dir <directory>      # Validate directory
    python validate_ducky.py --fix <script.txt>     # Auto-fix common issues

Author: dil1thium
License: CC BY-NC-SA 4.0
"""

import argparse
import os
import re
import sys
from pathlib import Path
from dataclasses import dataclass
from typing import List, Optional, Tuple
from enum import Enum

# ANSI Colors for terminal output
class Colors:
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    MAGENTA = '\033[95m'
    CYAN = '\033[96m'
    WHITE = '\033[97m'
    BOLD = '\033[1m'
    RESET = '\033[0m'

class Severity(Enum):
    ERROR = "error"
    WARNING = "warning"
    INFO = "info"

@dataclass
class ValidationIssue:
    line_number: int
    line_content: str
    message: str
    severity: Severity
    suggestion: Optional[str] = None

# Valid DuckyScript 1.0 commands for Flipper Zero
VALID_COMMANDS = {
    # Comments
    'REM',
    # Timing
    'DELAY', 'DEFAULT_DELAY', 'DEFAULTDELAY',
    # String typing
    'STRING', 'STRINGLN',
    # Special keys
    'ENTER', 'RETURN',
    'TAB',
    'SPACE',
    'BACKSPACE',
    'DELETE', 'DEL',
    'INSERT',
    'HOME',
    'END',
    'PAGEUP', 'PAGE_UP',
    'PAGEDOWN', 'PAGE_DOWN',
    'ESCAPE', 'ESC',
    'PAUSE', 'BREAK',
    'CAPSLOCK', 'CAPS_LOCK',
    'NUMLOCK', 'NUM_LOCK',
    'SCROLLLOCK', 'SCROLL_LOCK',
    'PRINTSCREEN', 'PRINT_SCREEN',
    # Arrow keys
    'UP', 'UPARROW', 'UP_ARROW',
    'DOWN', 'DOWNARROW', 'DOWN_ARROW',
    'LEFT', 'LEFTARROW', 'LEFT_ARROW',
    'RIGHT', 'RIGHTARROW', 'RIGHT_ARROW',
    # Function keys
    'F1', 'F2', 'F3', 'F4', 'F5', 'F6',
    'F7', 'F8', 'F9', 'F10', 'F11', 'F12',
    # Modifier keys (can be standalone or with combinations)
    'CTRL', 'CONTROL',
    'ALT',
    'SHIFT',
    'GUI', 'WINDOWS', 'COMMAND', 'META',
    # Application key
    'MENU', 'APP',
    # Flipper-specific
    'ID',
    'REPEAT',
    'SYSRQ',
    # Holdable modifiers (Flipper Zero specific)
    'HOLD', 'RELEASE',
    # Wait for button press
    'WAIT_FOR_BUTTON_PRESS',
}

# Keys that can follow modifier keys
VALID_MODIFIER_TARGETS = {
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
    'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'F10', 'F11', 'F12',
    'ENTER', 'RETURN', 'TAB', 'SPACE', 'BACKSPACE', 'DELETE', 'DEL',
    'ESCAPE', 'ESC', 'INSERT', 'HOME', 'END', 'PAGEUP', 'PAGEDOWN',
    'UP', 'DOWN', 'LEFT', 'RIGHT', 'UPARROW', 'DOWNARROW', 'LEFTARROW', 'RIGHTARROW',
    'PRINTSCREEN', 'PAUSE', 'BREAK', 'CAPSLOCK', 'NUMLOCK', 'SCROLLLOCK',
    'CTRL', 'CONTROL', 'ALT', 'SHIFT', 'GUI', 'WINDOWS',
}

MODIFIER_KEYS = {'CTRL', 'CONTROL', 'ALT', 'SHIFT', 'GUI', 'WINDOWS', 'COMMAND', 'META'}

def validate_line(line: str, line_number: int) -> List[ValidationIssue]:
    """Validate a single line of DuckyScript."""
    issues = []
    original_line = line
    line = line.strip()
    
    # Empty line - warning (can cause issues on some firmware)
    if not line:
        issues.append(ValidationIssue(
            line_number=line_number,
            line_content=original_line,
            message="Empty line (may cause issues on some Flipper firmware)",
            severity=Severity.WARNING,
            suggestion="Remove empty line or replace with 'REM'"
        ))
        return issues
    
    # Check for leading whitespace (tabs/spaces)
    if original_line != original_line.lstrip():
        issues.append(ValidationIssue(
            line_number=line_number,
            line_content=original_line,
            message="Leading whitespace detected",
            severity=Severity.WARNING,
            suggestion="Remove leading spaces/tabs"
        ))
    
    # Check for common hyphen mistake in modifier combinations (but not in comments)
    if not line.upper().startswith('REM') and re.search(r'(CTRL|ALT|SHIFT|GUI|WINDOWS)[-]', line, re.IGNORECASE):
        issues.append(ValidationIssue(
            line_number=line_number,
            line_content=original_line,
            message="Hyphen in modifier combination (should use space)",
            severity=Severity.ERROR,
            suggestion="Replace 'CTRL-SHIFT' with 'CTRL SHIFT'"
        ))
    
    # Parse the command
    parts = line.split(None, 1)  # Split on first whitespace
    if not parts:
        return issues
    
    command = parts[0].upper()
    args = parts[1] if len(parts) > 1 else ""
    
    # REM (comment) - anything goes after
    if command == 'REM':
        return issues
    
    # ID command (Flipper-specific device identifier)
    if command == 'ID':
        if not args:
            issues.append(ValidationIssue(
                line_number=line_number,
                line_content=original_line,
                message="ID command requires VID:PID argument",
                severity=Severity.ERROR,
                suggestion="Example: ID 1234:5678"
            ))
        return issues
    
    # DELAY command
    if command in ('DELAY', 'DEFAULT_DELAY', 'DEFAULTDELAY'):
        if not args:
            issues.append(ValidationIssue(
                line_number=line_number,
                line_content=original_line,
                message=f"{command} requires a numeric argument (milliseconds)",
                severity=Severity.ERROR,
                suggestion=f"Example: {command} 500"
            ))
        elif not args.strip().isdigit():
            issues.append(ValidationIssue(
                line_number=line_number,
                line_content=original_line,
                message=f"{command} argument must be a number",
                severity=Severity.ERROR,
                suggestion=f"Example: {command} 500"
            ))
        else:
            delay_ms = int(args.strip())
            if delay_ms > 30000:
                issues.append(ValidationIssue(
                    line_number=line_number,
                    line_content=original_line,
                    message=f"Very long delay ({delay_ms}ms = {delay_ms/1000}s)",
                    severity=Severity.INFO,
                    suggestion="Consider if this delay is intentional"
                ))
            elif delay_ms < 50:
                issues.append(ValidationIssue(
                    line_number=line_number,
                    line_content=original_line,
                    message=f"Very short delay ({delay_ms}ms) may be unreliable",
                    severity=Severity.WARNING,
                    suggestion="Consider increasing to at least 100ms"
                ))
        return issues
    
    # REPEAT command
    if command == 'REPEAT':
        if not args or not args.strip().isdigit():
            issues.append(ValidationIssue(
                line_number=line_number,
                line_content=original_line,
                message="REPEAT requires a numeric argument",
                severity=Severity.ERROR,
                suggestion="Example: REPEAT 5"
            ))
        return issues
    
    # STRING command
    if command in ('STRING', 'STRINGLN'):
        if not args:
            issues.append(ValidationIssue(
                line_number=line_number,
                line_content=original_line,
                message=f"{command} has no text to type",
                severity=Severity.WARNING,
                suggestion="Add text after STRING command"
            ))
        # Check for placeholder patterns
        placeholders = re.findall(r'(YOUR[_\s]?(?:URL|WEBHOOK|LINK|PATH|IP|PASSWORD|USERNAME)[_\s]?HERE|PUT[_\s]?(?:.*?)[_\s]?HERE|DISCORD[_\s]?WEBHOOK[_\s]?(?:URL|LINK)?|LINK[_\s]?TO[_\s]?\w+)', args, re.IGNORECASE)
        if placeholders:
            issues.append(ValidationIssue(
                line_number=line_number,
                line_content=original_line,
                message=f"Placeholder detected: {placeholders[0]}",
                severity=Severity.WARNING,
                suggestion="Replace placeholder with actual value before use"
            ))
        return issues
    
    # HOLD/RELEASE commands (Flipper-specific)
    if command in ('HOLD', 'RELEASE'):
        if not args:
            issues.append(ValidationIssue(
                line_number=line_number,
                line_content=original_line,
                message=f"{command} requires a key argument",
                severity=Severity.ERROR,
                suggestion=f"Example: {command} SHIFT"
            ))
        return issues
    
    # Check if it's a valid standalone command
    if command in VALID_COMMANDS:
        return issues
    
    # Check for modifier key combinations
    line_parts = line.split()
    if line_parts and line_parts[0].upper() in MODIFIER_KEYS:
        # Validate modifier combination
        for i, part in enumerate(line_parts):
            part_upper = part.upper()
            if i == 0:
                continue  # First part is already validated as modifier
            if part_upper in MODIFIER_KEYS:
                continue  # Additional modifier
            if part_upper in VALID_MODIFIER_TARGETS or part in VALID_MODIFIER_TARGETS:
                continue  # Valid target key
            # Unknown key in combination
            issues.append(ValidationIssue(
                line_number=line_number,
                line_content=original_line,
                message=f"Unknown key in modifier combination: '{part}'",
                severity=Severity.ERROR,
                suggestion=f"Valid keys: a-z, 0-9, F1-F12, ENTER, TAB, etc."
            ))
        return issues
    
    # Unknown command
    issues.append(ValidationIssue(
        line_number=line_number,
        line_content=original_line,
        message=f"Unknown command: '{command}'",
        severity=Severity.ERROR,
        suggestion=f"Valid commands: STRING, DELAY, ENTER, GUI, CTRL, ALT, SHIFT, etc."
    ))
    
    return issues


def validate_script(filepath: str) -> Tuple[List[ValidationIssue], dict]:
    """Validate an entire DuckyScript file."""
    issues = []
    stats = {
        'total_lines': 0,
        'command_lines': 0,
        'comment_lines': 0,
        'empty_lines': 0,
        'has_header': False,
        'has_author': False,
        'has_description': False,
    }
    
    try:
        with open(filepath, 'r', encoding='utf-8', errors='replace') as f:
            lines = f.readlines()
    except Exception as e:
        issues.append(ValidationIssue(
            line_number=0,
            line_content="",
            message=f"Could not read file: {e}",
            severity=Severity.ERROR
        ))
        return issues, stats
    
    stats['total_lines'] = len(lines)
    
    # Check for header comments
    header_lines = []
    for i, line in enumerate(lines[:10]):  # Check first 10 lines for header
        if line.strip().upper().startswith('REM'):
            header_lines.append(line)
            content = line.strip()[3:].strip().lower()
            if 'author' in content:
                stats['has_author'] = True
            if 'description' in content:
                stats['has_description'] = True
    
    if header_lines:
        stats['has_header'] = True
    
    # Validate each line
    for line_num, line in enumerate(lines, 1):
        stripped = line.strip()
        
        if not stripped:
            stats['empty_lines'] += 1
        elif stripped.upper().startswith('REM'):
            stats['comment_lines'] += 1
        else:
            stats['command_lines'] += 1
        
        line_issues = validate_line(line, line_num)
        issues.extend(line_issues)
    
    # Check for missing header
    if not stats['has_header']:
        issues.append(ValidationIssue(
            line_number=1,
            line_content="",
            message="Script missing header comments",
            severity=Severity.INFO,
            suggestion="Add REM Author:, REM Description:, REM Version:, REM Category:"
        ))
    elif not stats['has_author']:
        issues.append(ValidationIssue(
            line_number=1,
            line_content="",
            message="Script missing author attribution",
            severity=Severity.INFO,
            suggestion="Add 'REM Author: YourName'"
        ))
    
    return issues, stats


def print_issues(filepath: str, issues: List[ValidationIssue], stats: dict, verbose: bool = False):
    """Print validation results in a formatted way."""
    errors = [i for i in issues if i.severity == Severity.ERROR]
    warnings = [i for i in issues if i.severity == Severity.WARNING]
    infos = [i for i in issues if i.severity == Severity.INFO]
    
    # Header
    print(f"\n{Colors.BOLD}{'='*60}{Colors.RESET}")
    print(f"{Colors.CYAN}📄 {filepath}{Colors.RESET}")
    print(f"{Colors.BOLD}{'='*60}{Colors.RESET}")
    
    # Stats
    if verbose:
        print(f"\n{Colors.BLUE}📊 Statistics:{Colors.RESET}")
        print(f"   Total lines: {stats['total_lines']}")
        print(f"   Commands: {stats['command_lines']}")
        print(f"   Comments: {stats['comment_lines']}")
        print(f"   Empty: {stats['empty_lines']}")
        print(f"   Has header: {'✅' if stats['has_header'] else '❌'}")
    
    # Results summary
    if not errors and not warnings:
        print(f"\n{Colors.GREEN}✅ PASSED - No errors or warnings{Colors.RESET}")
    elif not errors:
        print(f"\n{Colors.YELLOW}⚠️  PASSED with {len(warnings)} warning(s){Colors.RESET}")
    else:
        print(f"\n{Colors.RED}❌ FAILED - {len(errors)} error(s), {len(warnings)} warning(s){Colors.RESET}")
    
    # Print issues
    for issue in issues:
        if issue.severity == Severity.ERROR:
            color = Colors.RED
            icon = "❌"
        elif issue.severity == Severity.WARNING:
            color = Colors.YELLOW
            icon = "⚠️ "
        else:
            if not verbose:
                continue
            color = Colors.BLUE
            icon = "ℹ️ "
        
        print(f"\n{color}{icon} Line {issue.line_number}: {issue.message}{Colors.RESET}")
        if issue.line_content.strip():
            print(f"   {Colors.WHITE}> {issue.line_content.rstrip()}{Colors.RESET}")
        if issue.suggestion:
            print(f"   {Colors.CYAN}💡 {issue.suggestion}{Colors.RESET}")
    
    return len(errors) == 0


def find_all_scripts(base_path: str) -> List[str]:
    """Find all .txt files that look like DuckyScript payloads."""
    scripts = []
    for root, dirs, files in os.walk(base_path):
        # Skip hidden directories and common non-payload directories
        dirs[:] = [d for d in dirs if not d.startswith('.') and d.lower() not in ('tools', '__pycache__', 'venv', 'node_modules')]
        
        for file in files:
            if file.endswith('.txt') and not file.lower().startswith('readme'):
                filepath = os.path.join(root, file)
                scripts.append(filepath)
    
    return sorted(scripts)


def fix_script(filepath: str, dry_run: bool = True) -> bool:
    """Attempt to auto-fix common issues in a script."""
    try:
        with open(filepath, 'r', encoding='utf-8', errors='replace') as f:
            content = f.read()
    except Exception as e:
        print(f"{Colors.RED}Error reading {filepath}: {e}{Colors.RESET}")
        return False
    
    original = content
    
    # Fix hyphen in modifier combinations
    content = re.sub(r'(CTRL|ALT|SHIFT|GUI|WINDOWS)-', r'\1 ', content, flags=re.IGNORECASE)
    
    # Remove leading whitespace from lines
    lines = content.split('\n')
    lines = [line.lstrip() for line in lines]
    content = '\n'.join(lines)
    
    # Remove multiple consecutive empty lines
    content = re.sub(r'\n{3,}', '\n\n', content)
    
    if content != original:
        if dry_run:
            print(f"{Colors.YELLOW}Would fix: {filepath}{Colors.RESET}")
            return True
        else:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"{Colors.GREEN}Fixed: {filepath}{Colors.RESET}")
            return True
    
    return False


def main():
    parser = argparse.ArgumentParser(
        description="DuckyScript 1.0 Validator for Flipper Zero",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s script.txt                 Validate a single script
  %(prog)s --all                      Validate all scripts in BadUSB-Scripts/
  %(prog)s --dir path/to/scripts      Validate all scripts in directory
  %(prog)s --fix script.txt           Auto-fix common issues (dry-run)
  %(prog)s --fix script.txt --apply   Auto-fix and save changes
  %(prog)s -v script.txt              Verbose output with stats
        """
    )
    
    parser.add_argument('script', nargs='?', help='Script file to validate')
    parser.add_argument('--all', action='store_true', help='Validate all scripts in repository')
    parser.add_argument('--dir', help='Validate all scripts in directory')
    parser.add_argument('--fix', help='Auto-fix common issues in script')
    parser.add_argument('--apply', action='store_true', help='Apply fixes (use with --fix)')
    parser.add_argument('-v', '--verbose', action='store_true', help='Verbose output')
    parser.add_argument('--no-color', action='store_true', help='Disable colored output')
    
    args = parser.parse_args()
    
    # Disable colors if requested or not a TTY
    if args.no_color or not sys.stdout.isatty():
        Colors.RED = Colors.GREEN = Colors.YELLOW = Colors.BLUE = ''
        Colors.MAGENTA = Colors.CYAN = Colors.WHITE = Colors.BOLD = Colors.RESET = ''
    
    # Auto-fix mode
    if args.fix:
        fixed = fix_script(args.fix, dry_run=not args.apply)
        if fixed and not args.apply:
            print(f"\n{Colors.CYAN}Run with --apply to save changes{Colors.RESET}")
        sys.exit(0 if fixed else 1)
    
    # Find scripts to validate
    scripts = []
    if args.all:
        # Find repository root
        script_dir = Path(__file__).parent.parent
        badusb_dir = script_dir / 'BadUSB-Scripts'
        if badusb_dir.exists():
            scripts = find_all_scripts(str(badusb_dir))
        else:
            print(f"{Colors.RED}BadUSB-Scripts directory not found{Colors.RESET}")
            sys.exit(1)
    elif args.dir:
        scripts = find_all_scripts(args.dir)
    elif args.script:
        scripts = [args.script]
    else:
        parser.print_help()
        sys.exit(1)
    
    if not scripts:
        print(f"{Colors.YELLOW}No scripts found to validate{Colors.RESET}")
        sys.exit(1)
    
    # Validate scripts
    total = len(scripts)
    passed = 0
    failed = 0
    
    print(f"\n{Colors.BOLD}🔍 Validating {total} script(s)...{Colors.RESET}")
    
    for filepath in scripts:
        issues, stats = validate_script(filepath)
        success = print_issues(filepath, issues, stats, verbose=args.verbose)
        if success:
            passed += 1
        else:
            failed += 1
    
    # Summary
    print(f"\n{Colors.BOLD}{'='*60}{Colors.RESET}")
    print(f"{Colors.BOLD}📊 SUMMARY{Colors.RESET}")
    print(f"{Colors.BOLD}{'='*60}{Colors.RESET}")
    print(f"   Total:  {total}")
    print(f"   {Colors.GREEN}Passed: {passed}{Colors.RESET}")
    print(f"   {Colors.RED}Failed: {failed}{Colors.RESET}")
    
    sys.exit(0 if failed == 0 else 1)


if __name__ == '__main__':
    main()

