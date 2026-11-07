#!/usr/bin/env bash
# Toggle dunst do-not-disturb. Notifications that arrive while paused are
# queued and shown when it is turned off.
notify() {
    notify-send -a dnd -u low -t 1200 -h string:x-dunst-stack-tag:dnd "Do not disturb" "$1"
}
if [[ "$(dunstctl is-paused)" == "true" ]]; then
    dunstctl set-paused false
    notify "off"
else
    notify "on"
    sleep 1.3                 # let the "on" message show before pausing
    dunstctl set-paused true
fi
