return {
  'ruifm/gitlinker.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    { '<leader>Gy', function() require('gitlinker').get_buf_range_url('n') end, desc = 'Copy GitHub link' },
    { '<leader>Gy', function() require('gitlinker').get_buf_range_url('v') end, mode = 'v', desc = 'Copy GitHub link (selection)' },
    { '<leader>Go', function() require('gitlinker').get_buf_range_url('n', { action_callback = require('gitlinker.actions').open_in_browser }) end, desc = 'Open GitHub link' },
    { '<leader>Go', function() require('gitlinker').get_buf_range_url('v', { action_callback = require('gitlinker.actions').open_in_browser }) end, mode = 'v', desc = 'Open GitHub link (selection)' },
  },
  opts = {},
}
