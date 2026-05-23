require("nvim-treesitter.configs").setup({
  indent = { enable = true },
  highlight = { enable = true },
  incremental_selection = { enable = true },
  textobjects = {
    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = {
        ["]m"] = { query = "@function.outer", desc = "Next function start" },
        ["]]"] = { query = "@class.outer", desc = "Next class start" },
        ["]o"] = { query = "@loop.outer", desc = "Next loop start" },
        ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
        ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
      },
      goto_next_end = {
        ["]M"] = "@function.outer",
        ["]["] = "@class.outer",
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
        ["[["] = "@class.outer",
      },
      goto_previous_end = {
        ["[M"] = "@function.outer",
        ["[]"] = "@class.outer",
      },
    },
  },
})
local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")
vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)

require("treesitter-context").setup({
  enable = true,
  max_lines = 3,
  separator = "─",
})
vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "#2e2e3e" })
vim.api.nvim_set_hl(0, "TreesitterContextSeparator", { fg = "#555577" })
