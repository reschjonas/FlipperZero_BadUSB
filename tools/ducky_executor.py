#!/usr/bin/env python3
"""
DuckyScript 1.0 Executor - Test payloads without Flipper Zero

⚠️  WARNING: This tool EXECUTES keystrokes on YOUR computer!
    Only run scripts you understand and trust.
    Use in a VM for dangerous payloads.

Usage:
    python ducky_executor.py <script.txt>           # Execute script
    python ducky_executor.py <script.txt> --dry-run # Show what would happen
    python ducky_executor.py <script.txt> --delay 2 # Add 2s startup delay

Author: dil1thium
License: CC BY-NC-SA 4.0
"""

import argparse
import sys
import time
from pathlib import Path

try:
    import pyautogui
    PYAUTOGUI_AVAILABLE = True
except ImportError:
    PYAUTOGUI_AVAILABLE = False

# Disable PyAutoGUI fail-safe for continuous execution
# Move mouse to corner to abort
if PYAUTOGUI_AVAILABLE:
    pyautogui.FAILSAFE = True
    pyautogui.PAUSE = 0.01  # Small pause between actions

# ANSI Colors
class Colors:
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    BOLD = '\033[1m'
    RESET = '\033[0m'

# Key mappings from DuckyScript to PyAutoGUI
KEY_MAP = {
    # Special keys
    'ENTER': 'enter',
    'RETURN': 'enter',
    'TAB': 'tab',
    'SPACE': 'space',
    'BACKSPACE': 'backspace',
    'DELETE': 'delete',
    'DEL': 'delete',
    'INSERT': 'insert',
    'HOME': 'home',
    'END': 'end',
    'PAGEUP': 'pageup',
    'PAGE_UP': 'pageup',
    'PAGEDOWN': 'pagedown',
    'PAGE_DOWN': 'pagedown',
    'ESCAPE': 'escape',
    'ESC': 'escape',
    'PAUSE': 'pause',
    'BREAK': 'pause',
    'CAPSLOCK': 'capslock',
    'CAPS_LOCK': 'capslock',
    'NUMLOCK': 'numlock',
    'NUM_LOCK': 'numlock',
    'SCROLLLOCK': 'scrolllock',
    'SCROLL_LOCK': 'scrolllock',
    'PRINTSCREEN': 'printscreen',
    'PRINT_SCREEN': 'printscreen',
    
    # Arrow keys
    'UP': 'up',
    'UPARROW': 'up',
    'UP_ARROW': 'up',
    'DOWN': 'down',
    'DOWNARROW': 'down',
    'DOWN_ARROW': 'down',
    'LEFT': 'left',
    'LEFTARROW': 'left',
    'LEFT_ARROW': 'left',
    'RIGHT': 'right',
    'RIGHTARROW': 'right',
    'RIGHT_ARROW': 'right',
    
    # Function keys
    'F1': 'f1', 'F2': 'f2', 'F3': 'f3', 'F4': 'f4',
    'F5': 'f5', 'F6': 'f6', 'F7': 'f7', 'F8': 'f8',
    'F9': 'f9', 'F10': 'f10', 'F11': 'f11', 'F12': 'f12',
    
    # Modifier keys
    'CTRL': 'ctrl',
    'CONTROL': 'ctrl',
    'ALT': 'alt',
    'SHIFT': 'shift',
    'GUI': 'win',
    'WINDOWS': 'win',
    'COMMAND': 'command',  # macOS
    'META': 'win',
    
    # Menu key
    'MENU': 'apps',
    'APP': 'apps',
}


def parse_line(line: str) -> tuple:
    """Parse a DuckyScript line into command and arguments."""
    line = line.strip()
    if not line:
        return None, None
    
    parts = line.split(None, 1)
    command = parts[0].upper()
    args = parts[1] if len(parts) > 1 else ""
    
    return command, args


def execute_keystroke(keys: list, dry_run: bool = False):
    """Execute a keystroke or key combination."""
    if dry_run:
        print(f"   {Colors.CYAN}[KEYS] {' + '.join(keys)}{Colors.RESET}")
        return
    
    if not PYAUTOGUI_AVAILABLE:
        print(f"{Colors.RED}PyAutoGUI not installed. Run: pip install pyautogui{Colors.RESET}")
        return
    
    # Map DuckyScript keys to PyAutoGUI keys
    mapped_keys = []
    for key in keys:
        key_upper = key.upper()
        if key_upper in KEY_MAP:
            mapped_keys.append(KEY_MAP[key_upper])
        elif len(key) == 1:
            mapped_keys.append(key.lower())
        else:
            print(f"{Colors.YELLOW}Warning: Unknown key '{key}'{Colors.RESET}")
            return
    
    if len(mapped_keys) == 1:
        pyautogui.press(mapped_keys[0])
    else:
        pyautogui.hotkey(*mapped_keys)


def execute_string(text: str, dry_run: bool = False):
    """Type a string."""
    if dry_run:
        preview = text[:50] + "..." if len(text) > 50 else text
        print(f"   {Colors.CYAN}[TYPE] {preview}{Colors.RESET}")
        return
    
    if not PYAUTOGUI_AVAILABLE:
        return
    
    pyautogui.write(text, interval=0.01)


def execute_script(filepath: str, dry_run: bool = False, initial_delay: float = 3.0):
    """Execute a DuckyScript file."""
    
    print(f"\n{Colors.BOLD}{'='*60}{Colors.RESET}")
    print(f"{Colors.CYAN}🦆 DuckyScript Executor{Colors.RESET}")
    print(f"{Colors.BOLD}{'='*60}{Colors.RESET}")
    print(f"\n📄 Script: {filepath}")
    print(f"🔧 Mode: {'DRY RUN (no execution)' if dry_run else 'LIVE EXECUTION'}")
    
    if not dry_run:
        print(f"\n{Colors.YELLOW}⚠️  WARNING: This will execute keystrokes on your computer!{Colors.RESET}")
        print(f"{Colors.YELLOW}   Move mouse to screen corner to abort (PyAutoGUI failsafe){Colors.RESET}")
        print(f"\n{Colors.BLUE}Starting in {initial_delay} seconds... Press Ctrl+C to cancel{Colors.RESET}")
        
        try:
            for i in range(int(initial_delay), 0, -1):
                print(f"   {i}...")
                time.sleep(1)
        except KeyboardInterrupt:
            print(f"\n{Colors.RED}Cancelled by user{Colors.RESET}")
            return False
        
        print(f"\n{Colors.GREEN}🚀 Executing...{Colors.RESET}\n")
    else:
        print(f"\n{Colors.BLUE}📋 Simulating execution...{Colors.RESET}\n")
    
    try:
        with open(filepath, 'r', encoding='utf-8', errors='replace') as f:
            lines = f.readlines()
    except Exception as e:
        print(f"{Colors.RED}Error reading file: {e}{Colors.RESET}")
        return False
    
    default_delay = 0
    line_count = 0
    
    for line_num, line in enumerate(lines, 1):
        command, args = parse_line(line)
        
        if command is None:
            continue
        
        line_count += 1
        
        # Show progress
        if dry_run:
            print(f"{Colors.WHITE}Line {line_num}:{Colors.RESET} {line.strip()}")
        
        # Process commands
        if command == 'REM':
            if dry_run:
                print(f"   {Colors.GREEN}[COMMENT]{Colors.RESET}")
            continue
        
        elif command == 'DELAY':
            delay_ms = int(args) if args.isdigit() else 0
            if dry_run:
                print(f"   {Colors.BLUE}[DELAY] {delay_ms}ms{Colors.RESET}")
            else:
                time.sleep(delay_ms / 1000)
        
        elif command in ('DEFAULT_DELAY', 'DEFAULTDELAY'):
            default_delay = int(args) if args.isdigit() else 0
            if dry_run:
                print(f"   {Colors.BLUE}[DEFAULT_DELAY] {default_delay}ms{Colors.RESET}")
        
        elif command == 'STRING':
            execute_string(args, dry_run)
        
        elif command == 'STRINGLN':
            execute_string(args, dry_run)
            execute_keystroke(['ENTER'], dry_run)
        
        elif command in KEY_MAP:
            # Single key or modifier combination
            parts = line.strip().split()
            execute_keystroke(parts, dry_run)
        
        elif command == 'REPEAT':
            # Repeat last command (simplified - just show info)
            if dry_run:
                print(f"   {Colors.MAGENTA}[REPEAT] {args} times{Colors.RESET}")
        
        elif command == 'ID':
            if dry_run:
                print(f"   {Colors.BLUE}[ID] {args} (device identifier - ignored){Colors.RESET}")
        
        elif command in ('HOLD', 'RELEASE', 'WAIT_FOR_BUTTON_PRESS'):
            if dry_run:
                print(f"   {Colors.BLUE}[{command}] {args} (Flipper-specific - ignored){Colors.RESET}")
        
        else:
            # Unknown command - try as key combination
            parts = line.strip().split()
            execute_keystroke(parts, dry_run)
        
        # Apply default delay
        if default_delay > 0 and not dry_run:
            time.sleep(default_delay / 1000)
    
    print(f"\n{Colors.GREEN}✅ Completed! Executed {line_count} commands.{Colors.RESET}")
    return True


def main():
    parser = argparse.ArgumentParser(
        description="DuckyScript 1.0 Executor - Test payloads without Flipper Zero",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
⚠️  SAFETY WARNING:
    This tool executes keystrokes on YOUR computer!
    - Always use --dry-run first to preview
    - Test dangerous scripts in a VM
    - Move mouse to corner to abort (failsafe)

Examples:
    %(prog)s script.txt --dry-run     Preview without execution
    %(prog)s script.txt               Execute script (3s delay)
    %(prog)s script.txt --delay 5     Execute with 5s startup delay
        """
    )
    
    parser.add_argument('script', help='DuckyScript file to execute')
    parser.add_argument('--dry-run', '-n', action='store_true', 
                       help='Show what would happen without executing')
    parser.add_argument('--delay', '-d', type=float, default=3.0,
                       help='Startup delay in seconds (default: 3)')
    
    args = parser.parse_args()
    
    if not Path(args.script).exists():
        print(f"{Colors.RED}File not found: {args.script}{Colors.RESET}")
        sys.exit(1)
    
    if not PYAUTOGUI_AVAILABLE and not args.dry_run:
        print(f"{Colors.RED}PyAutoGUI not installed!{Colors.RESET}")
        print(f"Install with: pip install pyautogui")
        print(f"Or use --dry-run to preview without execution")
        sys.exit(1)
    
    success = execute_script(args.script, dry_run=args.dry_run, initial_delay=args.delay)
    sys.exit(0 if success else 1)


if __name__ == '__main__':
    main()

