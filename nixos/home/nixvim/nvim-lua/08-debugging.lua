require("nvim-dap-virtual-text").setup()
local dap = require("dap")
local dapui = require("dapui")
dapui.setup()
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end
vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Continue" })
vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Debug: Open REPL" })

dap.adapters["pwa-node"] = {
  type = "server",
  host = "127.0.0.1",
  port = "${port}",
  executable = {
    command = vim.g.nixvim_js_debug_adapter,
    args = { "${port}" },
  },
}

dap.adapters.php = {
  type = "executable",
  command = "node",
  args = { vim.g.nixvim_php_debug_adapter },
}

local js_configurations = {
  {
    type = "pwa-node",
    request = "launch",
    name = "Launch file",
    program = "${file}",
    cwd = vim.fn.getcwd(),
    sourceMaps = true,
    runtimeExecutable = "node",
    console = "integratedTerminal",
    internalConsoleOptions = "neverOpen",
  },
}
dap.configurations.javascript = js_configurations
dap.configurations.javascriptreact = js_configurations
dap.configurations.typescript = js_configurations
dap.configurations.typescriptreact = js_configurations

dap.configurations.php = {
  {
    type = "php",
    request = "launch",
    name = "Listen for Xdebug",
    port = 9003,
    pathMappings = { ["/opt/abhe"] = "~/code/abhe" },
  },
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
