-- Colors live in colors/mono.lua (palette: see colors.md in the repo root)
return {
  {
    name = "mono",
    dir = vim.fn.stdpath("config"),
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("mono")
    end,
  },
}
