return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    current_line_blame = false,
    on_attach = function(bufnr)
      local gs = require("gitsigns")

      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = "Git: " .. desc })
      end

      -- Navigation
      map("n", "]h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        elseif gs.nav_hunk then
          gs.nav_hunk("next")
        else
          gs.next_hunk()
        end
      end, "Next hunk")

      map("n", "[h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        elseif gs.nav_hunk then
          gs.nav_hunk("prev")
        else
          gs.prev_hunk()
        end
      end, "Prev hunk")

      -- Actions
      map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
      map("n", "<leader>gb", gs.toggle_current_line_blame, "Toggle current line blame")
    end,
  },
}

