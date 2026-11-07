# Sway Dual-Monitor Dotfiles

A clean, modular, and keyboard-driven Wayland desktop setup powered by **Sway WM**, managed effortlessly with **GNU Stow**.

Configured specifically for a **dual-monitor productivity workflow** (Laptop + 27" 1440p 100Hz External Display) with automatic display detection via **Kanshi**, seamless **clamshell mode** handling, and dynamic workspace routing.

---

## 🖥️ Display & Workspace Architecture

### Physical Layout

```
┌──────────────────┐  ┌─────────────────────────────────────────┐
│      eDP-1       │  │                HDMI-A-1                 │
│  Laptop Display  │  │        Samsung 27" Quad HD @ 100Hz      │
│    1920 x 1200   │  │               2560 x 1440               │
│   Position: 0,0  │  │            Position: 1920, 0            │
│  Workspaces 6-10 │  │             Workspaces 1-5              │
└──────────────────┘  └─────────────────────────────────────────┘
```

### Dynamic Multi-Monitor Management

* **[Kanshi](https://sr.ht/~emersion/kanshi/) Profile Switching**:
  * **`dual` profile**: Automatically triggers when the HDMI cable is connected. Configures positions and executes [`migrate-workspaces.sh dual`](file:///home/ashish/swaywm/sway/.config/sway/scripts/migrate-workspaces.sh).
  * **`solo` profile**: Automatically detects HDMI disconnect and consolidates all active workspaces onto the laptop display via [`migrate-workspaces.sh solo`](file:///home/ashish/swaywm/sway/.config/sway/scripts/migrate-workspaces.sh).
* **Clamshell Mode**:
  * Closing the laptop lid with an external display connected disables `eDP-1`, repositions `HDMI-A-1` to `(0, 0)`, and routes all workspaces to the external screen without interruption via [`lid-handler.sh`](file:///home/ashish/swaywm/sway/.config/sway/scripts/lid-handler.sh).
  * Opening the lid restores the dual-screen configuration and redistributes workspaces.
* **Workspace Pinning**:
  * Workspaces `1` to `5` are bound to `HDMI-A-1` (fallback to `eDP-1`).
  * Workspaces `6` to `10` are bound to `eDP-1` (fallback to `HDMI-A-1`).
  * Jump focus between displays at any time with `$mod + Tab`.

---

## 📦 Packages & Components

Each component is modularized as an independent GNU Stow package:

| Package | Target Location | Description |
| :--- | :--- | :--- |
| **`sway`** | `~/.config/sway` | Core window manager config, keybindings, drop-in configs (`config.d/`), and utility scripts (`scripts/`). |
| **`kanshi`** | `~/.config/kanshi` | Display auto-detection daemon and dual/solo monitor profiles. |
| **`waybar`** | `~/.config/waybar` | Status bar with workspace indicators, hardware monitors, and power profile switcher. |
| **`rofi`** | `~/.config/rofi` | Application launcher, power menu, and clipboard menu (`Arc-Dark` theme). |
| **`dunst`** | `~/.config/dunst` | Notification daemon configured with mouse-follow across dual monitors. |
| **`foot`** | `~/.config/foot` | Ultra-fast Wayland-native terminal emulator configured with Maple Mono NF. |
| **`swaylock`** | `~/.config/swaylock` | Minimal black screen locker integrated with `swayidle`. |
| **`starship`** | `~/.config/starship.toml` | Fast, informative two-line shell prompt (Catppuccin Mocha theme). |
| **`btop`** | `~/.config/btop` | Terminal system resource monitor. |
| **`fontconfig`** | `~/.config/fontconfig` | Font configuration directing to `~/.local/share/fonts`. |
| **`nvim`** | `~/.config/nvim` | Neovim IDE configuration (lazy.nvim, Treesitter, LSP, Telescope, Oil, and completion). |

---

## 🚀 Managing Dotfiles with GNU Stow

[GNU Stow](https://www.gnu.org/software/stow/) manages symlinks from this repository directly into `$HOME` (`~/.config/...`).

### Stow All Packages
To symlink all configuration packages at once:

```bash
cd ~/swaywm
stow -v -t ~ */
```

*(Or specify package names explicitly)*:
```bash
cd ~/swaywm
stow -v -t ~ sway kanshi waybar rofi dunst foot swaylock starship btop fontconfig nvim
```

### Stow an Individual Package
```bash
cd ~/swaywm
stow -v -t ~ sway
```

### Unstow / Remove Symlinks
To remove the symlinks for a package:
```bash
cd ~/swaywm
stow -D -v -t ~ sway
```

### Restow / Refresh Symlinks
If you add or rename files within a package:
```bash
cd ~/swaywm
stow -R -v -t ~ sway
```

### Dry Run (Test Before Stowing)
```bash
cd ~/swaywm
stow -n -v -t ~ sway
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
| `$mod + v` | Toggle Rofi clipboard history (`cliphist`) |
| `$mod + q` | Close focused window |
| `$mod + Shift + e` | Emergency exit / power menu |

### Navigation & Focus
| Shortcut | Action |
| :--- | :--- |
| `$mod + h` / `j` / `k` / `l` | Focus left / down / up / right |
| `$mod + Left` / `Down` / `Up` / `Right` | Focus left / down / up / right |
| `$mod + Tab` | Focus next monitor / output |
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

### Session & System
| Shortcut | Action |
| :--- | :--- |
| `$mod + Shift + r` | Reload Sway configuration |
| `$mod + Shift + Escape` | Lock screen (`swaylock`) |
| Waybar Power Icon (Right Click) | Cycle power profile (Power-saver → Balanced → Performance) |

---

## 🛠️ Required Dependencies

On **Fedora / RHEL**:
```bash
sudo dnf install -y \
    sway swayidle swaylock \
    waybar kanshi rofi-wayland dunst foot \
    grim slurp grimshot \
    cliphist wl-clipboard \
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
├── sway/
│   └── .config/sway/
│       ├── config
│       ├── environment
│       ├── sddm-greeter.config
│       ├── config.d/
│       │   ├── 10-systemd-cgroups.conf
│       │   ├── 10-systemd-session.conf
│       │   ├── 60-bindings-screenshot.conf
│       │   └── 90-swayidle.conf
│       └── scripts/
│           ├── clipboard-menu.sh
│           ├── lid-handler.sh
│           ├── migrate-workspaces.sh
│           ├── power-menu.sh
│           └── rofi-toggle.sh
├── kanshi/
│   └── .config/kanshi/
│       └── config
├── waybar/
│   └── .config/waybar/
│       ├── config.jsonc
│       ├── style.css
│       └── cycle-power-profile.sh
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
│       └── btop.conf
├── fontconfig/
│   └── .config/fontconfig/
│       └── fonts.conf
└── nvim/
    └── .config/nvim/
        ├── init.lua
        ├── lazy-lock.json
        ├── colors/
        └── lua/
```
