return {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "williamboman/mason.nvim",
      "jay-babu/mason-nvim-dap.nvim",
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      require("nvim-dap-virtual-text").setup()

      require("mason").setup()
      require("mason-nvim-dap").setup({
        ensure_installed = { "js", "php", "r", "codelldb" },
        automatic_installation = false,
      })

      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup()

      -- Auto-open/close UI
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      -- Keymaps
      vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Continue" })
      vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
      vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
      vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })
      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Debug: Open REPL" })

      dap.configurations.javascript = {
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          cwd = vim.fn.getcwd(),
          sourceMaps = true,
          runtimeExecutable = "node",
          console = "integratedTerminal",
          internalConsoleOptions = "neverOpen"
        },
      }

      -- dap.adapters.php = {
      --   type = "executable",
      --   command = "node",
      --   args = { vim.fn.stdpath("data") .. "/mason/packages/php-debug-adapter/extension/out/phpDebug.js" },
      -- }

      dap.configurations.php = {
        {
          type = "php",
          request = "launch",
          name = "Listen for Xdebug",
          port = 9003,
          pathMappings = { ["/opt/abhe"] = "~/code/abhe", },
        }
      }

      dap.adapters.r = {
        type = "executable",
        command = "R",
        args = { "--no-save", "-e", "library(debugR);debugR::run()" },
      }

      dap.configurations.r = {
        {
          type = "r",
          request = "launch",
          name = "Debug R Script",
          program = "${file}",
          cwd = vim.fn.getcwd(),
          console = "integratedTerminal",
        },
      }
    end,
}
