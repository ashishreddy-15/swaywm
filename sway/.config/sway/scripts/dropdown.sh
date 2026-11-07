#!/usr/bin/env bash
# Toggle a floating drop-down terminal kept in the scratchpad.
# Window size/position come from the [app_id="dropdown"] rule in config.d.
if swaymsg -t get_tree | jq -e '.. | objects | select(.app_id? == "dropdown")' >/dev/null; then
    swaymsg -q '[app_id="dropdown"] scratchpad show'
else
    swaymsg -q exec 'foot --app-id=dropdown'
fi
