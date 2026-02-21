# XRDP Session Chooser

A lightweight desktop environment selector for [XRDP](https://github.com/neutrinolabs/xrdp) sessions using `xmessage`.

When you connect via RDP, a centered dialog instantly appears letting you choose which desktop environment to start — no lag, no heavy dependencies.

## Problem

XRDP doesn't natively let you pick a desktop environment from its login screen (the dropdown controls the backend type like Xorg/Xvnc, not the DE). Common workarounds using `xterm` + `whiptail` or `zenity` suffer from:

- **3-5 second startup lag** due to GTK/D-Bus/fontconfig initialization before the Window Manager is ready
- **Small window in the top-left corner** because `xterm -fullscreen` requires a Window Manager to handle the fullscreen hint, but no WM is running yet
- **Breaking D-Bus** if `unset DBUS_SESSION_BUS_ADDRESS` is placed in `~/.xsession` (it destroys the bus already created by the Xsession.d pipeline)

## Solution

This script uses `xmessage`, a minimal X11 utility that:

- Starts **instantly** (~5ms) — no GTK, no D-Bus, no font scanning
- Centers itself on screen with `-center` — works **without a Window Manager**
- Auto-detects installed DEs from `/usr/share/xsessions/*.desktop`
- Falls back to the first available DE on timeout (default: 60 seconds)

## Requirements

- **XRDP** (tested with v0.9.24)
- **xmessage** (part of X11 core utilities)

### Install xmessage

| Distro | Command |
|--------|---------|
| Debian/Ubuntu/Mint | `sudo apt install x11-utils` |
| Arch Linux | `sudo pacman -S xorg-xmessage` |
| Fedora | `sudo dnf install xmessage` |
| openSUSE | `sudo zypper install xmessage` |

## Installation

### Quick Install

```bash
git clone https://github.com/alfinsalsabil/xrdp-session-chooser.git
cd xrdp-session-chooser
chmod +x install.sh
./install.sh
```

The installer will:
1. Check that `xmessage` is installed
2. Detect your distro and choose the correct target file (`~/.xsession` or `~/.xinitrc`)
3. Back up your existing session file (if any)
4. Install the chooser script
5. Show you the detected desktop environments

### Manual Install

```bash
# Back up existing file
cp ~/.xsession ~/.xsession.bak 2>/dev/null

# Copy and make executable
cp xsession ~/.xsession
chmod +x ~/.xsession
```

## How It Works

```
XRDP Login
  → xrdp-sesman
    → /etc/xrdp/startwm.sh
      → /etc/X11/Xsession (Debian/Mint)
        → Xsession.d pipeline (D-Bus, env setup)
          → exec ~/.xsession     ← THIS SCRIPT
            → xmessage dialog
              → exec chosen-session
```

The script reads `/usr/share/xsessions/*.desktop` files to discover available desktop environments, builds `xmessage` buttons dynamically, and `exec`s the selected session command.

## Configuration

The script auto-detects everything. No configuration needed.

If you want to customize the timeout, edit the `TIMEOUT=60` variable at the top of the script.

## Compatibility

| Distro | Startup File | Status |
|--------|-------------|--------|
| Debian / Ubuntu / Linux Mint | `~/.xsession` | ✅ Tested |
| Arch Linux | `~/.xinitrc` | ✅ Supported |
| Fedora | `~/.xsession` | ✅ Supported |
| openSUSE | `~/.xsession` | ✅ Supported |

## Uninstall

```bash
# Restore your backup
cp ~/.xsession.bak ~/.xsession
# Or simply delete it to use system defaults
rm ~/.xsession
```

## Technical Notes

> [!WARNING]
> Do NOT add `unset DBUS_SESSION_BUS_ADDRESS` inside `~/.xsession`. The Xsession.d pipeline (`75dbus_dbus-launch`) creates a fresh D-Bus session bus before `~/.xsession` runs. Unsetting it here destroys that bus, causing broken desktop functionality.

> [!NOTE]
> The `unset DBUS_SESSION_BUS_ADDRESS` line belongs in `/etc/xrdp/startwm.sh` (before the Xsession.d pipeline runs), which is the [recommended fix](https://askubuntu.com/questions/1432489/xrdp-shows-a-blank-screen-after-login) for XRDP black screen issues.

## License

[MIT](LICENSE)
