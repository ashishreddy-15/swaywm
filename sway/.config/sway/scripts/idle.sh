#!/usr/bin/env bash
# Idle handling with a "keep awake" switch.
#
#   idle.sh start    (re)start swayidle for the current mode (sway runs this)
#   idle.sh toggle   flip keep-awake on/off, restart swayidle, update waybar
#   idle.sh status   JSON for waybar's custom/awake module
#
# Normal timeline:
#   5 min idle    → lock screen (swaylock)
#   10 min idle   → displays off (5 more min after lock)
#   15 min idle   → suspend, only when running on battery
#   Already locked + 30 s → displays off immediately
#
# Keep awake drops the timeouts but still locks before sleep and on
# `loginctl lock-session`, so closing the lid never leaves it unlocked.
# The state lives in XDG_RUNTIME_DIR, so it resets at the next login.
set -euo pipefail

STATE="${XDG_RUNTIME_DIR:-/tmp}/keep-awake"

start() {
    pkill -xu "$USER" swayidle || true
    local always=(
        before-sleep 'swaylock -f'
        lock         'swaylock -f'
        unlock       'pkill -xu "$USER" -SIGUSR1 swaylock'
    )
    if [[ -e $STATE ]]; then
        setsid -f swayidle -w "${always[@]}"
    else
        setsid -f swayidle -w \
            timeout 300 'swaylock -f' \
            timeout 600 'swaymsg "output * power off"' \
                        resume 'swaymsg "output * power on"' \
            timeout 30  'pgrep -xu "$USER" swaylock >/dev/null && swaymsg "output * power off"' \
                        resume  'pgrep -xu "$USER" swaylock >/dev/null && swaymsg "output * power on"' \
            timeout 900 '[ "$(cat /sys/class/power_supply/AC/online)" = 1 ] || systemctl suspend' \
            "${always[@]}"
    fi
}

case ${1:-} in
    start)
        start
        ;;
    toggle)
        if [[ -e $STATE ]]; then rm -f "$STATE"; else touch "$STATE"; fi
        start
        pkill -RTMIN+9 -x waybar || true
        ;;
    status)
        if [[ -e $STATE ]]; then
            echo '{"text": "AWAKE", "class": "on", "tooltip": "Keep awake is on: no auto-lock, screen-off or suspend.\nClick to turn off."}'
        else
            echo '{"text": "", "class": "off"}'
        fi
        ;;
    *)
        echo "usage: ${0##*/} start|toggle|status" >&2
        exit 1
        ;;
esac
