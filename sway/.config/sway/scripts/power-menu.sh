#!/usr/bin/env bash

# Power menu script using rofi
options="Lock\nLogout\nSuspend\nReboot\nShutdown"

chosen=$(echo -e "$options" | rofi -dmenu -i -p "Power" -lines 5 -no-show-icons)

case "$chosen" in
    *Lock*)
        loginctl lock-session
        ;;
    *Logout*)
        swaymsg exit
        ;;
    *Suspend*)
        systemctl suspend
        ;;
    *Reboot*)
        systemctl reboot
        ;;
    *Shutdown*)
        systemctl poweroff
        ;;
esac
