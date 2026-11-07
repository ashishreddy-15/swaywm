#!/usr/bin/env bash
# Rofi calculator (qalc). Type an expression and press Enter to compute;
# select the result line and press Enter to copy it. Escape closes.
command -v qalc >/dev/null || { notify-send "Calculator" "qalc is not installed (dnf install qalculate)"; exit 1; }

res=""
msg="Enter: compute · select result + Enter: copy"
while :; do
    q=$(printf '%s' "$res" | rofi -dmenu -i -l 1 -p "calc" -mesg "$msg") || exit 0
    [[ -z "$q" ]] && exit 0
    if [[ -n "$res" && "$q" == "$res" ]]; then
        printf '%s' "$res" | wl-copy
        notify-send -a calc -u low -t 1500 "Copied" "$res"
        exit 0
    fi
    res=$(qalc -t -- "$q" 2>/dev/null | tail -n1)
    msg="$q = $res"
done
