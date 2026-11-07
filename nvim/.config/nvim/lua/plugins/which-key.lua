return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    spec = {
      { "<leader>b", group = "Buffer" },
      { "<leader>c", group = "Code / LSP" },
      { "<leader>d", group = "Debug (DAP)" },
      { "<leader>f", group = "Find / Telescope" },
      { "<leader>g", group = "Git" },
      { "<leader>G", group = "Gradle" },
      { "<leader>m", group = "Maven" },
      { "<leader>s", group = "Split Window" },
      { "<leader>t", group = "Test / Toggle" },
      { "<leader>T", group = "Terminal" },
      { "<leader>x", group = "Diagnostics / Quickfix" },
    },
  },
}
