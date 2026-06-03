vim.treesitter.query.set("zsh", "aerial", [[
(function_definition
  name: (word) @name
  (#set! "kind" "Function")) @symbol
]])

require("aerial").setup({
  backends = { "treesitter", "markdown" },
  filter_kind = {
    "Class",
    "Enum",
    "Interface",
    "Struct",
    "Module",
    "Method",
    "Function",
  },
  post_parse_symbol = function(bufnr, item)
    local ft = vim.bo[bufnr].filetype
    if ft == "markdown" then
      return true
    end
    return not item.parent or item.kind == "Function" or item.kind == "Method"
  end,
})
vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle<CR>", { desc = "Toggle Aerial outline" })
