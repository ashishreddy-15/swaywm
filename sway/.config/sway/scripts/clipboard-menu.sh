#!/usr/bin/env bash

# Clipboard menu selector with sequential numbering (1. test, 2. example)
raw=$(cliphist list)
[ -z "$raw" ] && exit 0

mapfile -t ids < <(echo "$raw" | awk '{print $1}')
formatted=$(echo "$raw" | awk '{sub(/^[0-9]+\t/, ""); print NR ".  " $0}')

chosen=$(echo "$formatted" | rofi -dmenu -i -p "Clipboard" -no-show-icons)
[ -z "$chosen" ] && exit 0

index="${chosen%%.*}"
if [[ "$index" =~ ^[0-9]+$ ]] && [ "$index" -ge 1 ] && [ "$index" -le "${#ids[@]}" ]; then
    target_id="${ids[$((index - 1))]}"
    cliphist decode "$target_id" | wl-copy
fi
