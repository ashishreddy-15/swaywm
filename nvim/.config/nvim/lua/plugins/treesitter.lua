return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  event = { "BufReadPost", "BufNewFile" },
  build = ":TSUpdate",
  config = function()
    local ts = require("nvim-treesitter")

    ts.setup()

    local ensure_installed = {
      "c",
      "lua",
      "vim",
      "vimdoc",
      "query",
      "bash",
      "markdown",
      "python",
      "javascript",
      "typescript",
      "go",
      "java",
      "xml",  -- for Spring XML configs (application context, pom.xml)
      "yaml", -- for application.yml
    }

    ts.install(ensure_installed)

    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
      end,
    })
  end,
}
