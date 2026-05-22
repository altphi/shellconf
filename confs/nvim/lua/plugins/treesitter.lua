return {
    "nvim-treesitter/nvim-treesitter",
    dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "bash", "lua", "vim", "javascript", "typescript", "php", "markdown", "markdown_inline", "r", "rust", "latex", "scheme" },
        indent = {
          enabled = true,
        },
        highlight = { enable = true },
        incremental_selection = { enable = true },
        textobjects = {
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              [']m'] = { query = '@function.outer', desc = 'Next function start' },
              [']]'] = { query = '@class.outer', desc = 'Next class start' },
              [']o'] = { query = '@loop.outer', desc = 'Next loop start' },
              [']s'] = { query = '@scope', query_group = 'locals', desc = 'Next scope' },
              [']z'] = { query = '@fold', query_group = 'folds', desc = 'Next fold' },
            },
            goto_next_end = {
              [']M'] = '@function.outer',
              [']['] = '@class.outer',
            },
            goto_previous_start = {
              ['[m'] = '@function.outer',
              ['[['] = '@class.outer',
            },
            goto_previous_end = {
              ['[M'] = '@function.outer',
              ['[]'] = '@class.outer',
            },
          },
        },
      })

      local ts_repeat_move = require 'nvim-treesitter.textobjects.repeatable_move'
      vim.keymap.set({ 'n', 'x', 'o' }, ';', ts_repeat_move.repeat_last_move_next)
      vim.keymap.set({ 'n', 'x', 'o' }, ',', ts_repeat_move.repeat_last_move_previous)

    end,
  }
