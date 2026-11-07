# Sway Dual-Monitor Dotfiles

A clean, modular, and keyboard-driven Wayland desktop setup powered by **Sway WM**, managed effortlessly with **GNU Stow**.

Configured specifically for a **dual-monitor productivity workflow** (Laptop + 27" 1440p 100Hz External Display) with automatic display detection via **Kanshi**, seamless **clamshell mode** handling, and dynamic workspace routing.

---

## 🎨 Color Scheme

Monochrome greys plus one blue-grey accent (`#7aa2c8`) used for focus only. See [`colors.md`](colors.md) for the palette and where it is applied.

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
| **`nvim`** | `~/.config/nvim` | Neovim IDE configuration (lazy.nvim, Treesitter, LSP, Telescope, Oil, and completion). |

---

## 🚀 Managing Dotfiles with GNU Stow

[GNU Stow](https://www.gnu.org/software/stow/) manages symlinks from this repository directly into `$HOME` (`~/.config/...`).

The repo's [`.stowrc`](.stowrc) sets the defaults, so plain `stow` commands work from `~/swaywm`:

* `--target=~`: links go into your home directory.
* `--no-folding`: every file gets its own symlink and directories like `~/.config/sway` stay real. Logs and caches that apps write into their config dir (e.g. `btop.log`) stay out of the repo, and new files you add to the repo only appear after a restow.
* `--ignore=\.bak...`: `*.bak` backups are never linked.

```bash
cd ~/swaywm
stow -v */            # stow every package
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
| `$mod + 1` .. `$mod + 0` | Switch to workspace 1 - 10 |
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

### Session & System
| Shortcut | Action |
| :--- | :--- |
| `$mod + Shift + r` | Reload Sway configuration |
| `$mod + Shift + Escape` | Lock screen (`swaylock`) |
| Waybar power-profile indicator (click) | Cycle power profile (Power-saver → Balanced → Performance) |

---

## 🛠️ Required Dependencies

On **Fedora / RHEL**:
```bash
sudo dnf install -y \
    sway swayidle swaylock \
    waybar kanshi rofi-wayland dunst foot \
    grim slurp grimshot \
    cliphist wl-clipboard libnotify \
    brightnessctl ddcutil xdg-desktop-portal-wlr \
    jq btop starship power-profiles-daemon \
    neovim ripgrep fd-find \
    stow git
```

### Kanshi User Service
Ensure the `kanshi` systemd service is active so hotplug display events run automatically:
```bash
systemctl --user enable --now kanshi.service
```

---

## 📂 Repository Layout

```
~/swaywm/
├── README.md
├── .gitignore
├── .stowrc
├── colors.md                 # shared palette (hex copied into each config)
├── sway/
│   └── .config/sway/
│       ├── config
│       ├── environment
│       ├── config.d/                 # only files that override Fedora's defaults
│       │   ├── 60-bindings-brightness.conf
│       │   ├── 60-bindings-screenshot.conf
│       │   └── 90-swayidle.conf
│       └── scripts/
│           ├── brightness.sh
│           ├── clipboard-menu.sh
│           ├── lid-handler.sh
│           ├── power-menu.sh
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
└── nvim/
    └── .config/nvim/
        ├── init.lua
        ├── lazy-lock.json
        ├── colors/
        └── lua/
```
