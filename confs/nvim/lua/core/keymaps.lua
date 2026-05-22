-- show line nums briefly
vim.keymap.set('n', '<leader>ll', function()
  vim.wo.number = true
  vim.defer_fn(function()
    vim.wo.number = false
  end, 3000)
end)


-- blog post
vim.keymap.set('n', '\\wb', function()
  local folder = vim.fn.expand('~/code/blog/posts')
  local date = os.date('%Y-%m-%d')
  local seconds = os.time()
  local filename = string.format('%s/%s_%d.md', folder, date, seconds)
  vim.fn.mkdir(folder, 'p')
  vim.cmd('edit ' .. filename)
end, { desc = 'Create new timestamped file' })


-- delete current file
vim.api.nvim_create_user_command('DeleteFile', function()
  require('core.utils').delete_current_file()
end, { desc = 'Delete the file for the current buffer' })


--- save shortcut
vim.keymap.set("n", "<C-s>", "<cmd>w<CR>", { desc = "Save file" })
vim.keymap.set("i", "<C-s>", "<Esc><cmd>w<CR>a", { desc = "Save file" })


-- move current line / selection up and down with Alt+Up / Alt+Down
vim.keymap.set("n", "<A-Down>", "<cmd>m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-Up>", "<cmd>m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("i", "<A-Down>", "<Esc><cmd>m .+1<CR>==gi", { desc = "Move line down" })
vim.keymap.set("i", "<A-Up>", "<Esc><cmd>m .-2<CR>==gi", { desc = "Move line up" })
vim.keymap.set("v", "<A-Down>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-Up>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- search/replace within visually selected range
vim.keymap.set('x', '<leader>s', [[:s/\%V]])

