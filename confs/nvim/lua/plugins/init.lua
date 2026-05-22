local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  { import = 'plugins.dap' },
  { import = 'plugins.telescope' },
  { import = 'plugins.treesitter' },
  { import = 'plugins.aerial' },
  { import = 'plugins.obsidian' },
  { import = 'plugins.bullets' },
  { import = 'plugins.lsp' },
  { import = 'plugins.cmp' },
  { import = 'plugins.octo' },
  { import = 'plugins.lazygit' },
  { import = 'plugins.gitsigns' },
  { import = 'plugins.trouble' },
  { import = 'plugins.barbar' },
  { import = 'plugins.rustaceanvim' },
  { import = 'plugins.grug-far' },
  { import = 'plugins.mini-surround' },
  { import = 'plugins.conjure' },
  { import = 'plugins.treesitter-context' },
  { import = 'plugins.tmux-navigator' },
  { import = 'plugins.gitlinker' },
  -- { import = 'plugins.markview' },
}, {
  checker = { enabled = false },
})
