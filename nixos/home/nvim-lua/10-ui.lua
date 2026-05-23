require("mini.surround").setup({
  custom_surroundings = nil,
  highlight_duration = 500,
  mappings = {
    add = "sa",
    delete = "sd",
    find = "sf",
    find_left = "sF",
    highlight = "sh",
    replace = "sr",
    suffix_last = "l",
    suffix_next = "n",
  },
  n_lines = 20,
  respect_selection_type = false,
  search_method = "cover",
  silent = false,
})

vim.g.barbar_auto_setup = false
vim.api.nvim_set_hl(0, "BufferCurrent", { ctermfg = 15, ctermbg = 0 })
vim.api.nvim_set_hl(0, "BufferCurrentMod", { ctermfg = 15, ctermbg = 0 })
vim.api.nvim_set_hl(0, "BufferCurrentIcon", { ctermfg = 11 })
vim.api.nvim_set_hl(0, "BufferInactive", { ctermfg = 7 })
vim.api.nvim_set_hl(0, "BufferInactiveMod", { ctermfg = 8, ctermbg = 0 })
vim.api.nvim_set_hl(0, "BufferInactiveIcon", { ctermfg = 8 })
require("barbar").setup({
  animation = false,
  preset = "default",
  icons = { filetype = { enabled = false } },
})
vim.keymap.set("n", "<C-p>", "<Cmd>BufferPrevious<CR>", { desc = "Buffer: Previous" })
vim.keymap.set("n", "<C-n>", "<Cmd>BufferNext<CR>", { desc = "Buffer: Next" })
vim.keymap.set("n", "<A-1>", "<Cmd>BufferGoto 1<CR>", { desc = "Buffer: Go to 1" })
vim.keymap.set("n", "<A-2>", "<Cmd>BufferGoto 2<CR>", { desc = "Buffer: Go to 2" })
vim.keymap.set("n", "<A-3>", "<Cmd>BufferGoto 3<CR>", { desc = "Buffer: Go to 3" })
vim.keymap.set("n", "<A-4>", "<Cmd>BufferGoto 4<CR>", { desc = "Buffer: Go to 4" })
vim.keymap.set("n", "<A-5>", "<Cmd>BufferGoto 5<CR>", { desc = "Buffer: Go to 5" })
vim.keymap.set("n", "<A-6>", "<Cmd>BufferGoto 6<CR>", { desc = "Buffer: Go to 6" })
vim.keymap.set("n", "<A-7>", "<Cmd>BufferGoto 7<CR>", { desc = "Buffer: Go to 7" })
vim.keymap.set("n", "<A-8>", "<Cmd>BufferGoto 8<CR>", { desc = "Buffer: Go to 8" })
vim.keymap.set("n", "<A-9>", "<Cmd>BufferGoto 9<CR>", { desc = "Buffer: Go to 9" })
vim.keymap.set("n", "<A-0>", "<Cmd>BufferLast<CR>", { desc = "Buffer: Last" })
vim.keymap.set("n", "<A-p>", "<Cmd>BufferPin<CR>", { desc = "Buffer: Pin" })
vim.keymap.set("n", "<A-w>", "<Cmd>BufferClose<CR>", { desc = "Buffer: Close" })
vim.keymap.set("n", "<C-s-p>", "<Cmd>BufferPickDelete<CR>", { desc = "Buffer: Pick Delete" })
vim.keymap.set("n", "<Space>bb", "<Cmd>BufferOrderByBufferNumber<CR>", { desc = "Buffer: Order by number" })
vim.keymap.set("n", "<Space>bn", "<Cmd>BufferOrderByName<CR>", { desc = "Buffer: Order by name" })
vim.keymap.set("n", "<Space>bd", "<Cmd>BufferOrderByDirectory<CR>", { desc = "Buffer: Order by directory" })
vim.keymap.set("n", "<Space>bl", "<Cmd>BufferOrderByLanguage<CR>", { desc = "Buffer: Order by language" })
vim.keymap.set("n", "<Space>bw", "<Cmd>BufferOrderByWindowNumber<CR>", { desc = "Buffer: Order by window" })
