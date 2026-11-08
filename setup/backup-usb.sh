#!/usr/bin/env bash
# Copy snapper snapshots of / and /home to an encrypted USB stick.
#
# Snapper snapshots live on the same disk as the data (setup/snapshots.sh).
# This puts a second copy on another device with btrfs send/receive: each
# run takes a fresh snapshot of both configs, sends it to the stick
# (incremental after the first run) and keeps the last $KEEP per config.
#
#   ./setup/backup-usb.sh --init /dev/sdX   ERASE the stick, set up LUKS + btrfs (once)
#   ./setup/backup-usb.sh                   back up (stick plugged in)
#   ./setup/backup-usb.sh --mount           unlock + mount at /run/snapbackup to browse
#   ./setup/backup-usb.sh --umount          unmount + lock again
#
# Needs setup/snapshots.sh first. Asks for sudo and the stick's passphrase.
#
# On the stick:  /<config>/<snapper number>/snapshot   (read-only subvolumes)
# Restore files: --mount, then copy out of /run/snapbackup/home/<N>/snapshot/...
#
# To make the next send incremental, the last snapshot sent stays on the
# laptop too (snapper description "usb backup"). It has no cleanup
# algorithm on purpose, so snapper never prunes it; this script replaces
# it on the next run.
set -euo pipefail
shopt -s nullglob

[[ $EUID -eq 0 ]] || exec sudo "$0" "$@"

NAME=snapbackup                  # GPT partition name, LUKS label, mapper name, fs label
PART=/dev/disk/by-partlabel/$NAME
MAPPER=/dev/mapper/$NAME
MNT=/run/$NAME
KEEP=8                           # copies per config kept on the stick
CONFIGS=(root home)
declare -A SUBVOL=([root]=/ [home]=/home)

die()   { echo "error: $*" >&2; exit 1; }
usage() { sed -n '2,/^set -euo/{/^set/d;s/^# \{0,1\}//;p}' "$0"; exit "${1:-0}"; }

open_stick() {
    [[ -e $PART ]] || die "no partition named '$NAME' found. Stick plugged in? Set up with --init?"
    [[ -e $MAPPER ]] || cryptsetup open "$PART" "$NAME"
    mkdir -p "$MNT"
    mountpoint -q "$MNT" || mount -o compress=zstd,noatime "$MAPPER" "$MNT"
}

close_stick() {
    sync
    if mountpoint -q "$MNT"; then umount "$MNT"; fi
    if [[ -e $MAPPER ]]; then cryptsetup close "$NAME"; fi
    rmdir "$MNT" 2>/dev/null || true
}

init_stick() {
    local dev=${1:-}
    [[ -n $dev ]] || usage 1
    dev=$(readlink -f "$dev")
    [[ -b $dev && $(lsblk -dno TYPE "$dev" | tr -d ' ') == disk ]] \
        || die "$dev is not a whole disk (want e.g. /dev/sdb, not /dev/sdb1)"
    [[ $(lsblk -dno RM "$dev" | tr -d ' ') == 1 ]] \
        || die "$dev is not a removable drive, refusing"

    # never the disk this system runs from (it is USB too, but not removable)
    local rootdisk
    rootdisk=$(lsblk -spno PATH,TYPE "$(findmnt -no SOURCE / | sed 's/\[.*//')" | awk '$2=="disk"{print $1}')
    [[ $dev != "$rootdisk" ]] || die "$dev holds the running system, refusing"

    if lsblk -no MOUNTPOINTS "$dev" | grep -q .; then
        die "something on $dev is mounted, unmount it first"
    fi

    echo "This ERASES everything on:"
    lsblk -o NAME,SIZE,TRAN,FSTYPE,LABEL "$dev"
    local answer
    read -rp "Type the device path ($dev) to continue: " answer
    [[ $answer == "$dev" ]] || die "aborted"

    echo "==> Partitioning"
    local p
    for p in $(lsblk -lnpo PATH "$dev" | tail -n +2); do wipefs -aq "$p"; done
    wipefs -aq "$dev"
    printf 'label: gpt\ntype=L, name=%s\n' "$NAME" | sfdisk -q --wipe always "$dev"
    udevadm settle
    [[ -e $PART ]] || die "partition did not show up at $PART"

    echo "==> Encrypting (choose a passphrase; you need it for every backup)"
    cryptsetup luksFormat --type luks2 --label "$NAME" "$PART"
    trap close_stick EXIT
    cryptsetup open "$PART" "$NAME"

    echo "==> Creating btrfs"
    mkfs.btrfs -q -L "$NAME" "$MAPPER"
    mkdir -p "$MNT"
    mount -o compress=zstd,noatime "$MAPPER" "$MNT"
    mkdir "${CONFIGS[@]/#/$MNT/}"
    echo "Done. Run ./setup/backup-usb.sh to make the first backup."
}

# true when a subvolume on the stick finished receiving
received() {
    [[ $(btrfs subvolume show "$1" | awk '/Received UUID:/{print $NF}') != "-" ]]
}

backup_config() {
    local cfg=$1
    local src=${SUBVOL[$cfg]%/}/.snapshots dst=$MNT/$cfg
    snapper -c "$cfg" list &>/dev/null || die "no snapper config '$cfg', run setup/snapshots.sh first"
    mkdir -p "$dst"

    # drop leftovers of an interrupted run
    local d
    for d in "$dst"/*/; do
        d=${d%/}
        if [[ -d $d/snapshot ]] && ! received "$d/snapshot"; then
            btrfs subvolume delete -q "$d/snapshot"
        fi
        [[ -d $d/snapshot ]] || rmdir "$d"
    done

    # newest snapshot that is on the stick and still on the laptop
    local parent="" n
    for n in $(ls -1 "$dst" | sort -rn); do
        if [[ -d $src/$n/snapshot ]]; then parent=$n; break; fi
    done

    local new
    new=$(snapper -c "$cfg" create -p -d "usb backup" -u usbbackup=yes)
    mkdir "$dst/$new"
    if [[ -n $parent ]]; then
        echo "==> $cfg: #$new, incremental from #$parent"
        btrfs send -q -p "$src/$parent/snapshot" "$src/$new/snapshot" | btrfs receive -q "$dst/$new"
    else
        echo "==> $cfg: #$new, full copy (first run, takes a while)"
        btrfs send -q "$src/$new/snapshot" | btrfs receive -q "$dst/$new"
    fi
    received "$dst/$new/snapshot" || die "$cfg: receive did not complete"

    # laptop: keep only the snapshot just sent as the next parent
    local f k
    for f in "$src"/*/info.xml; do
        k=${f%/info.xml}; k=${k##*/}
        if [[ $k != "$new" ]] && grep -q '<key>usbbackup</key>' "$f"; then
            snapper -c "$cfg" delete "$k"
        fi
    done

    # stick: keep the newest $KEEP
    local nums i
    mapfile -t nums < <(ls -1 "$dst" | sort -n)
    for (( i = 0; i < ${#nums[@]} - KEEP; i++ )); do
        btrfs subvolume delete -q "$dst/${nums[i]}/snapshot"
        rmdir "$dst/${nums[i]}"
    done
}

case ${1:-} in
    --init)   shift; init_stick "$@" ;;
    --mount)  open_stick; echo "Mounted at $MNT. Run with --umount when done." ;;
    --umount) close_stick; echo "Locked. Safe to unplug." ;;
    -h|--help) usage ;;
    "")
        trap close_stick EXIT
        open_stick
        for c in "${CONFIGS[@]}"; do backup_config "$c"; done
        echo; df -h "$MNT" | awk 'NR==2{print "Stick: " $3 " used, " $4 " free"}'
        echo "Done. Safe to unplug once this exits."
        ;;
    *) usage 1 ;;
esac
