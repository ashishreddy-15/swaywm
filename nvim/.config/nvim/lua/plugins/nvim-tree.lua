return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  lazy = false,
  init = function()
    -- Disable netrw as recommended by nvim-tree
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
  end,
  keys = {
    { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle File Explorer" },
    { "<leader>o", "<cmd>NvimTreeFocus<cr>", desc = "Focus File Explorer" },
  },
  opts = {
    hijack_netrw = true,
    sync_root_with_cwd = true,
    view = {
      width = 35,
    },
    renderer = {
      group_empty = true,
      icons = {
        show = {
          file = true,
          folder = true,
          folder_arrow = true,
          git = true,
        },
      },
    },
    update_focused_file = {
      enable = true,
    },
    actions = {
      open_file = {
        window_picker = {
          enable = false,
        },
      },
    },
  },
}
