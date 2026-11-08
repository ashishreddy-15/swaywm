#!/usr/bin/env bash
# Power menu ($mod+x, via rofi-toggle.sh).
#
# Lock and Suspend run straight away: nothing is lost. Logout, Reboot and
# Shutdown close every app, so they ask first. The confirm list starts on
# "No", so a stray Enter cancels; Esc cancels too.
set -euo pipefail

pick() {  # pick PROMPT [MESSAGE] < options  -> chosen line (empty on Esc)
    rofi -dmenu -i -p "$1" -no-show-icons -l 5 -selected-row 0 ${2:+-mesg "$2"} || true
}

confirm() {  # confirm ACTION -> success only if the user picks "Yes"
    local answer
    answer=$(printf '%s\n' "No" "Yes, $1" | pick "${1^}?" "Open apps will close without saving.")
    [[ $answer == "Yes, $1" ]]
}

chosen=$(printf '%s\n' Lock Suspend Logout Reboot Shutdown | pick "Power")

case $chosen in
    Lock)     loginctl lock-session ;;
    Suspend)  systemctl suspend ;;
    Logout)   confirm "log out"   && swaymsg exit ;;
    Reboot)   confirm "reboot"    && systemctl reboot ;;
    Shutdown) confirm "shut down" && systemctl poweroff ;;
esac
