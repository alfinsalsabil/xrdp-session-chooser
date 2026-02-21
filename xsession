#!/bin/bash
#
# XRDP Session Chooser
# https://github.com/alfinsalsabil/xrdp-session-chooser
#
# Lightweight desktop environment selector for XRDP using xmessage.
# Auto-detects installed DEs from /usr/share/xsessions/*.desktop.
#
# IMPORTANT: Do NOT unset DBUS_SESSION_BUS_ADDRESS or XDG_RUNTIME_DIR here!
# Those variables are already properly managed by the Xsession.d pipeline:
#   startwm.sh (unset) → Xsession.d/20dbus_xdg-runtime (set)
#                       → Xsession.d/75dbus_dbus-launch (launch)
# Unsetting them here would destroy the freshly created D-Bus session bus,
# causing broken notifications, file managers, and other D-Bus-dependent apps.

XSESSIONS_DIR="/usr/share/xsessions"
TIMEOUT=60

# --- Auto-detect installed desktop environments ---
BUTTONS=""
BUTTON_COUNT=0
declare -A DE_COMMANDS

if [ -d "$XSESSIONS_DIR" ]; then
    while IFS= read -r desktop_file; do
        name=$(grep -m1 "^Name=" "$desktop_file" | cut -d= -f2)
        exec_cmd=$(grep -m1 "^Exec=" "$desktop_file" | cut -d= -f2)

        if [ -n "$name" ] && [ -n "$exec_cmd" ]; then
            BUTTON_COUNT=$((BUTTON_COUNT + 1))
            exit_code=$((100 + BUTTON_COUNT))
            DE_COMMANDS[$exit_code]="$exec_cmd"

            if [ -z "$BUTTONS" ]; then
                BUTTONS="${name}:${exit_code}"
                DEFAULT_BUTTON="$name"
                DEFAULT_CMD="$exec_cmd"
            else
                BUTTONS="${BUTTONS},${name}:${exit_code}"
            fi
        fi
    done < <(find "$XSESSIONS_DIR" -name "*.desktop" -type f | sort)
fi

# --- Fallback if no .desktop files found ---
if [ "$BUTTON_COUNT" -eq 0 ]; then
    # No desktop files found; try common session commands
    for cmd in startxfce4 xfce4-session cinnamon-session gnome-session startplasma-x11 mate-session; do
        if command -v "$cmd" >/dev/null 2>&1; then
            exec "$cmd"
        fi
    done
    # Last resort
    exec xterm
fi

# --- Single DE: skip the chooser entirely ---
if [ "$BUTTON_COUNT" -eq 1 ]; then
    exec $DEFAULT_CMD
fi

# --- Show chooser dialog ---
xmessage -center \
         -title "XRDP Session Chooser" \
         -buttons "$BUTTONS" \
         -default "$DEFAULT_BUTTON" \
         -timeout "$TIMEOUT" \
         "Select your Desktop Environment for this XRDP session:"

CHOICE=$?

# --- Launch selected DE ---
# Exit code 0 = timeout → use default
if [ "$CHOICE" -eq 0 ] || [ -z "${DE_COMMANDS[$CHOICE]}" ]; then
    exec $DEFAULT_CMD
else
    exec ${DE_COMMANDS[$CHOICE]}
fi
