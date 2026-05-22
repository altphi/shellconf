return {
  "lewis6991/gitsigns.nvim",
  config = function()
    require("gitsigns").setup {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local trouble = require("trouble")

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- All hunks in current buffer → location list
        map('n', '<leader>hq', function()
          gs.setqflist(0, { use_location_list = true, open = false }, function()
            trouble.close("qflist")
            trouble.open({ mode = "loclist", focus = true, win = { position = "bottom", size = 0.15 } })
          end)
        end, { desc = 'Git hunks in buffer' })

        -- All hunks across the whole repo → quickfix
        map('n', '<leader>hQ', function()
          gs.setqflist('all', { open = false }, function()
            trouble.close("loclist")
            trouble.open({ mode = "qflist", focus = true, win = { position = "bottom", size = 0.15 } })
          end)
        end, { desc = 'Git hunks in repo' })

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then return ']c' end
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, { expr = true, desc = 'Next Git hunk' })

        map('n', '[c', function()
          if vim.wo.diff then return '[c' end
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, { expr = true, desc = 'Previous Git hunk' })

        map('n', '<leader>hn', gs.next_hunk, { desc = 'Next Git hunk' })
        map('n', '<leader>hp', gs.prev_hunk, { desc = 'Previous Git hunk' })
        map('n', '<leader>hl', gs.preview_hunk, { desc = 'Preview Git hunk' })
        map('n', '<leader>hb', function() gs.blame_line{ full = true } end, { desc = 'Git blame line' })
        map('n', '<leader>hr', function()
          vim.ui.input({ prompt = 'Are you sure? (y/n): ' }, function(input)
            if input and (input:lower() == 'y' or input:lower() == 'yes') then
              gs.reset_hunk()
              print('Hunk reset')
            else
              print('Hunk reset cancelled')
            end
          end)
        end, { desc = 'Reset Git hunk with confirmation' })
      end,
    }
  end
}
