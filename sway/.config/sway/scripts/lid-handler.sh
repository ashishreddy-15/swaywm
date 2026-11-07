#!/usr/bin/env bash

ACTION="$1"
LAPTOP="eDP-1"
EXTERNAL="HDMI-A-1"

# Check if external monitor is connected
has_external=$(swaymsg -t get_outputs 2>/dev/null | jq -r '[.[] | select(.name == "'"$EXTERNAL"'")] | length' 2>/dev/null)

if [ "$ACTION" = "close" ]; then
    if [ "${has_external:-0}" -gt 0 ]; then
        # Disable laptop screen
        swaymsg output "$LAPTOP" disable
        # Reposition external monitor to 0 0
        swaymsg output "$EXTERNAL" position 0 0
        # Move all active workspaces to external monitor
        for i in {1..10}; do
            swaymsg "[workspace=\"$i\"] move workspace to output $EXTERNAL" >/dev/null 2>&1
        done
    fi
elif [ "$ACTION" = "open" ]; then
    # Re-enable laptop screen at 0 0
    swaymsg output "$LAPTOP" enable position 0 0
    # If external monitor is present, restore dual monitor positions and workspace layout
    if [ "${has_external:-0}" -gt 0 ]; then
        swaymsg output "$EXTERNAL" position 1920 0
        for i in {1..5}; do
            swaymsg "[workspace=\"$i\"] move workspace to output $EXTERNAL" >/dev/null 2>&1
        done
        for i in {6..10}; do
            swaymsg "[workspace=\"$i\"] move workspace to output $LAPTOP" >/dev/null 2>&1
        done
    fi
fi

exit 0
