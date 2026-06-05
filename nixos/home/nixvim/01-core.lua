vim.opt.diffopt:append({
  "iwhite",
  "algorithm:histogram",
  "indent-heuristic",
  "context:3",
})
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.undodir = vim.fn.stdpath("data") .. "/.nvim-undo//"
vim.fn.mkdir(vim.fn.stdpath("cache"), "p")

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

local function toggle_line_numbers()
  local enabled = not vim.wo.number
  vim.wo.number = enabled
  vim.wo.relativenumber = enabled
end

local function toggle_cursor_line()
  vim.wo.cursorline = not vim.wo.cursorline
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

vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave" }, {
  pattern = "*",
  callback = function()
    toggle_cursor_line()
  end,
})

vim.api.nvim_create_user_command("DeleteFile", delete_current_file, {
  desc = "Delete the file for the current buffer",
})
vim.keymap.set("n", "<leader>ll", toggle_line_numbers, { desc = "Toggle line numbers" })
vim.keymap.set("n", "\\wb", function()
  local folder = vim.fn.expand("~/code/blog/posts")
  local date = os.date("%Y-%m-%d")
  local seconds = os.time()
  local filename = string.format("%s/%s_%d.md", folder, date, seconds)
  vim.fn.mkdir(folder, "p")
  vim.cmd("edit " .. filename)
end, { desc = "Create new timestamped file" })
vim.keymap.set("n", "<leader>cl", toggle_cursor_line, { desc = "Toggle cursor line" })

vim.o.laststatus = 0;
vim.keymap.set("n", "<leader>e", function()
  vim.o.laststatus = vim.o.laststatus == 0 and 2 or 0;
end, { desc = "Toggle status line" })
