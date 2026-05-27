require("nvim-treesitter").setup({
  install_dir = vim.fn.stdpath("data") .. "/site",
})

vim.api.nvim_create_autocmd("FileType", {
  callback = function(ev)
    local ok = pcall(vim.treesitter.start, ev.buf)
    if ok then
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

require("nvim-treesitter-textobjects").setup({
  move = { set_jumps = true },
})

local ts_move = require("nvim-treesitter-textobjects.move")
local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")

local function map_move(lhs, rhs, desc)
  vim.keymap.set({ "n", "x", "o" }, lhs, rhs, { desc = desc })
end

map_move("]m", function()
  ts_move.goto_next_start("@function.outer", "textobjects")
end, "Next function start")
map_move("]]", function()
  ts_move.goto_next_start("@class.outer", "textobjects")
end, "Next class start")
map_move("]o", function()
  ts_move.goto_next_start("@loop.outer", "textobjects")
end, "Next loop start")
map_move("]s", function()
  ts_move.goto_next_start("@local.scope", "locals")
end, "Next scope")
map_move("]z", function()
  ts_move.goto_next_start("@fold", "folds")
end, "Next fold")

map_move("]M", function()
  ts_move.goto_next_end("@function.outer", "textobjects")
end, "Next function end")
map_move("][", function()
  ts_move.goto_next_end("@class.outer", "textobjects")
end, "Next class end")

map_move("[m", function()
  ts_move.goto_previous_start("@function.outer", "textobjects")
end, "Previous function start")
map_move("[[", function()
  ts_move.goto_previous_start("@class.outer", "textobjects")
end, "Previous class start")

map_move("[M", function()
  ts_move.goto_previous_end("@function.outer", "textobjects")
end, "Previous function end")
map_move("[]", function()
  ts_move.goto_previous_end("@class.outer", "textobjects")
end, "Previous class end")

vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)

require("treesitter-context").setup({
  enable = true,
  max_lines = 3,
  separator = "─",
})
vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "#2e2e3e" })
vim.api.nvim_set_hl(0, "TreesitterContextSeparator", { fg = "#555577" })
