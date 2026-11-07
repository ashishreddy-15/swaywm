# Sway Dual-Monitor Dotfiles

A clean, modular, and keyboard-driven Wayland desktop setup powered by **Sway WM**, managed effortlessly with **GNU Stow**.

Configured specifically for a **dual-monitor productivity workflow** (Laptop + 27" 1440p 100Hz External Display) with automatic display detection via **Kanshi**, seamless **clamshell mode** handling, and dynamic workspace routing.

---

## 🎨 Color Scheme

Monochrome greys plus one blue-grey accent (`#7aa2c8`) used for focus only. See [`colors.md`](colors.md) for the palette and where it is applied.

---

## 🪟 Window Look & Rules

* Flat windows: 2px borders, no titlebars, no gaps; borders are hidden when a workspace has a single window (`smart_borders`).
* Anything fullscreen blocks idle lock/blank (`50-rules-windows.conf`).
* Dialogs, pop-ups, file pickers and the Bluetooth/network manager windows float instead of tiling.

---

## ⌨️ Keyboard

* Key repeat: 250 ms delay, 40/s.
* Caps Lock acts as Escape.

---

## 🖥️ Display & Workspace Architecture

### Physical Layout

```
                      ┌─────────────────────────────────────────┐
                      │      Samsung 27" (HDMI or USB-C/DP)     │
┌──────────────────┐  │         Quad HD 2560 x 1440 @ 100Hz     │
│      eDP-1       │  │                                         │
│  Laptop Display  │  │            Position: 1920, 0            │
│    1920 x 1200   │  │                                         │
│ Position: 0, 240 │  │             Workspaces 1-5              │
│  Workspaces 6-10 │  │                                         │
└──────────────────┘  └─────────────────────────────────────────┘
```

The two screens are **bottom-aligned**, so the mouse crosses between them where you expect.

```
```

### Dynamic Multi-Monitor Management

* **[Kanshi](https://sr.ht/~emersion/kanshi/) Profile Switching** (`kanshi/.config/kanshi/config`):
  * **`dual`**: the Samsung is matched by make/model/serial, so it works on any port (HDMI or USB-C).
  * **`external`**: any other monitor gets its preferred mode, to the right of the laptop.
  * **`solo`**: laptop screen only.
  * After `dual`/`external` are applied, kanshi runs `lid-handler.sh`, so plugging in a monitor while the lid is closed does not turn the laptop panel back on.
* **Clamshell Mode** ([`lid-handler.sh`](sway/.config/sway/scripts/lid-handler.sh)):
  * Closing the lid with an external screen connected turns `eDP-1` off; opening it turns it back on.
  * With no external screen, closing the lid does nothing in sway (logind handles suspend).
  * Called with no argument it reads the lid state from `/proc/acpi/button/lid/*/state`.
* **Workspace Pinning** (no scripts needed):
  * Workspaces `1`–`5` prefer the external monitor (fallback `eDP-1`); `6`–`10` prefer `eDP-1` (fallback external).
  * Sway uses these preference lists itself: when a screen turns off or is unplugged its workspaces move to the other one, and when it comes back they move back.
  * `$mod + Tab` jumps focus to the other screen; `$mod + Shift + Tab` sends the current workspace there.

---

## 📦 Packages & Components

Each component is modularized as an independent GNU Stow package:

| Package | Target Location | Description |
| :--- | :--- | :--- |
| **`bash`** | `~/.bashrc`, `~/.bashrc.d/`, `~/.inputrc` | Shell: history, aliases, fzf (`Ctrl+R`/`Ctrl+T`/`Alt+C`), zoxide (`z`/`j`), starship, readline completion. |
| **`sway`** | `~/.config/sway` | Core window manager config, keybindings, drop-in configs (`config.d/`), and utility scripts (`scripts/`). |
| **`kanshi`** | `~/.config/kanshi` | Display auto-detection daemon and dual/solo monitor profiles. |
| **`waybar`** | `~/.config/waybar` | Status bar with workspace indicators, hardware monitors, and power profile switcher. |
| **`rofi`** | `~/.config/rofi` | Application launcher, power menu, and clipboard menu (minimal monochrome theme). |
| **`dunst`** | `~/.config/dunst` | Notification daemon configured with mouse-follow across dual monitors. |
| **`foot`** | `~/.config/foot` | Ultra-fast Wayland-native terminal emulator configured with Maple Mono NF. |
| **`swaylock`** | `~/.config/swaylock` | Minimal black screen locker integrated with `swayidle`. |
| **`starship`** | `~/.config/starship.toml` | Fast, informative two-line shell prompt (monochrome + accent). |
| **`btop`** | `~/.config/btop` | Terminal system resource monitor. |
| **`fontconfig`** | `~/.config/fontconfig` | Font configuration directing to `~/.local/share/fonts`. |
| **`xdg-desktop-portal-wlr`** | `~/.config/xdg-desktop-portal-wlr` | Screen sharing asks which monitor to share (click it with `slurp`). |
| **`mpv`** | `~/.config/mpv` | Video player: VAAPI hardware decoding, Vulkan `gpu-next`, smooth motion on the 100 Hz monitor, monochrome OSD. |
| **`zathura`** | `~/.config/zathura` | Keyboard-driven PDF viewer in the same palette (`Ctrl+r` for dark pages). |
| **`nvim`** | `~/.config/nvim` | Neovim IDE configuration (lazy.nvim, Treesitter, LSP, Telescope, Oil, and completion). |

---

## 🚀 Managing Dotfiles with GNU Stow

[GNU Stow](https://www.gnu.org/software/stow/) manages symlinks from this repository directly into `$HOME` (`~/.config/...`).

The repo's [`.stowrc`](.stowrc) sets the defaults, so plain `stow` commands work from `~/swaywm`:

* `--target=~`: links go into your home directory.
* `--no-folding`: every file gets its own symlink and directories like `~/.config/sway` stay real. Logs and caches that apps write into their config dir (e.g. `btop.log`) stay out of the repo, and new files you add to the repo only appear after a restow.
* `--ignore=\.bak...`: `*.bak` backups are never linked.

`setup/` is not a stow package (system-level scripts), so link packages by name, or let `./install.sh --no-packages` link all of them:

```bash
cd ~/swaywm
stow -v bash sway     # stow packages by name
stow -v sway          # stow one package
stow -R -v sway       # restow after adding/removing files in a package
stow -D -v sway       # remove a package's symlinks
stow -n -v sway       # dry run
```

---

## ⌨️ Keybindings Cheat Sheet

Modifier Key: **`$mod` = `Super` (Windows key)**

### Applications & Menus
| Shortcut | Action |
| :--- | :--- |
| `$mod + Return` | Open Foot terminal |
| `$mod + d` | Toggle Rofi application launcher |
| `$mod + x` | Toggle Rofi power menu (Lock, Logout, Suspend, Reboot, Shutdown) |
| `$mod + v` | Toggle Rofi clipboard history (`cliphist`, last 200 entries; password-manager copies are skipped) |
| `$mod + Ctrl + v` | Wipe clipboard history |
| `$mod + q` | Close focused window |

### Navigation & Focus
| Shortcut | Action |
| :--- | :--- |
| `$mod + h` / `j` / `k` / `l` | Focus left / down / up / right |
| `$mod + Left` / `Down` / `Up` / `Right` | Focus left / down / up / right |
| `$mod + Tab` | Focus the other monitor |
| `$mod + Shift + Tab` | Move the current workspace to the other monitor |
| `$mod + 1` .. `$mod + 0` | Switch to workspace 1 - 10 (press the current one again to go back) |
| `$mod + Shift + 1` .. `0` | Move focused window to workspace 1 - 10 |

### Layout & Window Management
| Shortcut | Action |
| :--- | :--- |
| `$mod + b` | Split horizontally |
| `$mod + Shift + v` | Split vertically |
| `$mod + s` | Stacking layout |
| `$mod + w` | Tabbed layout |
| `$mod + e` | Toggle split layout |
| `$mod + f` | Toggle fullscreen |
| `$mod + Shift + Space` | Toggle floating mode |
| `$mod + Space` | Toggle focus between floating & tiled |
| `$mod + a` | Focus parent container |
| `$mod + r` | Enter resize mode (`Escape` or `Return` to exit) |
| `$mod + Shift + -` | Move window to scratchpad |
| `$mod + -` | Show scratchpad window |

### Screenshots (Grimshot)
| Shortcut | Action |
| :--- | :--- |
| `Print` | Capture current display output (save & copy to clipboard) |
| `Alt + Print` | Capture active window (save & copy to clipboard) |
| `Ctrl + Print` | Select area to capture with `slurp` (save & copy to clipboard) |

### Brightness
| Shortcut | Action |
| :--- | :--- |
| `$mod + [` / `XF86MonBrightnessDown` | Dim the **focused** screen (laptop never below 1%) |
| `$mod + ]` / `XF86MonBrightnessUp` | Brighten the **focused** screen |

The laptop panel uses `brightnessctl`; the external monitor uses `ddcutil` (DDC/CI). A dunst progress bar shows the new level.

### Tools
| Shortcut | Action |
| :--- | :--- |
| `$mod + n` | Toggle night light (`wlsunset`, constant 3500K tint) |
| `Shift + Print` | Start/stop recording a selected area (`wf-recorder`, saved to `~/Videos/recordings`) |
| `$mod + Shift + Return` | Toggle the floating drop-down terminal (kept in the scratchpad) |
| `$mod + c` | Calculator (`qalc` in rofi; select the result + Enter to copy it) |
| `$mod + .` | Emoji picker (`rofimoji`, types the emoji into the focused window) |

### Notifications
| Shortcut | Action |
| :--- | :--- |
| `$mod + grave` (key left of `1`) | Bring back the last notification |
| `$mod + Shift + grave` | Dismiss all notifications |
| `$mod + Shift + n` | Toggle do-not-disturb (notifications queue up and show when turned off) |

A battery watcher warns at 15% and again (critical) at 5% while discharging.

### Session & System
| Shortcut | Action |
| :--- | :--- |
| `$mod + Shift + r` | Reload Sway configuration |
| `$mod + Shift + Escape` | Lock screen (`swaylock`) |
| Waybar power-profile indicator (click) | Cycle power profile (Power-saver → Balanced → Performance) |

---

## 🛠️ Installation (fresh Fedora)

```bash
git clone git@github.com:ashishreddy-15/swaywm.git ~/swaywm
cd ~/swaywm
./install.sh --dry-run          # see what it would do
./install.sh                    # do it
./install.sh --with-snapshots   # ...and set up btrfs snapshots (sudo)
```

[`install.sh`](install.sh) is safe to re-run; each step checks first:

1. **Packages**: installs whatever is missing from its list with `sudo dnf` (`--no-packages` skips this). Hardware video decoding in mpv also needs `intel-media-driver` from RPM Fusion.
2. **starship**: official installer, if not present (it is not in Fedora's repos).
3. **Font**: Maple Mono NF into `~/.local/share/fonts`, if not present.
4. **Dotfiles**: stows every package. Real files that would block a symlink are moved to `~/.dotfiles-backup-<date>/`, never deleted.
5. **Desktop settings**: GTK dark theme and subpixel font smoothing (`gsettings`).
6. **Default apps**: images → Loupe, video/audio → mpv, PDF → zathura (`xdg-mime`; not stowed, because apps rewrite `mimeapps.list`).
7. **Services & folders**: enables `kanshi.service`; creates `~/Pictures/mpv` and `~/Videos/recordings`.

---

## 📸 Snapshots (btrfs + snapper)

[`setup/snapshots.sh`](setup/snapshots.sh) (run with `--with-snapshots`, or on its own) sets up:

* **`/` (root)**: a pre/post snapshot pair around every `dnf` transaction, via the dnf5 actions plugin ([`setup/snapper.actions`](setup/snapper.actions), taken from `libdnf5-actions(8)`). Keeps the last 20.
* **`/home`**: hourly snapshots; keeps 12 hourly, 7 daily, 4 weekly.

```bash
snapper -c root list                       # what dnf changed, as numbered pairs
snapper -c root status 41..42              # files changed by one update
sudo snapper -c root undochange 41..42     # revert that update's file changes
snapper -c home list
cp /home/.snapshots/<N>/snapshot/ashish/<file> ~/   # recover a deleted/overwritten file
```

`/boot` is a separate ext4 partition, so roll back updates with `undochange` (file level), not by booting a snapshot.
Snapshots live on the same disk: they undo mistakes, they are **not** a backup against disk failure or a lost laptop.

---

## 📂 Repository Layout

```
~/swaywm/
├── README.md
├── .gitignore
├── .stowrc
├── colors.md                 # shared palette (hex copied into each config)
├── install.sh                # bootstrap a fresh Fedora install
├── setup/                    # system-level, not stowed
│   ├── snapshots.sh
│   └── snapper.actions
├── bash/
│   ├── .bashrc
│   ├── .bash_profile
│   ├── .inputrc
│   └── .bashrc.d/            # 01-env 02-aliases 03-fzf 04-zoxide 05-starship 06-functions
├── sway/
│   └── .config/sway/
│       ├── config
│       ├── environment
│       ├── config.d/                 # only files that override Fedora's defaults
│       │   ├── 50-rules-windows.conf
│       │   ├── 60-bindings-brightness.conf
│       │   ├── 60-bindings-screenshot.conf
│       │   ├── 60-bindings-tools.conf
│       │   └── 90-swayidle.conf
│       └── scripts/
│           ├── battery-notify.sh
│           ├── brightness.sh
│           ├── calc.sh
│           ├── clipboard-menu.sh
│           ├── dnd.sh
│           ├── dropdown.sh
│           ├── lid-handler.sh
│           ├── nightlight.sh
│           ├── power-menu.sh
│           ├── record.sh
│           └── rofi-toggle.sh
├── kanshi/
│   └── .config/kanshi/
│       └── config
├── waybar/
│   └── .config/waybar/
│       ├── config.jsonc          # one block per screen
│       ├── modules.jsonc         # module settings shared by both bars
│       └── style.css
├── rofi/
│   └── .config/rofi/
│       └── config.rasi
├── dunst/
│   └── .config/dunst/
│       └── dunstrc
├── foot/
│   └── .config/foot/
│       └── foot.ini
├── swaylock/
│   └── .config/swaylock/
│       └── config
├── starship/
│   └── .config/
│       └── starship.toml
├── btop/
│   └── .config/btop/
│       ├── btop.conf
│       └── themes/mono.theme
├── fontconfig/
│   └── .config/fontconfig/
│       └── fonts.conf
├── xdg-desktop-portal-wlr/
│   └── .config/xdg-desktop-portal-wlr/
│       └── config
├── mpv/
│   └── .config/mpv/
│       ├── mpv.conf
│       ├── input.conf
│       └── script-opts/osc.conf
├── zathura/
│   └── .config/zathura/
│       └── zathurarc
└── nvim/
    └── .config/nvim/
        ├── init.lua
        ├── lazy-lock.json
        ├── colors/
        └── lua/
```
