return {
  "echasnovski/mini.nvim",
  event = "VeryLazy",
  config = function()
    require("mini.pairs").setup()
    require("mini.surround").setup()
    require("mini.statusline").setup({ use_icons = true })
    require("mini.bufremove").setup()
  end,
}
