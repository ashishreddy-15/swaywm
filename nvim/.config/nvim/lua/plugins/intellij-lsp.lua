return {
  "JetBrains/intellij-lsp.nvim",
  dependencies = { "mfussenegger/nvim-dap" },
  opts = {
    -- Auto-download and cache the published intellij-server bundle for your platform
    server_download = true,

    -- Use your active SDKMAN Java (Java 25) for projects without an explicit SDK
    default_sdk = vim.fn.expand("$HOME/.sdkman/candidates/java/current"),

    -- Apply bundled islands-dark colorscheme
    colorscheme = true,

    -- Format on every save using IntelliJ's code style engine
    format_on_save = true,

    -- Integrated DAP run/debug via IntelliJ
    run = true,
    debug = true,
    build_before_run = true,

    -- Editor features
    keymaps = true, -- registers <leader>rr, <leader>rd, <leader>ci, <leader>ts, etc.
    inlay_hints = true,
    decompiler = true, -- decompiles JDK and library classes automatically
    file_templates = true, -- template skeletons for new Java/Kotlin classes
    references = true, -- grr opens live-previewing references list
    folding = true,
  },
}
