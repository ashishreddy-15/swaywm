-- Custom keymaps
-- Define non-plugin global keymaps here using vim.keymap.set

local map = vim.keymap.set

local function opt(desc)
  return { noremap = true, silent = true, desc = desc }
end

-- ==========================================
-- Insert Mode
-- ==========================================
-- Fast exit to normal mode
map("i", "jj", "<Esc>", opt("Exit insert mode"))
map("i", "jk", "<Esc>", opt("Exit insert mode"))

-- ==========================================
-- General & File Operations
-- ==========================================
-- Clear search highlights with Esc or <leader>h
map("n", "<Esc>", "<cmd>nohlsearch<CR>", opt("Clear search highlights"))
map("n", "<leader>h", "<cmd>nohlsearch<CR>", opt("Clear search highlights"))

-- Fast save and quit
map("n", "<leader>w", "<cmd>w<CR>", opt("Save file"))
map("n", "<leader>q", "<cmd>q<CR>", opt("Quit window"))
map("n", "<leader>Q", "<cmd>qa!<CR>", opt("Quit all without saving"))

-- Quickfix list management
map("n", "<leader>xq", "<cmd>cclose<CR>", opt("Close Quickfix list"))

-- Automatically allow pressing 'q' to close helper windows like quickfix
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "qf", "help", "man", "lspinfo" },
  callback = function(event)
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true, desc = "Close window" })
  end,
})

-- ==========================================
-- Navigation & Scrolling
-- ==========================================
-- Better vertical movement for wrapped lines
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "Down" })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "Up" })

-- Keep cursor centered when scrolling half-page
map("n", "<C-d>", "<C-d>zz", opt("Scroll down and center"))
map("n", "<C-u>", "<C-u>zz", opt("Scroll up and center"))

-- Keep search results centered in the screen
map("n", "n", "nzzzv", opt("Next search result (centered)"))
map("n", "N", "Nzzzv", opt("Previous search result (centered)"))

-- ==========================================
-- Window Management
-- ==========================================
-- Navigate between split windows easily using Ctrl + hjkl
map("n", "<C-h>", "<C-w>h", opt("Navigate to left window"))
map("n", "<C-j>", "<C-w>j", opt("Navigate to lower window"))
map("n", "<C-k>", "<C-w>k", opt("Navigate to upper window"))
map("n", "<C-l>", "<C-w>l", opt("Navigate to right window"))

-- Window splits
map("n", "<leader>sv", "<cmd>vsplit<CR>", opt("Split window vertically"))
map("n", "<leader>sh", "<cmd>split<CR>", opt("Split window horizontally"))
map("n", "<leader>se", "<C-w>=", opt("Make split windows equal size"))
map("n", "<leader>sx", "<cmd>close<CR>", opt("Close current split window"))

-- Resize windows with Ctrl + Arrow keys
map("n", "<C-Up>", "<cmd>resize -2<CR>", opt("Resize window up"))
map("n", "<C-Down>", "<cmd>resize +2<CR>", opt("Resize window down"))
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", opt("Resize window left"))
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", opt("Resize window right"))

-- ==========================================
-- Buffer Navigation (BufferLine)
-- ==========================================
map("n", "<S-h>", "<cmd>BufferLineCyclePrev<CR>", opt("Previous buffer"))
map("n", "<S-l>", "<cmd>BufferLineCycleNext<CR>", opt("Next buffer"))
map("n", "[b", "<cmd>BufferLineCyclePrev<CR>", opt("Previous buffer"))
map("n", "]b", "<cmd>BufferLineCycleNext<CR>", opt("Next buffer"))
map("n", "<leader>bp", "<cmd>BufferLinePick<CR>", opt("Pick buffer"))
map("n", "<leader>bc", "<cmd>BufferLinePickClose<CR>", opt("Pick buffer to close"))

-- Delete current buffer without closing window split
map("n", "<leader>bd", function()
  local ok, bufremove = pcall(require, "mini.bufremove")
  if ok then
    bufremove.delete(0, false)
  else
    vim.cmd("bdelete")
  end
end, opt("Delete current buffer"))

-- ==========================================
-- Text Editing & Visual Mode
-- ==========================================
-- Stay in visual mode when indenting (using 'x' mode to avoid select-mode conflicts)
map("x", "<", "<gv", opt("Indent left and stay in visual mode"))
map("x", ">", ">gv", opt("Indent right and stay in visual mode"))

-- Move selected lines up/down in visual mode with Alt + j/k (preserves 'J' for joining lines)
map("x", "<A-j>", ":m '>+1<CR>gv=gv", opt("Move selection down"))
map("x", "<A-k>", ":m '<-2<CR>gv=gv", opt("Move selection up"))

-- Move current line up/down in normal mode with Alt + j/k
map("n", "<A-j>", "<cmd>m .+1<CR>==", opt("Move line down"))
map("n", "<A-k>", "<cmd>m .-2<CR>==", opt("Move line up"))

-- Paste over selection without replacing the clipboard register
map("x", "<leader>p", [["_dP]], opt("Paste without replacing register"))

-- Delete without yanking into default register
map({ "n", "v" }, "<leader>d", [["_d]], opt("Delete without yanking"))

-- ==========================================
-- Terminal Keymaps & Mode
-- ==========================================
-- Exit terminal mode easily with double Escape
map("t", "<Esc><Esc>", "<C-\\><C-n>", opt("Exit terminal mode"))

-- Toggle persistent terminal drawer with Ctrl+\ from normal or terminal mode
map({ "n", "t" }, "<C-\\>", "<cmd>ToggleTerm<CR>", opt("Toggle terminal drawer"))
map("n", "<leader>Tt", "<cmd>ToggleTerm direction=horizontal<CR>", opt("Terminal drawer (horizontal)"))
map("n", "<leader>Tf", "<cmd>ToggleTerm direction=float<CR>",      opt("Terminal floating window"))
map("n", "<leader>Tv", "<cmd>ToggleTerm direction=vertical size=60<CR>", opt("Terminal split (vertical)"))

-- ==========================================
-- Spring Boot / Java Build Tools
-- ==========================================
-- Helper to run commands in persistent terminal drawer without creating new buffers
local function run_in_term(cmd)
  local ok, toggleterm = pcall(require, "toggleterm")
  if ok then
    toggleterm.exec(cmd, 1, 15, nil, "horizontal")
  else
    vim.cmd("split | terminal " .. cmd)
  end
end

-- Maven shortcuts (persistent terminal drawer, no new buffers)
map("n", "<leader>mb", function() run_in_term("mvn clean install -DskipTests") end, opt("Maven: Build (skip tests)"))
map("n", "<leader>mr", function() run_in_term("mvn spring-boot:run") end,           opt("Maven: Run Spring Boot"))
map("n", "<leader>mt", function() run_in_term("mvn test") end,                      opt("Maven: Run all tests"))
map("n", "<leader>mT", function() run_in_term("mvn clean test") end,                opt("Maven: Clean + run all tests"))
map("n", "<leader>mc", function() run_in_term("mvn clean") end,                     opt("Maven: Clean"))
map("n", "<leader>mp", function() run_in_term("mvn clean package -DskipTests") end, opt("Maven: Package (skip tests)"))

-- Gradle shortcuts (persistent terminal drawer, no new buffers)
map("n", "<leader>Gb", function() run_in_term("./gradlew build -x test") end,       opt("Gradle: Build (skip tests)"))
map("n", "<leader>Gr", function() run_in_term("./gradlew bootRun") end,             opt("Gradle: Run Spring Boot"))
map("n", "<leader>Gt", function() run_in_term("./gradlew test") end,                opt("Gradle: Run all tests"))
map("n", "<leader>GT", function() run_in_term("./gradlew clean test") end,          opt("Gradle: Clean + run all tests"))
map("n", "<leader>Gc", function() run_in_term("./gradlew clean") end,               opt("Gradle: Clean"))
map("n", "<leader>Gp", function() run_in_term("./gradlew bootJar") end,             opt("Gradle: Package (bootJar)"))
