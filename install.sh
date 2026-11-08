#!/usr/bin/env bash
# Bootstrap this setup on a fresh Fedora install.
#
#   git clone git@github.com:ashishreddy-15/swaywm.git ~/swaywm
#   cd ~/swaywm && ./install.sh
#
# Options:
#   --dry-run         print what would happen, change nothing
#   --no-packages     skip dnf (e.g. on an already-set-up machine)
#   --with-snapshots  also run setup/snapshots.sh (snapper + dnf hook)
#   --with-sddm       also run setup/sddm.sh (login screen theme)
#
# Safe to re-run: every step checks before it acts. Existing dotfiles that
# would block stow are moved to ~/.dotfiles-backup-<date>/, never deleted.
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
DRY=0 PKGS=1 SNAPS=0 SDDM=0
for a in "$@"; do
    case "$a" in
        --dry-run)        DRY=1 ;;
        --no-packages)    PKGS=0 ;;
        --with-snapshots) SNAPS=1 ;;
        --with-sddm)      SDDM=1 ;;
        -h|--help)        sed -n '2,14p' "$0"; exit 0 ;;
        *) echo "unknown option: $a" >&2; exit 1 ;;
    esac
done

step() { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
run()  { if (( DRY )); then printf '    [dry-run] %s\n' "$*"; else "$@"; fi; }

[[ $EUID -ne 0 ]] || { echo "Run as your user, not root (sudo is used where needed)."; exit 1; }
grep -q '^ID=fedora' /etc/os-release || echo "warning: not Fedora, package names may differ"

PACKAGES=(
    # desktop
    sway swayidle swaylock waybar kanshi rofi dunst foot
    xdg-desktop-portal-wlr network-manager-applet blueman pavucontrol
    # screenshots, recording, clipboard, notifications
    grim slurp grimshot wf-recorder cliphist wl-clipboard libnotify
    # brightness, night light, power
    brightnessctl ddcutil wlsunset tuned-ppd playerctl
    # apps
    mpv yt-dlp loupe zathura zathura-pdf-mupdf
    # rofi tools
    qalculate rofimoji wtype
    # shell & cli
    neovim tmux fzf zoxide eza bat ripgrep fd-find jq btop fastfetch
    # bootstrap itself
    stow git-core curl unzip
)

# ── 1. Packages ─────────────────────────────────────────────
if (( PKGS )); then
    step "Installing packages (sudo dnf)"
    missing=()
    for p in "${PACKAGES[@]}"; do rpm -q "$p" &>/dev/null || missing+=("$p"); done
    if (( ${#missing[@]} )); then
        run sudo dnf install -y "${missing[@]}"
    else
        echo "    all ${#PACKAGES[@]} packages already installed"
    fi
fi

# ── 2. starship (not in Fedora repos; official installer) ───
step "starship prompt"
if command -v starship &>/dev/null; then
    echo "    already installed: $(command -v starship)"
else
    run sh -c 'curl -sS https://starship.rs/install.sh | sh -s -- -y'
fi

# ── 3. Fonts ────────────────────────────────────────────────
step "Maple Mono NF font"
FONT_DIR="$HOME/.local/share/fonts/MapleMono-NF-unhinted"
if fc-list -q 'Maple Mono NF'; then
    echo "    already installed"
else
    url=https://github.com/subframe7536/maple-font/releases/latest/download/MapleMono-NF-unhinted.zip
    run mkdir -p "$FONT_DIR"
    run sh -c "curl -fsSL '$url' -o /tmp/maple-nf.zip && unzip -oq /tmp/maple-nf.zip -d '$FONT_DIR' && rm /tmp/maple-nf.zip"
    run fc-cache -f
fi

# ── 4. Dotfiles (stow) ──────────────────────────────────────
step "Linking dotfiles with stow"
mapfile -t STOW_PKGS < <(cd "$REPO" && for d in */; do d=${d%/}; [[ $d == setup ]] || echo "$d"; done)
echo "    packages: ${STOW_PKGS[*]}"

# Move real files that would block stow out of the way (never delete).
BACKUP="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
moved=0
for pkg in "${STOW_PKGS[@]}"; do
    while IFS= read -r -d '' f; do
        rel=${f#"$REPO/$pkg/"}
        target="$HOME/$rel"
        if [[ -e "$target" && ! -L "$target" ]]; then
            run mkdir -p "$BACKUP/$(dirname "$rel")"
            run mv "$target" "$BACKUP/$rel"
            moved=$((moved + 1))
        fi
    done < <(find "$REPO/$pkg" \( -type f -o -type l \) ! -name '*.bak*' -print0)
done
(( moved )) && echo "    moved $moved existing file(s) to $BACKUP"

if (( DRY )); then
    (cd "$REPO" && stow -n -R "${STOW_PKGS[@]}" 2>&1 | sed 's/^/    [dry-run] /' | grep -v 'simulation mode' || true)
else
    (cd "$REPO" && stow -R "${STOW_PKGS[@]}")
fi

# ── 5. GTK / desktop settings (not files, so not stowed) ────
step "GTK dark theme and font smoothing"
run gsettings set org.gnome.desktop.interface color-scheme prefer-dark
run gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark
run gsettings set org.gnome.desktop.interface font-antialiasing rgba

# ── 6. Default applications ─────────────────────────────────
step "Default apps: images→Loupe, video/audio→mpv, PDF→zathura"
mimes() { grep -h '^MimeType=' "/usr/share/applications/$1" 2>/dev/null | cut -d= -f2 | tr ';' '\n' | grep -E "$2" || true; }
for spec in "org.gnome.Loupe.desktop:^image/" "mpv.desktop:^(video|audio)/" "org.pwmt.zathura-pdf-mupdf.desktop:^application/pdf"; do
    app=${spec%%:*} re=${spec#*:}
    mapfile -t types < <(mimes "$app" "$re")
    if (( ${#types[@]} )); then run xdg-mime default "$app" "${types[@]}"; echo "    $app: ${#types[@]} types"
    else echo "    $app not installed, skipped"; fi
done

# ── 7. Services and folders ─────────────────────────────────
step "User services and folders"
run systemctl --user enable kanshi.service
run mkdir -p "$HOME/Pictures/mpv" "$HOME/Videos/recordings"

# ── 8. Snapshots (optional, needs sudo) ─────────────────────
if (( SNAPS )); then
    step "btrfs snapshots"
    run "$REPO/setup/snapshots.sh"
fi

# ── 9. Login screen (optional, needs sudo) ──────────────────
if (( SDDM )); then
    step "SDDM login screen"
    if (( DRY )); then "$REPO/setup/sddm.sh" --dry-run; else "$REPO/setup/sddm.sh"; fi
fi

step "Done"
echo "    Log out and back in (or reboot) to start sway with everything in place."
(( SNAPS )) || echo "    Snapshots not set up; run ./install.sh --with-snapshots or ./setup/snapshots.sh"
(( SDDM ))  || echo "    Login screen not themed; run ./install.sh --with-sddm or ./setup/sddm.sh"
