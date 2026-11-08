# Color palette

Monochrome greys plus **one accent**. Hex values are copied into each config
by hand; to change the palette, search the repo for the old hex and replace it.

| Name      | Hex       | Use |
| :-------- | :-------- | :-- |
| `bg`      | `#000000` | Backgrounds: bar, terminal, editor, wallpaper, lock screen |
| `surface` | `#111111` | Raised areas: tooltips, notifications, popups, inputs |
| `raised`  | `#222222` | Selections, inactive buttons |
| `border`  | `#333333` | Borders, separators, unfocused windows |
| `dim`     | `#555555` | Comments, inactive text, separators |
| `muted`   | `#888888` | Secondary text |
| `fg`      | `#e6e6e6` | Primary text |
| `accent`  | `#7aa2c8` | Focus only: focused window border, active workspace, prompt arrow, selection, keywords |
| `red`     | `#e05555` | Errors, critical, urgent |
| `amber`   | `#e0a030` | Warnings, dirty git state |

Rules: no other hues. "OK" states use plain `fg`. Text on an `accent` or `red`
fill is `bg`.

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
