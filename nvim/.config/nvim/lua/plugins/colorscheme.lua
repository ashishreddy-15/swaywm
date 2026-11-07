return {
  {
    "duxlabs-dev/base46",
    lazy = false,
    priority = 1000,
    opts = {
      -- Set to true if you want transparent background
      transparency = false,
    },
    config = function(_, opts)
      require("base46").setup(opts)
      -- Default colorscheme; change this to any base46 theme (e.g. base46-onedark, base46-gruvchad, base46-nord, etc.)
      vim.cmd.colorscheme("base46-onedark")
    end,
  },
  {
    "folke/tokyonight.nvim",
    lazy = true,
  },
}


