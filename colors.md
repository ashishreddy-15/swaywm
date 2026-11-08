# Color palette

Taken from the wallpaper (`sway/.config/sway/wallpaper.jpg`, horizon at
dusk): olive-tinted greys from the ground, the accent from the sky, amber
from the horizon. Hex values are copied into each config by hand; to change
the palette, search the repo for the old hex and replace it.

**Migration in progress (`feat/ui-overhaul`).** Using the new palette:
waybar, dunst, wallpaper. Still on the old one (right column): everything
else, to be moved app by app.

| Name      | Hex       | Old       | Use |
| :-------- | :-------- | :-------- | :-- |
| `bg`      | `#0f110d` | `#000000` | Backgrounds: terminal, editor, lock screen |
| `surface` | `#161a14` | `#111111` | Raised areas: bar island, notifications, menus, tooltips, inputs |
| `hover`   | `#20251d` | —         | Hover on clickable items |
| `raised`  | `#222820` | `#222222` | Selections, inactive buttons |
| `line`    | `#232820` | —         | Separators inside a surface |
| `border`  | `#2e342a` | `#333333` | Borders, unfocused windows |
| `dim`     | `#5a6152` | `#555555` | Comments, inactive text, placeholders |
| `muted`   | `#8c9384` | `#888888` | Secondary text, labels |
| `fg`      | `#e6e8e1` | `#e6e6e6` | Primary text, values |
| `accent`  | `#6fa3b8` | `#7aa2c8` | Focus only: focused window border, focused workspace, prompt arrow, selection, keywords |
| `amber`   | `#db892d` | `#e0a030` | Drawing power or a temporary mode (PERF, AWAKE, resize), warnings, dirty git state |
| `red`     | `#e05555` | `#e05555` | Needs attention now: errors, critical, urgent |

Image colours they came from: ground `#13160f` (also the wallpaper's fallback
colour), sky `#06587a` (too dark for focus on a dark background, so the accent
keeps its hue at about 6.9:1 contrast), horizon `#db892d`.

Rules: no other hues. Normal states are quiet (dim or hidden); a word or
colour appears only when something differs from normal. "OK" states use
plain `fg`. Text on an `accent` or `red` fill is `bg`.

**Exception: the terminal's ANSI palette** (foot `[colors-dark]`). CLI tools
(eza/`LS_COLORS`, git diff, …) tell things apart by ANSI colour, so green,
magenta and cyan get muted hues there instead of greys. They are used nowhere
else.

| ANSI slot | Regular   | Bright    |
| :-------- | :-------- | :-------- |
| green     | `#8fb98b` | `#a3c99f` |
| magenta   | `#b294bb` | `#c4a7cc` |
| cyan      | `#7fbfb5` | `#95cfc6` |

## Where it is applied
sway (`client.*`, wallpaper) · waybar (`@define-color`) · dunst · rofi (variables
in `config.rasi`) · foot (`[colors-dark]`) · swaylock · starship · btop
(`themes/mono.theme`) · nvim (`colors/mono.lua`) · mpv (OSD, subtitles,
`script-opts/osc.conf`) · zathura (`zathurarc`) · fzf (`bash/.bashrc.d/03-fzf.sh`) · sddm login
screen (`setup/sddm/theme/mono/theme.conf`, installed by `setup/sddm.sh`).

Not tracked by stow: `gsettings set org.gnome.desktop.interface color-scheme prefer-dark`
and `gtk-theme Adwaita-dark` for GTK apps.
