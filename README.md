# xrdp-session-chooser

![License](https://img.shields.io/github/license/alfinsalsabil/xrdp-session-chooser)
![Platform](https://img.shields.io/badge/platform-linux-blue)
![Shell](https://img.shields.io/badge/shell-bash-success)

Hey there! 👋 I do a lot of remote "vibecoding" and use XRDP to connect to my Linux machines. XRDP is awesome, but it has one annoying quirk: you can't natively pick your Desktop Environment (like XFCE, GNOME, KDE, or i3) right from the login screen. 

I tried the usual workarounds floating around the internet, but they all felt clunky. So, I put together this super lightweight session chooser. It pops up instantly, looks clean, and just works. I hope it makes your remote desktop life a little easier!

## 🐛 The Headaches (Why existing workarounds drove me crazy)
If you've tried to build a session chooser before using tools like `xterm` + `whiptail` or `zenity`, you probably ran into these issues:
- **Annoying Lag**: You get a 3-5 second blank screen while GTK, D-Bus, and fonts try to initialize before the Window Manager is even ready.
- **Squished Windows**: Dialogs open as tiny boxes jammed in the top-left corner because there's no Window Manager running yet to tell them where to go.
- **Broken Desktops**: A lot of tutorials tell you to `unset DBUS_SESSION_BUS_ADDRESS` inside your `~/.xsession` file. Doing this actually destroys the bus and breaks your desktop features!

## 💡 The "Aha!" Moment: Good ol' `xmessage`
The fix? Going old-school. This script uses `xmessage`, a super minimal utility built right into the X11 core.
- It starts **instantly** (~5ms). No heavy GTK loading or font scanning.
- It uses the `-center` flag to place itself perfectly in the middle of your screen, **even without a Window Manager**.
- It automatically reads `/usr/share/xsessions/*.desktop` and builds clicky buttons for every desktop environment you have installed. If you don't click anything, it safely falls back to your first available DE after 60 seconds.

---

## 🛠️ Requirements

You just need XRDP and `xmessage` (which is usually part of the X11 core utilities).

| Distro | How to install `xmessage` |
|--------|---------|
| Debian/Ubuntu/Mint | `sudo apt install x11-utils` |
| Arch Linux | `sudo pacman -S xorg-xmessage` |
| Fedora | `sudo dnf install xmessage` |
| openSUSE | `sudo zypper install xmessage` |

---

## 🚀 Installation

### The Easy Way (Quick Install)
I wrote a quick installer that checks your distro, backs up your old files, and sets everything up safely.
```bash
git clone https://github.com/alfinsalsabil/xrdp-session-chooser.git
cd xrdp-session-chooser
chmod +x install.sh
./install.sh
```

### The Manual Way
If you prefer doing things by hand:
```bash
# Back up your existing file just in case
cp ~/.xsession ~/.xsession.bak 2>/dev/null

# Copy the script and make it executable
cp xsession ~/.xsession
chmod +x ~/.xsession
```

---

## ⚙️ Compatibility
The script auto-detects your setup, so no manual configuration is needed!

| Distro | Startup File | Status |
|--------|-------------|--------|
| Debian / Ubuntu / Linux Mint | `~/.xsession` | ✅ Tested |
| Arch Linux | `~/.xinitrc` | ✅ Supported |
| Fedora | `~/.xsession` | ✅ Supported |
| openSUSE | `~/.xsession` | ✅ Supported |

## ⚠️ A Quick Tip I Learned the Hard Way (Technical Note)

> [!WARNING]
> Please do NOT add `unset DBUS_SESSION_BUS_ADDRESS` inside your `~/.xsession` file. 
> The system pipeline (`75dbus_dbus-launch`) creates a fresh D-Bus session before `~/.xsession` runs. If you unset it here, you destroy that bus. 

> [!NOTE]
> If you are trying to fix the infamous XRDP "black screen" issue on Debian/Ubuntu, the `unset DBUS_SESSION_BUS_ADDRESS` line belongs in `/etc/xrdp/startwm.sh` (right at the top, before the Xsession.d pipeline runs). 

## 🤝 Let's Make It Better
I'm just a guy enjoying the vibecoding life. If you find a bug, have a cool idea, or just want to improve the code, feel free to open an Issue or a Pull Request! Let's build cool things together.

---
License: [MIT](LICENSE)
