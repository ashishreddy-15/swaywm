#!/usr/bin/env bash

MODE="$1"

if [ "$MODE" = "dual" ]; then
    # Both screens active:
    # Workspaces 1-5 → external Samsung (HDMI-A-1)
    # Workspaces 6-10 → laptop screen (eDP-1)
    for i in {1..5}; do
        swaymsg "[workspace=\"$i\"] move workspace to output HDMI-A-1" >/dev/null 2>&1
    done
    for i in {6..10}; do
        swaymsg "[workspace=\"$i\"] move workspace to output eDP-1" >/dev/null 2>&1
    done

elif [ "$MODE" = "clamshell" ]; then
    # Lid closed, external monitor only:
    # All workspaces move to HDMI-A-1
    for i in {1..10}; do
        swaymsg "[workspace=\"$i\"] move workspace to output HDMI-A-1" >/dev/null 2>&1
    done

elif [ "$MODE" = "solo" ]; then
    # Laptop screen only (no external monitor):
    # All workspaces move to eDP-1
    for i in {1..10}; do
        swaymsg "[workspace=\"$i\"] move workspace to output eDP-1" >/dev/null 2>&1
    done
fi
