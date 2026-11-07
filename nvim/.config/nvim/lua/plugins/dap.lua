return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
    },
    -- stylua: ignore
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end,                                           desc = "Toggle Breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end,        desc = "Conditional Breakpoint" },
      { "<leader>dc", function() require("dap").continue() end,                                                    desc = "Continue / Start" },
      { "<leader>di", function() require("dap").step_into() end,                                                   desc = "Step Into" },
      { "<leader>do", function() require("dap").step_over() end,                                                   desc = "Step Over" },
      { "<leader>dO", function() require("dap").step_out() end,                                                    desc = "Step Out" },
      { "<leader>dr", function() require("dap").repl.open() end,                                                   desc = "Open REPL" },
      { "<leader>dl", function() require("dap").run_last() end,                                                    desc = "Run Last" },
      { "<leader>dt", function() require("dap").terminate() end,                                                   desc = "Terminate Session" },
      { "<leader>du", function() require("dapui").toggle() end,                                                    desc = "Toggle DAP UI" },
      { "<leader>de", function() require("dapui").eval() end,                                                      desc = "Evaluate Expression", mode = { "n", "v" } },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      require("nvim-dap-virtual-text").setup({
        commented = true, -- show virtual text alongside comment
      })

      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
        layouts = {
          {
            elements = {
              { id = "scopes",      size = 0.40 },
              { id = "breakpoints", size = 0.15 },
              { id = "stacks",      size = 0.25 },
              { id = "watches",     size = 0.20 },
            },
            size = 40,
            position = "left",
          },
          {
            elements = {
              { id = "repl",    size = 0.5 },
              { id = "console", size = 0.5 },
            },
            size = 12,
            position = "bottom",
          },
        },
      })

      -- Auto-open/close UI with debug sessions
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- ─── Java / Spring Boot debug configuration ───────────────────────────
      -- The java debug adapter is provided by nvim-jdtls (java-debug extension).
      -- Two modes:
      --   1. "attach"  – connect to a running Spring Boot app on debug port 5005
      --   2. "launch"  – launch a specific main class directly via jdtls
      --
      -- To enable attach mode, start Spring Boot with:
      --   mvn spring-boot:run -Dspring-boot.run.jvmArguments="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005"
      --   or add to application.properties:
      --   spring.jmx.enabled=true  (for JMX), use MAVEN_OPTS or GRADLE_OPTS for JVM agent
      dap.configurations.java = {
        {
          type     = "java",
          request  = "attach",
          name     = "Attach to Spring Boot (port 5005)",
          hostName = "127.0.0.1",
          port     = 5005,
        },
        {
          type     = "java",
          request  = "attach",
          name     = "Attach to Spring Boot (custom port)",
          hostName = "127.0.0.1",
          port     = function()
            return tonumber(vim.fn.input("Debug port: ", "5005"))
          end,
        },
      }

      -- ─── Sign customization ────────────────────────────────────────────────
      vim.fn.sign_define("DapBreakpoint",          { text = "●", texthl = "DiagnosticError",   linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◉", texthl = "DiagnosticWarning", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped",             { text = "▶", texthl = "DiagnosticOk",      linehl = "DapStopped", numhl = "" })
      vim.fn.sign_define("DapBreakpointRejected",  { text = "○", texthl = "DiagnosticHint",    linehl = "", numhl = "" })
    end,
  },
}
