#!/usr/bin/env bash
# ============================================================
# Context-aware brightness control for Sway
#
# Usage: brightness.sh <up|down> [step]
#
# Changes the brightness of the focused output:
# - Laptop panel (eDP*): brightnessctl, never below 1%
# - External monitor:    ddcutil (DDC/CI)
# Shows the new level as a dunst progress bar.
# ============================================================

ACTION="${1:-up}"
STEP="${2:-5}"
MIN_LAPTOP=1

# DDC/CI calls are slow; drop key repeats that arrive while one is running
exec 9>"${XDG_RUNTIME_DIR:-/tmp}/brightness.lock"
flock -n 9 || exit 0

FOCUSED=$(swaymsg -t get_outputs -r | jq -r '.[] | select(.focused) | .name')

notify() {
    notify-send -a brightness -u low -t 1200 \
        -h string:x-dunst-stack-tag:brightness \
        -h "int:value:$1" "Brightness ($2)" "$1%"
}

if [[ "${FOCUSED:-eDP-1}" == eDP* ]]; then
    # brightnessctl's --min-value does not clamp percentage steps, so clamp here
    cur=$(brightnessctl -c backlight -m | cut -d, -f4 | tr -d '%')
    case "$ACTION" in
        up)   new=$(( cur + STEP )); (( new > 100 )) && new=100 ;;
        down) new=$(( cur - STEP )); (( new < MIN_LAPTOP )) && new=$MIN_LAPTOP ;;
        *)    exit 1 ;;
    esac
    brightnessctl -q -c backlight set "${new}%"
    pct=$(brightnessctl -c backlight -m | cut -d, -f4 | tr -d '%')
    notify "$pct" "laptop"
else
    case "$ACTION" in
        up)   sign="+" ;;
        down) sign="-" ;;
        *)    exit 1 ;;
    esac
    if ! ddcutil setvcp 10 "$sign" "$STEP" --noverify 2>/dev/null; then
        notify-send -u low -t 2000 "Brightness" "ddcutil could not reach $FOCUSED"
        exit 1
    fi
    # --brief prints: VCP 10 C <current> <max>
    pct=$(ddcutil getvcp 10 --brief 2>/dev/null | awk '{print $4}')
    notify "${pct:-0}" "$FOCUSED"
fi
