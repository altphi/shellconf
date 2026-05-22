vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.number = false
vim.opt.relativenumber = false
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.clipboard = "unnamedplus"
vim.opt.ignorecase = true
vim.opt.linespace = 2
vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.opt.conceallevel = 2
vim.o.autowriteall = true
-- vim.lsp.set_log_level("debug")
-- vim.api.nvim_set_hl(0, 'Visual', { reverse = true })
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = false
-- guicursor shapes: block, ver25 (vertical bar), hor20 (underscore)
-- add blinkwait/blinkon/blinkoff for blinking, omit for solid
vim.opt.scrolloff = 5
vim.opt.guicursor = {
  "n-v-c:block",
  "i-ci:block-blinkwait700-blinkon400-blinkoff250",
  "r-cr:block-blinkwait700-blinkon400-blinkoff250",
}

vim.opt.diffopt:append({
  "iwhite",
  "algorithm:histogram",
  "indent-heuristic",
  "context:3"
})
vim.api.nvim_set_hl(0, "DiffAdd", {
  fg = "#a6e3a1",
  bg = "NONE",
})
vim.api.nvim_set_hl(0, "DiffDelete", {
  fg = "#f38ba8",
  bg = "NONE",
})
vim.api.nvim_set_hl(0, "DiffChange", {
  bg = "NONE",
})
vim.api.nvim_set_hl(0, "DiffText", {
  bg = "#45475a",
})

vim.opt.wrap = false
vim.opt.linebreak = true
vim.opt.textwidth = 0
-- vim.opt.colorcolumn = "+1"
vim.opt.sidescrolloff = 5

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99


-- fast updatetime for LSP diagnostics
vim.opt.updatetime = 200

-- autosave on a separate timer
local autosave_timer = vim.uv.new_timer()
autosave_timer:start(15000, 15000, vim.schedule_wrap(function()
  if not vim.bo.modified then return end
  vim.cmd("silent! wall")
end))
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/.nvim-undo//"

vim.lsp.enable('nixd')

--vim.api.nvim_set_hl(0, "TabLine", {})  -- Clears attributes for non-selected tabs
--vim.api.nvim_set_hl(0, "TabLineSel", { reverse = true, bold = true })

-- return to cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Highlight trailing whitespace (hidden in insert mode)
vim.api.nvim_set_hl(0, 'ExtraWhitespace', { bg = 'red', ctermbg = 'red' })
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile", "InsertLeave"}, {
    pattern = "*",
    callback = function()
        vim.cmd([[match ExtraWhitespace /\s\+$/]])
    end,
})
vim.api.nvim_create_autocmd("InsertEnter", {
    pattern = "*",
    callback = function()
        vim.cmd([[match none]])
    end,
})

-- remove trailing whitespace on save (save/restore cursor position)
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    local mode = vim.api.nvim_get_mode().mode
    if mode ~= "i" and vim.bo.filetype ~= "markdown" then
      local pos = vim.api.nvim_win_get_cursor(0)
      vim.cmd("%s/\\s\\+$//e")
      pcall(vim.api.nvim_win_set_cursor, 0, pos)
    end
  end,
})

vim.api.nvim_create_user_command('RemoveTrailingWhitespace', '%s/\\s\\+$//e', {})
vim.api.nvim_create_user_command('BlameToggle', 'Gitsigns blame', {})
vim.api.nvim_create_user_command('LineNumbersToggle', function()
  vim.o.number = not vim.o.number
end, {})

