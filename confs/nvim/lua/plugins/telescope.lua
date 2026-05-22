local function telescope_grep_in_directory()
    local current_file_dir = vim.fn.expand('%:p:h')
    --if vim.fn.filereadable(vim.fn.expand('%:p')) == 1 then
    --    require('telescope.builtin').live_grep({
    --        cwd = current_file_dir,
    --        prompt_title = 'Grep in ' .. current_file_dir
    --    })
    --else
        require('telescope.builtin').find_files({
            prompt_title = 'Select a directory to grep',
            find_command = { 'fd', '--type', 'd', '--hidden', '--exclude', '.git' },
            attach_mappings = function(_, map)
                map('i', '<CR>', function(prompt_bufnr)
                    local selection = require('telescope.actions.state').get_selected_entry()
                    require('telescope.actions').close(prompt_bufnr)
                    require('telescope.builtin').live_grep({
                        cwd = selection.path,
                        prompt_title = 'Grep in ' .. selection.path
                    })
                end)
                return true
            end
        })
    -- end
end

return {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",  -- Pin to a stable version; check GitHub for latest
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
      "nvim-telescope/telescope-file-browser.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          history = {
            path = '~/.local/share/nvim/telescope_history',
            limit = 1000,
          },
          -- Basic config; customize as needed
          mappings = {
            i = {
              ["<C-u>"] = false,
              ["<C-d>"] = false,
              ["<C-n>"] = require('telescope.actions').cycle_history_next,
              ["<C-p>"] = require('telescope.actions').cycle_history_prev,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,  -- Shows hidden files/dirs, but still respects .gitignore and skips .git/
          },
          live_grep = {
            additional_args = function() return {"--hidden", "--glob", "!**.git/*" } end,  -- For grepping hidden files
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "ignore_case",
            hidden = true,
          },
          file_browser = {
            hidden = true,
          },
        },
      })
      telescope.load_extension("fzf")
      telescope.load_extension("file_browser")
      vim.keymap.set("n", "<leader>ee", ":Telescope file_browser<CR>", { desc = "File browser with preview" })
      vim.keymap.set("n", "<leader>ef", ":Telescope file_browser path=%:p:h select_buffer=true<CR>", { desc = "File browser focusing current file" })

      vim.api.nvim_create_user_command("E", "Telescope file_browser path=%:p:h select_buffer=true", {})
      vim.api.nvim_create_user_command("Explore", "Telescope file_browser path=%:p:h select_buffer=true", {})

      local builtin = require("telescope.builtin")
      local find_files = function()
        builtin.find_files({
          hidden = true,
          find_command = { 'fd', '--hidden', '--exclude', '.git' },
        })
      end

      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function(data)
          if vim.fn.argc() == 0 then
            find_files()
            return
          end

          if vim.fn.isdirectory(data.file) == 1 then
            vim.cmd.cd(data.file)
            require("telescope").extensions.file_browser.file_browser()
          end
        end,
      })


      vim.keymap.set("n", "<leader>c", builtin.git_status, { desc = "Telescope: Changed files" })
      --vim.keymap.set("n", "<leader>j", builtin.loclist, { desc = "Telescope: Jump list" })
      --vim.keymap.set("n", "<leader>f", builtin.find_files, { desc = "Telescope: Find files" })
      vim.keymap.set("n", "<leader>f", find_files, { desc = "Telescope: Find files (including hidden)" })
      vim.keymap.set("n", "<leader>g", builtin.live_grep, { desc = "Telescope: Live grep" })
      vim.keymap.set("n", "<leader>b", builtin.buffers, { desc = "Telescope: Buffers" })
      -- vim.keymap.set("n", "<leader>ph", builtin.help_tags, { desc = "Telescope: Help tags" })
      vim.keymap.set('n', '<leader>s', builtin.treesitter, { desc = 'Search Tree-sitter symbols' })
      vim.keymap.set('n', '<leader>h', builtin.resume, { desc = "Telescope prompt history" })
      vim.keymap.set("n", "<leader>?", ':Telescope keymaps<CR>', { silent = true })
      vim.keymap.set("n", "<leader>of", ':Telescope oldfiles only_cwd=true<CR>', { silent = true })
      vim.keymap.set('n', '<leader>dg', telescope_grep_in_directory, { desc = 'Telescope live_grep in current or selected directory' })
      vim.keymap.set("n", "<leader>dd", "<cmd>Telescope diagnostics<cr>")
      vim.keymap.set("n", "<leader>rr", function()
        builtin.lsp_references({ include_declaration = false, include_current_line = false })
      end, { desc = "Telescope: lsp_references (usages only)"})
      vim.keymap.set("n", "<leader>ic", builtin.lsp_incoming_calls, { desc = "Telescope: lsp_incoming_calls"})
      vim.keymap.set("n", "<leader>oc", builtin.lsp_outgoing_calls, { desc = "Telescope: lsp_outgoing_calls"})
    end,
}
