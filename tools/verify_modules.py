#!/usr/bin/env python3
"""
Remote Module Verification Tool

Verifies that all remote payload modules:
1. Actually exist in the repository
2. Are syntactically valid (PowerShell/Bash)
3. Match the loader's module mapping
"""

import os
import subprocess
import sys
from pathlib import Path
from typing import List, Dict, Tuple

class Colors:
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    BOLD = '\033[1m'
    RESET = '\033[0m'

def check_powershell_syntax(filepath: str) -> Tuple[bool, str]:
    """Check PowerShell script syntax using pwsh if available."""
    if not os.path.exists(filepath):
        return False, "File does not exist"
    
    # Try to use PowerShell syntax checker
    try:
        result = subprocess.run(
            ['pwsh', '-NoProfile', '-NonInteractive', '-Command', 
             f'$null = [System.Management.Automation.PSParser]::Tokenize((Get-Content -Raw "{filepath}"), [ref]$null)'],
            capture_output=True,
            timeout=5
        )
        if result.returncode == 0:
            return True, "Valid PowerShell syntax"
        else:
            return False, result.stderr.decode('utf-8', errors='replace')
    except FileNotFoundError:
        # PowerShell not installed, do basic check
        with open(filepath, 'r', encoding='utf-8', errors='replace') as f:
            content = f.read()
            if len(content) > 0:
                return True, "Basic check passed (pwsh not available for full validation)"
            return False, "Empty file"
    except Exception as e:
        return False, str(e)

def check_bash_syntax(filepath: str) -> Tuple[bool, str]:
    """Check Bash script syntax."""
    if not os.path.exists(filepath):
        return False, "File does not exist"
    
    try:
        result = subprocess.run(
            ['bash', '-n', filepath],
            capture_output=True,
            timeout=5
        )
        if result.returncode == 0:
            return True, "Valid Bash syntax"
        else:
            return False, result.stderr.decode('utf-8', errors='replace')
    except Exception as e:
        return False, str(e)

def verify_windows_modules(base_path: str) -> Dict[str, Dict]:
    """Verify all Windows PowerShell modules."""
    # Module mapping from loader.ps1
    modules = {
        'wifi': 'windows/exfil/wifi_grabber.ps1',
        'screenshot': 'windows/exfil/screenshot.ps1',
        'sysinfo': 'windows/exfil/system_info.ps1',
        'browser': 'windows/exfil/browser_data.ps1',
        'clipboard': 'windows/exfil/clipboard.ps1',
        'ip': 'windows/exfil/ip_info.ps1',
        'shell': 'windows/execution/reverse_shell.ps1',
        'admin': 'windows/execution/create_admin.ps1',
        'rdp': 'windows/execution/enable_rdp.ps1',
        'defender': 'windows/execution/disable_defender.ps1',
        'firewall': 'windows/execution/disable_firewall.ps1',
        'wallpaper': 'windows/fun/wallpaper_changer.ps1',
        'tts': 'windows/fun/text_to_speech.ps1',
        'rickroll': 'windows/fun/rickroll.ps1',
        'bsod': 'windows/fun/fake_bsod.ps1',
        'recon': 'windows/recon/full_recon.ps1',
        'network': 'windows/recon/network_scan.ps1',
        'persist': 'windows/persistence/startup.ps1',
    }
    
    results = {}
    for name, path in modules.items():
        full_path = os.path.join(base_path, 'remote-payloads', path)
        exists = os.path.exists(full_path)
        
        if exists:
            valid, msg = check_powershell_syntax(full_path)
            results[name] = {
                'path': path,
                'exists': True,
                'valid': valid,
                'message': msg,
                'full_path': full_path
            }
        else:
            results[name] = {
                'path': path,
                'exists': False,
                'valid': False,
                'message': 'File not found',
                'full_path': full_path
            }
    
    return results

def verify_linux_modules(base_path: str) -> Dict[str, Dict]:
    """Verify all Linux Bash modules."""
    modules = {
        'wifi': 'linux/exfil/wifi_grabber.sh',
        'screenshot': 'linux/exfil/screenshot.sh',
        'sysinfo': 'linux/exfil/system_info.sh',
        'ssh': 'linux/exfil/ssh_keys.sh',
        'history': 'linux/exfil/browser_history.sh',
        'env': 'linux/exfil/env_variables.sh',
        'clipboard': 'linux/exfil/clipboard.sh',
        'shell': 'linux/execution/reverse_shell.sh',
        'rickroll': 'linux/fun/rickroll.sh',
        'wallpaper': 'linux/fun/wallpaper.sh',
        'tts': 'linux/fun/text_to_speech.sh',
        'recon': 'linux/recon/full_recon.sh',
        'persist': 'linux/persistence/cron_backdoor.sh',
    }
    
    results = {}
    for name, path in modules.items():
        full_path = os.path.join(base_path, 'remote-payloads', path)
        exists = os.path.exists(full_path)
        
        if exists:
            valid, msg = check_bash_syntax(full_path)
            results[name] = {
                'path': path,
                'exists': True,
                'valid': valid,
                'message': msg,
                'full_path': full_path
            }
        else:
            results[name] = {
                'path': path,
                'exists': False,
                'valid': False,
                'message': 'File not found',
                'full_path': full_path
            }
    
    return results

def print_results(platform: str, results: Dict):
    """Print verification results."""
    print(f"\n{Colors.BOLD}{'='*60}{Colors.RESET}")
    print(f"{Colors.CYAN}🔍 {platform} Modules Verification{Colors.RESET}")
    print(f"{Colors.BOLD}{'='*60}{Colors.RESET}\n")
    
    passed = 0
    failed = 0
    
    for name, info in sorted(results.items()):
        if info['exists'] and info['valid']:
            icon = f"{Colors.GREEN}✅{Colors.RESET}"
            status = f"{Colors.GREEN}PASS{Colors.RESET}"
            passed += 1
        elif info['exists']:
            icon = f"{Colors.YELLOW}⚠️{Colors.RESET}"
            status = f"{Colors.YELLOW}WARN{Colors.RESET}"
            failed += 1
        else:
            icon = f"{Colors.RED}❌{Colors.RESET}"
            status = f"{Colors.RED}FAIL{Colors.RESET}"
            failed += 1
        
        print(f"{icon} {status} | {name:12} → {info['path']}")
        
        if not info['valid']:
            print(f"           {Colors.YELLOW}└─ {info['message']}{Colors.RESET}")
    
    print(f"\n{Colors.BOLD}Summary:{Colors.RESET}")
    print(f"  {Colors.GREEN}Passed: {passed}{Colors.RESET}")
    print(f"  {Colors.RED}Failed: {failed}{Colors.RESET}")
    print(f"  Total:  {len(results)}")
    
    return failed == 0

def main():
    # Find repository root
    script_dir = Path(__file__).parent.parent
    
    print(f"\n{Colors.BOLD}🔬 Remote Payload Module Verification{Colors.RESET}")
    print(f"Repository: {script_dir}\n")
    
    # Verify Windows modules
    win_results = verify_windows_modules(str(script_dir))
    win_passed = print_results("Windows", win_results)
    
    # Verify Linux modules  
    linux_results = verify_linux_modules(str(script_dir))
    linux_passed = print_results("Linux", linux_results)
    
    # Overall summary
    print(f"\n{Colors.BOLD}{'='*60}{Colors.RESET}")
    print(f"{Colors.BOLD}📊 OVERALL RESULTS{Colors.RESET}")
    print(f"{Colors.BOLD}{'='*60}{Colors.RESET}")
    
    if win_passed and linux_passed:
        print(f"{Colors.GREEN}✅ All modules verified successfully!{Colors.RESET}\n")
        sys.exit(0)
    else:
        print(f"{Colors.RED}❌ Some modules failed verification{Colors.RESET}\n")
        sys.exit(1)

if __name__ == '__main__':
    main()
