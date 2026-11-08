-- Minimal monochrome + one accent (palette: see colors.md)
vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
vim.o.termguicolors = true
vim.o.background = "dark"
vim.g.colors_name = "mono"

local c = {
  bg = "#0f110d", surface = "#161a14", raised = "#222820", border = "#2e342a",
  dim = "#5a6152", muted = "#8c9384", fg = "#e6e8e1",
  accent = "#6fa3b8", red = "#e05555", amber = "#db892d",
}
local function hl(g, o) vim.api.nvim_set_hl(0, g, o) end

local groups = {
  Normal = { fg = c.fg, bg = c.bg }, NormalNC = { fg = c.fg, bg = c.bg },
  NormalFloat = { fg = c.fg, bg = c.surface }, FloatBorder = { fg = c.border, bg = c.surface },
  FloatTitle = { fg = c.accent, bg = c.surface },
  Cursor = { fg = c.bg, bg = c.fg }, CursorLine = { bg = c.surface }, CursorLineNr = { fg = c.accent },
  LineNr = { fg = c.dim }, SignColumn = { bg = c.bg }, ColorColumn = { bg = c.surface },
  Visual = { bg = c.raised }, Search = { fg = c.bg, bg = c.accent }, IncSearch = { fg = c.bg, bg = c.amber },
  CurSearch = { fg = c.bg, bg = c.amber }, MatchParen = { fg = c.accent, bold = true },
  VertSplit = { fg = c.border }, WinSeparator = { fg = c.border },
  StatusLine = { fg = c.fg, bg = c.surface }, StatusLineNC = { fg = c.muted, bg = c.surface },
  Pmenu = { fg = c.fg, bg = c.surface }, PmenuSel = { fg = c.accent, bg = c.raised },
  PmenuSbar = { bg = c.surface }, PmenuThumb = { bg = c.dim },
  TabLine = { fg = c.muted, bg = c.surface }, TabLineSel = { fg = c.accent, bg = c.bg }, TabLineFill = { bg = c.surface },
  Folded = { fg = c.muted, bg = c.surface }, NonText = { fg = c.dim }, Whitespace = { fg = c.border },
  EndOfBuffer = { fg = c.bg }, Directory = { fg = c.accent }, Title = { fg = c.fg, bold = true },
  ErrorMsg = { fg = c.red }, WarningMsg = { fg = c.amber }, MoreMsg = { fg = c.accent }, Question = { fg = c.accent },
  -- syntax: greys, accent for keywords only
  Comment = { fg = c.dim, italic = true }, Constant = { fg = c.fg }, String = { fg = c.muted },
  Character = { fg = c.muted }, Number = { fg = c.fg }, Boolean = { fg = c.fg },
  Identifier = { fg = c.fg }, Function = { fg = c.fg, bold = true },
  Statement = { fg = c.accent }, Keyword = { fg = c.accent }, Conditional = { fg = c.accent },
  Repeat = { fg = c.accent }, Operator = { fg = c.muted }, PreProc = { fg = c.muted },
  Type = { fg = c.fg }, Special = { fg = c.muted }, Delimiter = { fg = c.muted },
  Underlined = { fg = c.accent, underline = true }, Todo = { fg = c.amber, bold = true },
  Error = { fg = c.red },
  -- diagnostics
  DiagnosticError = { fg = c.red }, DiagnosticWarn = { fg = c.amber },
  DiagnosticInfo = { fg = c.muted }, DiagnosticHint = { fg = c.dim },
  DiagnosticUnderlineError = { undercurl = true, sp = c.red }, DiagnosticUnderlineWarn = { undercurl = true, sp = c.amber },
  -- diff / gitsigns
  DiffAdd = { fg = c.fg, bg = c.raised }, DiffChange = { bg = c.surface }, DiffDelete = { fg = c.red },
  DiffText = { fg = c.accent, bg = c.raised }, Added = { fg = c.muted }, Changed = { fg = c.amber }, Removed = { fg = c.red },
  GitSignsAdd = { fg = c.muted }, GitSignsChange = { fg = c.amber }, GitSignsDelete = { fg = c.red },
  -- telescope
  TelescopeBorder = { fg = c.border }, TelescopeSelection = { fg = c.accent, bg = c.raised },
  TelescopeMatching = { fg = c.accent, bold = true }, TelescopePromptPrefix = { fg = c.accent },
}
for g, o in pairs(groups) do hl(g, o) end

-- treesitter links onto the groups above
for g, l in pairs({
  ["@variable"] = "Identifier", ["@property"] = "Identifier", ["@parameter"] = "Identifier",
  ["@function"] = "Function", ["@function.call"] = "Identifier", ["@keyword"] = "Keyword",
  ["@string"] = "String", ["@comment"] = "Comment", ["@type"] = "Type", ["@constant"] = "Constant",
  ["@operator"] = "Operator", ["@punctuation"] = "Delimiter", ["@number"] = "Number",
}) do vim.api.nvim_set_hl(0, g, { link = l }) end
