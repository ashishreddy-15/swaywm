#!/usr/bin/env bash
# Toggle a constant warm screen tint (wlsunset). Bound to $mod+n.
# -t/-T are 1K apart so the tint is the same all day, no sunrise/sunset schedule.
TEMP=3500

notify() {
    notify-send -a nightlight -u low -t 1500 \
        -h string:x-dunst-stack-tag:nightlight "Night light" "$1"
}

if pgrep -x wlsunset >/dev/null; then
    pkill -x wlsunset
    notify "off"
else
    swaymsg -q exec "wlsunset -t $TEMP -T $((TEMP + 1)) -S 07:00 -s 19:00"
    notify "on (${TEMP}K)"
fi
