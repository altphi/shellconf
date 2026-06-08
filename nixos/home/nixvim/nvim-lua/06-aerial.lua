vim.treesitter.query.set("zsh", "aerial", [[
(function_definition
  name: (word) @name
  (#set! "kind" "Function")) @symbol
]])

require("aerial").setup({
  backends = { "treesitter", "markdown" },
})
vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle<CR>", { desc = "Toggle Aerial outline" })
