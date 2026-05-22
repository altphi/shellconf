return {
  "nvim-treesitter/nvim-treesitter-context",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("treesitter-context").setup({
      enable = true,
      max_lines = 3,
      separator = "─",
    })
    vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "#2e2e3e" })
    vim.api.nvim_set_hl(0, "TreesitterContextSeparator", { fg = "#555577" })
  end,
}
