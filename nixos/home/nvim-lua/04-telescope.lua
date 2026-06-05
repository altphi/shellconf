--local function telescope_grep_in_directory()
--  --require("telescope.builtin").find_files({
--  --  prompt_title = "Select a directory to grep",
--  --  find_command = { "fd", "--type", "d", "--hidden", "--exclude", ".git" },
--  --  attach_mappings = function(_, map)
--  --    map("i", "<CR>", function(prompt_bufnr)
--  --      local selection = require("telescope.actions.state").get_selected_entry()
--  --      require("telescope.actions").close(prompt_bufnr)
--  --      require("telescope.builtin").live_grep({
--  --        cwd = selection.path,
--  --        prompt_title = "Grep in " .. selection.path,
--  --      })
--  --    end)
--  --    return true
--  --  end,
--  --})
--end

local telescope = require("telescope")
telescope.setup({
  defaults = {
    history = {
      path = "~/.local/share/nvim/telescope_history",
      limit = 1000,
    },
    mappings = {
      i = {
        ["<C-u>"] = false,
        ["<C-d>"] = false,
        ["<C-n>"] = require("telescope.actions").cycle_history_next,
        ["<C-p>"] = require("telescope.actions").cycle_history_prev,
      },
    },
  },
  pickers = {
    find_files = { hidden = true },
    live_grep = {
      additional_args = function()
        return { "--hidden", "--glob", "!**.git/*" }
      end,
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
    file_browser = { hidden = true },
    frecency = {
      db_safe_mode = false,
    },
  },
})
telescope.load_extension("fzf")
telescope.load_extension("file_browser")

vim.keymap.set("n", "<leader>ee", ":Telescope file_browser<CR>", { desc = "File browser with preview" })
vim.keymap.set("n", "<leader>ef", ":Telescope file_browser path=%:p:h select_buffer=true<CR>",
  { desc = "File browser focusing current file" })
vim.api.nvim_create_user_command("E", "Telescope file_browser path=%:p:h select_buffer=true", {})
vim.api.nvim_create_user_command("Explore", "Telescope file_browser path=%:p:h select_buffer=true", {})

local builtin = require("telescope.builtin")
-- local find_files = function()
--   builtin.find_files({
--     hidden = true,
--     find_command = { "fd", "--hidden", "--exclude", ".git" },
--   })
-- end
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function(data)
    if vim.fn.isdirectory(data.file) == 1 then
      vim.cmd.cd(data.file)
      require("telescope").extensions.file_browser.file_browser()
    end
  end,
})
vim.keymap.set("n", "<leader>c", builtin.git_status, { desc = "Telescope: Changed files" })
vim.keymap.set("n", "<leader>g", builtin.live_grep, { desc = "Telescope: Live grep" })
vim.keymap.set("n", "<leader>b", builtin.buffers, { desc = "Telescope: Buffers" })
vim.keymap.set("n", "<leader>m", builtin.marks, { desc = "Telescope: Marks" })
vim.keymap.set("n", "<leader>j", builtin.jumplist, { desc = "Telescope: Jumps" })
vim.keymap.set("n", "<leader>s", builtin.treesitter, { desc = "Search Tree-sitter symbols" })
vim.keymap.set("n", "<leader>?", ":Telescope keymaps<CR>", { silent = true })
vim.keymap.set("n", "<leader>of", ":Telescope oldfiles only_cwd=true<CR>", { silent = true })
--vim.keymap.set("n", "<leader>dg", telescope_grep_in_directory, { desc = "Telescope live_grep in selected directory" })
vim.keymap.set("n", "<leader>dd", "<cmd>Telescope diagnostics<CR>", { desc = "Telescope: diagnostics" })
vim.keymap.set("n", "<leader>rr", function()
  builtin.lsp_references({ include_declaration = false, include_current_line = false })
end, { desc = "Telescope: lsp_references (usages only)" })
vim.keymap.set("n", "<leader>ic", builtin.lsp_incoming_calls, { desc = "Telescope: lsp_incoming_calls" })
vim.keymap.set("n", "<leader>oc", builtin.lsp_outgoing_calls, { desc = "Telescope: lsp_outgoing_calls" })
--vim.keymap.set("n", "<leader>f", find_files, { desc = "Telescope: Find files (including hidden)" })
vim.keymap.set("n", "<leader>f", function()
  require("telescope").extensions.frecency.frecency({ workspace = "CWD", })
end, { desc = "Telescope: Frecent files" })
