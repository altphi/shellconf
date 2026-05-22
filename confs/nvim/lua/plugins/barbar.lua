return {'romgrk/barbar.nvim',
  dependencies = {
    'lewis6991/gitsigns.nvim', -- OPTIONAL: for git status
    'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
  },
  init = function()
    vim.g.barbar_auto_setup = false

    vim.api.nvim_set_hl(0, "BufferCurrent", { ctermfg = 15, ctermbg = 0 })
    vim.api.nvim_set_hl(0, "BufferCurrentMod", { ctermfg = 15, ctermbg = 0 })
    vim.api.nvim_set_hl(0, "BufferCurrentIcon", { ctermfg = 11 })

    vim.api.nvim_set_hl(0, "BufferInactive", { ctermfg = 7 })
    vim.api.nvim_set_hl(0, "BufferInactiveMod", { ctermfg = 8, ctermbg = 0 })
    vim.api.nvim_set_hl(0, "BufferInactiveIcon", { ctermfg = 8 })

    --vim.api.nvim_set_hl(0, "BufferTabpageFill", { ctermbg = 0 })
    --vim.api.nvim_set_hl(0, "BufferTabpages", { ctermfg = 7, ctermbg = 0 })
  end,
  event = 'VimEnter',
  keys = {
    { '<C-p>', '<Cmd>BufferPrevious<CR>', desc = 'Buffer: Previous' },
    { '<C-n>', '<Cmd>BufferNext<CR>', desc = 'Buffer: Next' },
    { '<A-1>', '<Cmd>BufferGoto 1<CR>', desc = 'Buffer: Go to 1' },
    { '<A-2>', '<Cmd>BufferGoto 2<CR>', desc = 'Buffer: Go to 2' },
    { '<A-3>', '<Cmd>BufferGoto 3<CR>', desc = 'Buffer: Go to 3' },
    { '<A-4>', '<Cmd>BufferGoto 4<CR>', desc = 'Buffer: Go to 4' },
    { '<A-5>', '<Cmd>BufferGoto 5<CR>', desc = 'Buffer: Go to 5' },
    { '<A-6>', '<Cmd>BufferGoto 6<CR>', desc = 'Buffer: Go to 6' },
    { '<A-7>', '<Cmd>BufferGoto 7<CR>', desc = 'Buffer: Go to 7' },
    { '<A-8>', '<Cmd>BufferGoto 8<CR>', desc = 'Buffer: Go to 8' },
    { '<A-9>', '<Cmd>BufferGoto 9<CR>', desc = 'Buffer: Go to 9' },
    { '<A-0>', '<Cmd>BufferLast<CR>', desc = 'Buffer: Last' },
    { '<A-p>', '<Cmd>BufferPin<CR>', desc = 'Buffer: Pin' },
    { '<A-w>', '<Cmd>BufferClose<CR>', desc = 'Buffer: Close' },
    { '<C-s-p>', '<Cmd>BufferPickDelete<CR>', desc = 'Buffer: Pick Delete' },
    { '<Space>bb', '<Cmd>BufferOrderByBufferNumber<CR>', desc = 'Buffer: Order by number' },
    { '<Space>bn', '<Cmd>BufferOrderByName<CR>', desc = 'Buffer: Order by name' },
    { '<Space>bd', '<Cmd>BufferOrderByDirectory<CR>', desc = 'Buffer: Order by directory' },
    { '<Space>bl', '<Cmd>BufferOrderByLanguage<CR>', desc = 'Buffer: Order by language' },
    { '<Space>bw', '<Cmd>BufferOrderByWindowNumber<CR>', desc = 'Buffer: Order by window' },
  },
  opts = {
    animation = false,
    preset = 'default',
    icons = { filetype = { enabled = false } },
  }
}
