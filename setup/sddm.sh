#!/usr/bin/env bash
# SDDM login screen that matches the desktop (theme "mono", see colors.md).
#
#   theme     setup/sddm/theme/mono      -> /usr/share/sddm/themes/mono/
#   greeter   setup/sddm/sway-greeter.conf -> /etc/sddm/sway-greeter.conf
#   drop-in   setup/sddm/10-swaywm.conf  -> /etc/sddm.conf.d/10-swaywm.conf
#   fonts     Maple Mono NF Light/Regular/Medium copied into the theme
#             (the sddm user can't read ~/.local/share/fonts)
#
# Usage: ./setup/sddm.sh [--dry-run] [--uninstall]     (asks for sudo)
#
# Takes effect at the next login screen; sddm is not restarted here because
# that would end the running session. To try the theme without logging out:
#   sddm-greeter-qt6 --test-mode --theme ~/swaywm/setup/sddm/theme/mono
#
# If the greeter ever breaks: Ctrl+Alt+F3, log in, then
#   sudo rm /etc/sddm.conf.d/10-swaywm.conf && sudo systemctl restart sddm
set -euo pipefail

DRY=0 UNINSTALL=0
for a in "$@"; do
    case "$a" in
        --dry-run)   DRY=1 ;;
        --uninstall) UNINSTALL=1 ;;
        -h|--help)   sed -n '2,18p' "$0"; exit 0 ;;
        *) echo "unknown option: $a" >&2; exit 1 ;;
    esac
done

HERE="$(cd "$(dirname "$0")" && pwd)"
SRC="$HERE/sddm"

# Validate before sudo. `sway -C` still opens a backend; headless needs no
# display, so this works from a TTY, over ssh and as root.
# Skipped on the second pass after `exec sudo` below; it already ran.
if (( ! UNINSTALL )) && [[ $EUID -ne 0 || -z ${SUDO_USER:-} ]]; then
    command -v sddm-greeter-qt6 >/dev/null || { echo "sddm-greeter-qt6 not found; is sddm installed?" >&2; exit 1; }
    echo "==> Checking the greeter sway config"
    env -u DISPLAY -u WAYLAND_DISPLAY WLR_BACKENDS=headless WLR_LIBINPUT_NO_DEVICES=1 \
        sway -C -c "$SRC/sway-greeter.conf" >/dev/null
fi

if (( ! DRY )) && [[ $EUID -ne 0 ]]; then exec sudo "$0" "$@"; fi

USER_NAME="${SUDO_USER:-$(id -un)}"
USER_HOME="$(getent passwd "$USER_NAME" | cut -d: -f6)"

THEME_DIR=/usr/share/sddm/themes/mono
GREETER_CONF=/etc/sddm/sway-greeter.conf
DROPIN=/etc/sddm.conf.d/10-swaywm.conf

run() { if (( DRY )); then printf '    [dry-run] %s\n' "$*"; else "$@"; fi; }

if (( UNINSTALL )); then
    echo "==> Removing the mono SDDM theme (back to Fedora's stock greeter)"
    run rm -f "$DROPIN" "$GREETER_CONF"
    run rm -rf "$THEME_DIR"
    echo "==> Done. The stock greeter returns at the next login screen."
    exit 0
fi

echo "==> Theme -> $THEME_DIR"
run rm -rf "$THEME_DIR"
run install -d -m 755 "$THEME_DIR/fonts"
for f in Main.qml TextButton.qml metadata.desktop theme.conf; do
    run install -m 644 "$SRC/theme/mono/$f" "$THEME_DIR/$f"
done

echo "==> Fonts (Maple Mono NF)"
for w in Light Regular Medium; do
    font=$(find "$USER_HOME/.local/share/fonts" /usr/local/share/fonts /usr/share/fonts \
                -name "MapleMono-NF-$w.ttf" -print -quit 2>/dev/null || true)
    if [[ -n "$font" ]]; then
        run install -m 644 "$font" "$THEME_DIR/fonts/"
        echo "    $w: $font"
    else
        echo "    warning: MapleMono-NF-$w.ttf not found; run ./install.sh first (falls back to a default font)"
    fi
done

echo "==> Greeter compositor config -> $GREETER_CONF"
run install -D -m 644 "$SRC/sway-greeter.conf" "$GREETER_CONF"

echo "==> SDDM drop-in -> $DROPIN"
run install -D -m 644 "$SRC/10-swaywm.conf" "$DROPIN"

if command -v restorecon >/dev/null; then
    run restorecon -R "$THEME_DIR" "$GREETER_CONF" "$DROPIN"
fi

echo "==> Done. The new login screen appears the next time you log out or reboot."
