return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "rcasia/neotest-java",
    },
    -- stylua: ignore
    keys = {
      { "<leader>tt", function() require("neotest").run.run() end,                                        desc = "Run nearest test" },
      { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end,                      desc = "Run file tests" },
      { "<leader>tT", function() require("neotest").run.run({ suite = true }) end,                        desc = "Run full test suite" },
      { "<leader>ts", function() require("neotest").summary.toggle() end,                                 desc = "Toggle test summary" },
      { "<leader>to", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Show test output" },
      { "<leader>tO", function() require("neotest").output_panel.toggle() end,                            desc = "Toggle output panel" },
      { "<leader>tS", function() require("neotest").run.stop() end,                                       desc = "Stop running tests" },
      { "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end,                    desc = "Debug nearest test (DAP)" },
    },
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require("neotest").setup({
        adapters = {
          require("neotest-java")({
            -- Use Maven/Gradle wrapper scripts (mvnw / gradlew) when present
            ignore_wrapper = false,
          }),
        },
        -- Show test results inline in the buffer
        output = {
          enabled = true,
          open_on_run = "short", -- auto-open for failures only
        },
        -- Status icons in the sign column
        status = {
          enabled = true,
          signs   = true,
          virtual_text = false,
        },
        -- Summary panel settings
        summary = {
          animated = true,
          enabled  = true,
          mappings = {
            attach        = "a",
            clear_marked  = "M",
            clear_target  = "T",
            debug         = "d",
            debug_marked  = "D",
            expand        = { "<CR>", "<2-LeftMouse>" },
            expand_all    = "e",
            jumpto        = "i",
            mark          = "m",
            next_failed   = "J",
            output        = "o",
            prev_failed   = "K",
            run           = "r",
            run_marked    = "R",
            short         = "O",
            stop          = "u",
            target        = "t",
          },
        },
      })
    end,
  },
}
