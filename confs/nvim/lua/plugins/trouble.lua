return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" }, -- optional but recommended
  cmd = "Trouble", -- lazy-load on these commands
  keys = {
    { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Trouble: Workspace Diagnostics" },
    { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Trouble: Buffer Diagnostics" },
    { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Trouble: Symbols (LSP)" },
    { "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "Trouble: LSP Definitions / References" },
    { "<leader>qq", "<cmd>Trouble qflist toggle<cr>", desc = "Trouble: Quickfix List" },
    { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Trouble: Location List" },
  },
  opts = {
    -- you honestly don't need to set anything — defaults are excellent now
    position = "bottom",     -- bottom | top | left | right
    height = 10,
    width = 50,
    mode = "workspace_diagnostics", -- or "document_diagnostics"
    auto_open = false,
    auto_close = true,       -- auto close when no problems
    signs = {
      error = "",
      warning = "",
      hint = "",
      information = "",
      other = "",
    },
    use_diagnostic_signs = true, -- use the same signs as your usual diagnostics
  },
}
