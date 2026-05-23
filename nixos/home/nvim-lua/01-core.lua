vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.mapleader = " "
vim.g.maplocalleader = ","

vim.opt.number = false
vim.opt.relativenumber = false
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.clipboard = "unnamedplus"
vim.opt.ignorecase = true
vim.opt.linespace = 2
vim.opt.conceallevel = 2
vim.opt.autowriteall = true
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = false
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
  "context:3",
})
vim.opt.wrap = false
vim.opt.linebreak = true
vim.opt.textwidth = 0
vim.opt.sidescrolloff = 5
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
vim.opt.updatetime = 200
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/.nvim-undo//"
vim.fn.mkdir(vim.fn.stdpath("cache"), "p")

vim.cmd("set title")

vim.api.nvim_set_hl(0, "DiffAdd", { fg = "#a6e3a1", bg = "NONE" })
vim.api.nvim_set_hl(0, "DiffDelete", { fg = "#f38ba8", bg = "NONE" })
vim.api.nvim_set_hl(0, "DiffChange", { bg = "NONE" })
vim.api.nvim_set_hl(0, "DiffText", { bg = "#45475a" })

local autosave_timer = vim.uv.new_timer()
autosave_timer:start(15000, 15000, vim.schedule_wrap(function()
  if not vim.bo.modified then
    return
  end
  vim.cmd("silent! wall")
end))

local function delete_current_file()
  local bufnr = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(bufnr)

  if filepath == "" then
    vim.notify("Buffer has no file", vim.log.levels.WARN)
    return
  end

  vim.ui.select({ "Yes", "No" }, {
    prompt = "Delete " .. vim.fn.fnamemodify(filepath, ":~:.") .. "?",
  }, function(choice)
    if choice ~= "Yes" then
      return
    end

    local ok, err = os.remove(filepath)
    if not ok then
      vim.notify("Failed to delete file: " .. err, vim.log.levels.ERROR)
      return
    end

    vim.api.nvim_buf_delete(bufnr, { force = true })
    vim.notify("Deleted " .. filepath)
  end)
end

vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

vim.api.nvim_set_hl(0, "ExtraWhitespace", { bg = "red", ctermbg = "red" })
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile", "InsertLeave" }, {
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

vim.api.nvim_create_user_command("RemoveTrailingWhitespace", "%s/\\s\\+$//e", {})
vim.api.nvim_create_user_command("BlameToggle", "Gitsigns blame", {})
vim.api.nvim_create_user_command("LineNumbersToggle", function()
  vim.o.number = not vim.o.number
end, {})
vim.api.nvim_create_user_command("DeleteFile", delete_current_file, {
  desc = "Delete the file for the current buffer",
})

vim.keymap.set("n", "<leader>ll", function()
  vim.wo.number = true
  vim.defer_fn(function()
    vim.wo.number = false
  end, 3000)
end)
vim.keymap.set("n", "\\wb", function()
  local folder = vim.fn.expand("~/code/blog/posts")
  local date = os.date("%Y-%m-%d")
  local seconds = os.time()
  local filename = string.format("%s/%s_%d.md", folder, date, seconds)
  vim.fn.mkdir(folder, "p")
  vim.cmd("edit " .. filename)
end, { desc = "Create new timestamped file" })
vim.keymap.set("n", "<C-s>", "<cmd>w<CR>", { desc = "Save file" })
vim.keymap.set("i", "<C-s>", "<Esc><cmd>w<CR>a", { desc = "Save file" })
vim.keymap.set("n", "<A-Down>", "<cmd>m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-Up>", "<cmd>m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("i", "<A-Down>", "<Esc><cmd>m .+1<CR>==gi", { desc = "Move line down" })
vim.keymap.set("i", "<A-Up>", "<Esc><cmd>m .-2<CR>==gi", { desc = "Move line up" })
vim.keymap.set("v", "<A-Down>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-Up>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
vim.keymap.set("x", "<leader>s", [[:s/\%V]])
