#!/usr/bin/env bash

# Toggle manager for Rofi menus
MENU="$1"
TAG_FILE="${XDG_RUNTIME_DIR:-/tmp}/rofi-current-menu"

if pgrep -x rofi >/dev/null; then
    CURRENT=$(cat "$TAG_FILE" 2>/dev/null)
    # Close existing rofi instance
    pkill -x rofi
    # If the user toggled the exact same menu, stay closed
    if [ "$CURRENT" = "$MENU" ]; then
        rm -f "$TAG_FILE"
        exit 0
    fi
fi

echo "$MENU" > "$TAG_FILE"

case "$MENU" in
    launcher)
        exec rofi -show drun
        ;;
    power)
        exec ~/.config/sway/scripts/power-menu.sh
        ;;
    clipboard)
        exec ~/.config/sway/scripts/clipboard-menu.sh
        ;;
esac
