local opt = vim.opt

-- Line numbers
opt.number = true
-- opt.relativenumber = true

-- Tabs & Indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

-- Search behavior
opt.ignorecase = true
opt.smartcase = true

-- Appearance & UI
opt.wrap = false
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.fillchars = { eob = " " }
opt.pumheight = 10 -- Popup menu max items

-- Splits behavior
opt.splitbelow = true
opt.splitright = true

-- Scroll padding
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Timing & performance
opt.updatetime = 250
opt.timeout = true
opt.timeoutlen = 500 -- Key combination timeout (responsive for jj/jk)
opt.ttimeout = true
opt.ttimeoutlen = 50

-- Editing & Undo
opt.undofile = true -- Persistent undo across sessions
opt.swapfile = false
opt.clipboard = "unnamedplus"
opt.virtualedit = "block"
opt.inccommand = "split" -- Live preview of :%s substitutions
opt.completeopt = { "menu", "menuone", "noselect" }
