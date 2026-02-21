#!/bin/bash
#
# XRDP Session Chooser - Installer
# https://github.com/alfinsalsabil/xrdp-session-chooser
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_FILE="$SCRIPT_DIR/xsession"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }

echo ""
echo "=== XRDP Session Chooser - Installer ==="
echo ""

# --- Check prerequisites ---
if ! command -v xrdp >/dev/null 2>&1; then
    warn "xrdp is not installed. This script is designed for XRDP."
fi

if ! command -v xmessage >/dev/null 2>&1; then
    echo ""
    warn "xmessage is not installed. Install it first:"
    echo ""
    echo "  Debian/Ubuntu/Mint:  sudo apt install x11-utils"
    echo "  Arch Linux:          sudo pacman -S xorg-xmessage"
    echo "  Fedora:              sudo dnf install xmessage"
    echo "  openSUSE:            sudo zypper install xmessage"
    echo ""
    error "Please install xmessage and re-run this installer."
fi

info "xmessage found: $(which xmessage)"

# --- Detect target file ---
# Debian/Ubuntu/Mint use ~/.xsession
# Arch Linux uses ~/.xinitrc (but ~/.xsession also works with some configs)
TARGET="$HOME/.xsession"

if [ -f /etc/arch-release ]; then
    TARGET="$HOME/.xinitrc"
    warn "Arch Linux detected. Installing to $TARGET"
elif [ -f /etc/debian_version ]; then
    info "Debian/Ubuntu/Mint detected. Installing to $TARGET"
else
    warn "Unknown distro. Defaulting to $TARGET"
    warn "You may need to adjust the target file for your distribution."
fi

# --- Backup existing file ---
if [ -f "$TARGET" ]; then
    BACKUP="${TARGET}.bak.$(date +%Y%m%d%H%M%S)"
    cp "$TARGET" "$BACKUP"
    info "Backed up existing $(basename $TARGET) to $(basename $BACKUP)"
fi

# --- Install ---
cp "$SOURCE_FILE" "$TARGET"
chmod +x "$TARGET"
info "Installed to $TARGET"

# --- Verify ---
DE_COUNT=$(find /usr/share/xsessions -name "*.desktop" -type f 2>/dev/null | wc -l)
if [ "$DE_COUNT" -gt 0 ]; then
    info "Detected $DE_COUNT desktop environment(s):"
    for f in /usr/share/xsessions/*.desktop; do
        name=$(grep -m1 "^Name=" "$f" | cut -d= -f2)
        echo "     - $name"
    done
else
    warn "No .desktop files found in /usr/share/xsessions/"
    warn "The chooser will use fallback detection."
fi

echo ""
info "Installation complete! Reconnect to XRDP to see the session chooser."
echo ""
