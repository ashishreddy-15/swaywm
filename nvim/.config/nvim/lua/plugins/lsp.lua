return {
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("mason").setup()

      -- Broadcast nvim-cmp completion capabilities to LSP servers
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      if has_cmp then
        capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
      end

      -- Configure global defaults for all LSP servers via native vim.lsp.config (Neovim 0.11+)
      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      -- Server-specific configuration overrides
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              checkThirdParty = false,
            },
          },
        },
      })

      -- YAML LSP with Spring Boot application.yml schema
      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            keyOrdering = false,
            format = { enable = true },
            validate = true,
            schemas = {
              -- Spring Boot application.yml IntelliSense
              ["https://json.schemastore.org/spring-boot-application.json"] = {
                "application*.yml",
                "application*.yaml",
              },
              -- Maven POM (handled via XML LSP, but YAML schema for reference)
            },
          },
        },
      })

      -- Automatically install LSP servers and enable them via vim.lsp.enable()
      -- Note: Java & Kotlin LSP is managed separately by JetBrains/intellij-lsp.nvim
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",   -- Lua (Neovim configuration & scripts)
          "pyright",  -- Python
          "ts_ls",    -- JavaScript & TypeScript
          "gopls",    -- Go
          "yamlls",   -- YAML (application.yml / Docker Compose / CI configs)
          "lemminx",  -- XML (Eclipse LemMinX language server)
        },
        automatic_enable = true,
      })

      -- Automatically install formatters used by conform.nvim
      require("mason-tool-installer").setup({
        ensure_installed = {
          "stylua",
          "black",
          "xmlformatter", -- XML formatter
        },
      })

      -- Diagnostic keymaps (accessible globally, using Neovim 0.11+ vim.diagnostic.jump)
      vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
      vim.keymap.set("n", "[d", function()
        vim.diagnostic.jump({ count = -1, float = true })
      end, { desc = "Previous Diagnostic" })
      vim.keymap.set("n", "]d", function()
        vim.diagnostic.jump({ count = 1, float = true })
      end, { desc = "Next Diagnostic" })

      -- LSP Keymaps on attach
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          local has_telescope, builtin = pcall(require, "telescope.builtin")

          -- Navigation & References
          map("gd", function()
            if has_telescope then builtin.lsp_definitions() else vim.lsp.buf.definition() end
          end, "Goto Definition")

          map("gD", vim.lsp.buf.declaration, "Goto Declaration")

          map("gI", function()
            if has_telescope then builtin.lsp_implementations() else vim.lsp.buf.implementation() end
          end, "Goto Implementation")

          map("gr", function()
            if has_telescope then builtin.lsp_references() else vim.lsp.buf.references() end
          end, "Goto References / Usages")

          -- Actions & Documentation
          map("K", vim.lsp.buf.hover, "Hover Documentation")
          map("<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
          map("<leader>ca", vim.lsp.buf.code_action, "Code Action")

          -- Toggle Inlay Hints (Neovim 0.10+)
          if client and client:supports_method("textDocument/inlayHint", event.buf) then
            map("<leader>ti", function()
              local is_enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
              vim.lsp.inlay_hint.enable(not is_enabled, { bufnr = event.buf })
            end, "Toggle Inlay Hints")
          end
        end,
      })
    end,
  },
}
