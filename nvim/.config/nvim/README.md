# Neovim Configuration

A clean, modular, and fast Neovim configuration built with [lazy.nvim](https://github.com/folke/lazy.nvim) for reproducible package management and optimized startup times.

---

## 🚀 Features

- **Package Manager**: [lazy.nvim](https://github.com/folke/lazy.nvim) with lazy-loading on keys and events.
- **Theme**: [base46](https://github.com/duxlabs-dev/base46) (`base46-onedark`).
- **File Explorers**:
  - [nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua) for full sidebar project tree navigation and directory hijacking.
  - [oil.nvim](https://github.com/stevearc/oil.nvim) for fast buffer-like floating directory edits.
- **LSP & Tooling**:
  - Native `vim.lsp.config` (Neovim 0.11+) + [mason.nvim](https://github.com/williamboman/mason.nvim).
  - [intellij-lsp.nvim](https://github.com/JetBrains/intellij-lsp.nvim) — JetBrains' official Language Server client for Java & Kotlin (AST intelligence, quick fixes, code lenses, run/debug, decompilation).
  - [lazydev.nvim](https://github.com/folke/lazydev.nvim) for Lua and Neovim API typing.
  - Configured LSP servers: `lua_ls` (Lua), `pyright` (Python), `ts_ls` (JavaScript / TypeScript), `gopls` (Go), `yamlls` (YAML / Spring Boot application.yml), `lemminx` (XML / pom.xml).
  - Diagnostic keymaps, code actions, and inlay hint toggles.
- **Debugging & Testing**:
  - [nvim-dap](https://github.com/mfussenegger/nvim-dap) with [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui) and [nvim-dap-virtual-text](https://github.com/theHamsta/nvim-dap-virtual-text) for full breakpoint debugging (integrated with IntelliJ run/debug & Spring Boot attach support).
  - [neotest](https://github.com/nvim-neotest/neotest) with [neotest-java](https://github.com/rcasia/neotest-java) for inline JUnit / test execution and test debugging.
- **Completion**: [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) with LuaSnip, [friendly-snippets](https://github.com/rafamadriz/friendly-snippets), and LSP/buffer/path sources.
- **Syntax Highlighting**: [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) (C, Lua, Vim, Bash, Python, JS, TS, Go, Java, XML, YAML, Markdown).
- **Fuzzy Finder**: [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) with C-accelerated [telescope-fzf-native.nvim](https://github.com/nvim-telescope/telescope-fzf-native.nvim).
- **Formatting**:
  - Java: IntelliJ native `format_on_save = true` via `intellij-lsp.nvim`.
  - [conform.nvim](https://github.com/stevearc/conform.nvim) for Lua (`stylua`), Python (`black`), and XML (`xmlformatter`).
- **Git Integration**: [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) with hunk navigation and line blame.
- **Productivity & UI**:
  - [bufferline.nvim](https://github.com/akinsho/bufferline.nvim) for visual tabs with unsaved indicator (`●`), LSP diagnostic badges, and buffer switching.
  - [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) for persistent terminal drawers and floating terminals without polluting buffers.
  - [which-key.nvim](https://github.com/folke/which-key.nvim) for contextual keybinding hints.
  - [mini.nvim](https://github.com/echasnovski/mini.nvim) (`mini.pairs`, `mini.surround`, `mini.statusline`, `mini.bufremove`).

---

## 📂 Project Structure

```text
~/.config/nvim/
├── init.lua                # Entry point & lazy.nvim bootstrapping
├── lazy-lock.json          # Locked plugin versions
└── lua/
    ├── config/
    │   ├── keymaps.lua     # General ergonomic keybindings
    │   └── options.lua     # Editor options and settings
    └── plugins/
        ├── bufferline.lua    # Top tabline with unsaved modified indicators (●)
        ├── colorscheme.lua   # Base46 & Tokyonight colorschemes
        ├── completion.lua    # nvim-cmp, LuaSnip & friendly-snippets
        ├── conform.lua       # Formatter configuration (stylua, black, xmlformatter)
        ├── dap.lua           # Debug Adapter Protocol (nvim-dap, dap-ui, Spring Boot attach)
        ├── gitsigns.lua      # Git decorations & hunk actions
        ├── intellij-lsp.lua  # JetBrains IntelliJ Language Server client (Java & Kotlin)
        ├── lsp.lua           # LSP setup (yamlls, lemminx, lua_ls, pyright, ts_ls, gopls)
        ├── mini.lua          # mini.nvim modules
        ├── neotest.lua       # Test runner (neotest, neotest-java)
        ├── nvim-tree.lua     # NvimTree sidebar & directory handler
        ├── oil.lua           # Oil floating file manager
        ├── telescope.lua     # Fuzzy search with fzf-native
        ├── toggleterm.lua    # Persistent terminal drawers (Ctrl+\) and floats
        ├── treesitter.lua    # Treesitter parsing
        └── which-key.lua     # WhichKey menu
```

---

## ⌨️ Keybindings

Leader key is mapped to `<Space>`.

### General & Navigation
| Key | Mode | Description |
| --- | --- | --- |
| `jj` or `jk` | Insert | Exit to Normal mode |
| `<Esc>` or `<leader>h` | Normal | Clear search highlights (`:nohlsearch`) |
| `<leader>w` | Normal | Save file (`:w`) |
| `<leader>q` | Normal | Quit window (`:q`) |
| `<leader>Q` | Normal | Force quit all (`:qa!`) |
| `<C-h/j/k/l>` | Normal | Navigate split windows |
| `<leader>sv` / `<leader>sh` | Normal | Split vertical / horizontal |
| `<leader>se` / `<leader>sx` | Normal | Equalize splits / Close split |
| `<C-Up/Down/Left/Right>` | Normal | Resize splits |
| `<S-h>` / `<S-l>` or `[b` / `]b` | Normal | Previous / Next buffer tab (BufferLine) |
| `<leader>bp` | Normal | Pick buffer tab interactively |
| `<leader>bc` | Normal | Pick buffer tab to close |
| `<leader>bd` | Normal | Delete buffer safely (preserves splits) |
| `<C-d>` / `<C-u>` | Normal | Half-page down / up (centered) |
| `n` / `N` | Normal | Search next / previous (centered) |
| `<A-j>` / `<A-k>` | Visual / Normal | Move selected line(s) down / up |
| `<` / `>` | Visual | Indent left / right (maintains selection) |

### File Explorers
| Key | Mode | Description |
| --- | --- | --- |
| `<leader>e` | Normal | Toggle NvimTree sidebar |
| `<leader>o` | Normal | Focus NvimTree sidebar |
| `-` | Normal | Open Oil floating file explorer |

### Fuzzy Finder (Telescope)
| Key | Mode | Description |
| --- | --- | --- |
| `<leader>ff` | Normal | Find files |
| `<leader>fg` | Normal | Live grep |
| `<leader>fr` | Normal | Recent files |
| `<leader>fs` | Normal | Document symbols |
| `<leader>fd` | Normal | Workspace diagnostics |
| `<leader><space>` | Normal | Open buffers list |

### LSP & Code
| Key | Mode | Description |
| --- | --- | --- |
| `gd` | Normal | Go to definition |
| `gD` | Normal | Go to declaration |
| `gI` | Normal | Go to implementation |
| `gr` | Normal | Go to references / usages (Telescope) |
| `K` | Normal | Hover documentation |
| `<leader>rn` | Normal | Rename symbol |
| `<leader>ca` | Normal | Code actions |
| `<leader>cf` | Normal / Visual | Format buffer (Conform) |
| `<leader>cd` | Normal | Show line diagnostics float |
| `[d` / `]d` | Normal | Jump to previous / next diagnostic |
| `<leader>ti` | Normal | Toggle LSP inlay hints |

### Java & Kotlin (IntelliJ LSP)
| Key | Mode | Description |
| --- | --- | --- |
| `<leader>rr` | Normal | Run main class at cursor |
| `<leader>rd` | Normal | Debug class at cursor (DAP) |
| `<leader>rl` | Normal | Run code lens on current line |
| `grr` | Normal | IntelliJ references with live floating preview |
| `<leader>ci` / `<leader>co` | Normal | Call hierarchy: incoming / outgoing calls |
| `<leader>ts` / `<leader>tu` | Normal | Type hierarchy: subtypes / supertypes |
| `<leader>ws` | Normal | Search workspace symbols |
| `gra` | Normal | IntelliJ intentions and quick fixes |
| `:IntellijLspLicense` | Command | Manage license (30-day trial / JetBrains Account) |

### Git (Gitsigns)
| Key | Mode | Description |
| --- | --- | --- |
| `]h` / `[h` | Normal | Next / previous git hunk |
| `<leader>gp` | Normal | Preview hunk |
| `<leader>gb` | Normal | Toggle current line blame |

### Debugging (nvim-dap)
| Key | Mode | Description |
| --- | --- | --- |
| `<leader>db` | Normal | Toggle breakpoint |
| `<leader>dB` | Normal | Set conditional breakpoint |
| `<leader>dc` | Normal | Continue / Start debugging (Attach to Spring Boot :5005) |
| `<leader>di` | Normal | Step into |
| `<leader>do` | Normal | Step over |
| `<leader>dO` | Normal | Step out |
| `<leader>dr` | Normal | Open REPL |
| `<leader>dl` | Normal | Run last |
| `<leader>dt` | Normal | Terminate session |
| `<leader>du` | Normal | Toggle DAP UI |
| `<leader>de` | Normal / Visual | Evaluate expression |

### Tests (neotest)
| Key | Mode | Description |
| --- | --- | --- |
| `<leader>tt` | Normal | Run nearest test |
| `<leader>tf` | Normal | Run file tests |
| `<leader>tT` | Normal | Run full test suite |
| `<leader>ts` | Normal | Toggle test summary panel |
| `<leader>to` | Normal | Show test output float |
| `<leader>tO` | Normal | Toggle test output panel |
| `<leader>tS` | Normal | Stop running tests |
| `<leader>td` | Normal | Debug nearest test (DAP) |

### Terminal (ToggleTerm)
| Key | Mode | Description |
| --- | --- | --- |
| `<C-\>` | Normal / Terminal | Toggle persistent bottom terminal drawer |
| `<leader>Tt` | Normal | Toggle horizontal drawer terminal |
| `<leader>Tf` | Normal | Toggle centered floating terminal |
| `<leader>Tv` | Normal | Toggle vertical side terminal split |
| `<Esc><Esc>` | Terminal | Exit terminal mode to normal mode |

### Build Tools (Maven & Gradle)
| Key | Mode | Description |
| --- | --- | --- |
| `<leader>mb` | Normal | Maven: Build (`clean install -DskipTests`) |
| `<leader>mr` | Normal | Maven: Run (`spring-boot:run`) |
| `<leader>mt` | Normal | Maven: Test (`mvn test`) |
| `<leader>mT` | Normal | Maven: Clean test (`mvn clean test`) |
| `<leader>mc` | Normal | Maven: Clean (`mvn clean`) |
| `<leader>mp` | Normal | Maven: Package (`mvn clean package -DskipTests`) |
| `<leader>Gb` | Normal | Gradle: Build (`gradlew build -x test`) |
| `<leader>Gr` | Normal | Gradle: Run (`gradlew bootRun`) |
| `<leader>Gt` | Normal | Gradle: Test (`gradlew test`) |
| `<leader>GT` | Normal | Gradle: Clean test (`gradlew clean test`) |
| `<leader>Gc` | Normal | Gradle: Clean (`gradlew clean`) |
| `<leader>Gp` | Normal | Gradle: Package (`gradlew bootJar`) |

---

## 🛠️ Installation

```bash
git clone git@gitlab.com:ashish_ette/dotfiles/nvim.git ~/.config/nvim
nvim
```
Plugins will be automatically cloned and installed on first startup by `lazy.nvim`.
