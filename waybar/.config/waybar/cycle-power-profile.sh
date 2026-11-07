#!/bin/sh
# Cycle power-profiles-daemon through: power-saver -> balanced -> performance -> power-saver
current=$(busctl get-property net.hadess.PowerProfiles /net/hadess/PowerProfiles net.hadess.PowerProfiles ActiveProfile 2>/dev/null | awk -F'"' '{print $2}')

case "$current" in
    "power-saver") next="balanced" ;;
    "balanced")    next="performance" ;;
    *)             next="power-saver" ;;
esac

busctl call net.hadess.PowerProfiles /net/hadess/PowerProfiles org.freedesktop.DBus.Properties Set "ssv" net.hadess.PowerProfiles ActiveProfile s "$next"
