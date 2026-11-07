return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = { "Oil" },
  keys = {
    {
      "-",
      function()
        require("oil").open_float()
      end,
      mode = "n",
      desc = "Open parent directory",
    },
  },
  opts = {
    default_file_explorer = false,
    view_options = {
      show_hidden = true,
    },
    float = {
      max_width = 80,
      max_height = 25,
      border = "rounded",
    },
  },
}
