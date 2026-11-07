#!/usr/bin/env bash
# ============================================================
# Clamshell handler: turns the laptop panel off/on with the lid.
#
# Usage: lid-handler.sh [open|close]
#   open/close  called by sway's bindswitch on lid events
#   (no arg)    read the lid state from ACPI; kanshi calls it like this
#               after every profile change, so plugging in a monitor
#               while the lid is closed can't turn the panel back on.
#
# Workspaces are not moved here: the `workspace N output ...` rules in
# the sway config make sway move them to the right output by itself.
# ============================================================

LAPTOP="eDP-1"
STATE="$1"

if [ -z "$STATE" ]; then
    if grep -qs closed /proc/acpi/button/lid/*/state; then
        STATE="close"
    else
        STATE="open"
    fi
fi

# Number of connected outputs other than the laptop panel
externals=$(swaymsg -t get_outputs -r | jq --arg l "$LAPTOP" '[.[] | select(.name != $l)] | length')

case "$STATE" in
    close)
        # Only go clamshell if there is another screen to use;
        # otherwise leave the panel alone (logind handles suspend).
        if [ "${externals:-0}" -gt 0 ]; then
            swaymsg output "$LAPTOP" disable >/dev/null
        fi
        ;;
    open)
        swaymsg output "$LAPTOP" enable >/dev/null
        ;;
esac
