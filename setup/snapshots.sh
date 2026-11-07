#!/usr/bin/env bash
# btrfs snapshots with snapper (Fedora, dnf5).
#
#   root  (/)      a pre/post snapshot pair around every dnf transaction;
#                  keeps the last 10 pairs. No timeline.
#   home  (/home)  hourly snapshots; keeps 12 hourly, 7 daily, 4 weekly.
#
# Snapshots live on the same disk: they undo mistakes and bad updates,
# they are NOT a backup against disk failure or a lost laptop.
#
# Usage: ./setup/snapshots.sh      (asks for sudo)
set -euo pipefail

[[ $EUID -eq 0 ]] || exec sudo "$0" "$@"
USER_NAME="${SUDO_USER:-$(logname)}"
HERE="$(cd "$(dirname "$0")" && pwd)"

[[ "$(findmnt -no FSTYPE /)" == btrfs ]] || { echo "/ is not btrfs, nothing to do"; exit 1; }

echo "==> Installing snapper and the dnf5 actions plugin"
dnf install -y snapper libdnf5-plugin-actions

echo "==> Creating snapper configs"
snapper -c root list &>/dev/null || snapper -c root create-config /
snapper -c home list &>/dev/null || snapper -c home create-config /home

# root: only dnf pre/post pairs, cleaned up by number
snapper -c root set-config \
    TIMELINE_CREATE=no \
    NUMBER_CLEANUP=yes NUMBER_LIMIT=20 NUMBER_LIMIT_IMPORTANT=10 \
    ALLOW_USERS="$USER_NAME" SYNC_ACL=yes

# home: hourly timeline, cleaned up by age buckets
snapper -c home set-config \
    TIMELINE_CREATE=yes TIMELINE_CLEANUP=yes \
    TIMELINE_LIMIT_HOURLY=12 TIMELINE_LIMIT_DAILY=7 TIMELINE_LIMIT_WEEKLY=4 \
    TIMELINE_LIMIT_MONTHLY=0 TIMELINE_LIMIT_YEARLY=0 \
    NUMBER_CLEANUP=yes NUMBER_LIMIT=10 \
    ALLOW_USERS="$USER_NAME" SYNC_ACL=yes

echo "==> Hooking snapper into dnf"
install -Dm644 "$HERE/snapper.actions" /etc/dnf/libdnf5-plugins/actions.d/snapper.actions

echo "==> Enabling timeline and cleanup timers"
systemctl enable --now snapper-timeline.timer snapper-cleanup.timer

echo "==> First snapshots"
snapper -c root create -d "baseline after setup" --cleanup-algorithm number
snapper -c home create -d "baseline after setup" --cleanup-algorithm timeline

echo
snapper list-configs
echo
echo "Done. Try:  snapper -c root list    (no sudo needed)"
