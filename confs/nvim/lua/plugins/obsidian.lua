local function open_vault_main()
  require("core.utils").open_vault_main()
end

local function load_clt_workspace()
  pcall(require("lazy").load, { plugins = { "obsidian.nvim" } })
  -- vim.cmd("cd ~/vaults/clt")
  vim.cmd("ObsidianWorkspace work")
end

local function load_personal_workspace()
  pcall(require("lazy").load, { plugins = { "obsidian.nvim" } })
  -- vim.cmd("cd ~/vaults/sdb")
  vim.cmd("ObsidianWorkspace personal")
end

vim.keymap.set("n", "\\ws", function()
  load_personal_workspace()
  vim.cmd("edit " .. vim.fn.expand("~/vaults/sdb/inbox.md"))
end, { desc = "Load obsidian, switch to 'personal', open main.md" })

vim.keymap.set("n", "\\ww", function()
  load_clt_workspace()
  vim.cmd("edit " .. vim.fn.expand("~/vaults/clt/inbox.md"))
end, { desc = "Load obsidian, switch to 'work', open main.md" })

vim.keymap.set("n", "\\wt", function()
  load_personal_workspace()
  require("core.utils").open_vault_todo()
end, { desc = "Open Personal todo.md" })

vim.keymap.set("n", "\\wT", function()
  load_clt_workspace()
  require("core.utils").open_vault_todo()
end, { desc = "Open CLT todo.md" })

vim.keymap.set("n", "\\wd", function()
  load_personal_workspace()
  vim.cmd("ObsidianToday")
end, { desc = "Open Personal daily" })

-- vim.keymap.set("n", "\\wD", function()
--   load_clt_workspace()
--   vim.cmd("ObsidianToday")
-- end, { desc = "Open CLT daily" })

return {
    "epwalsh/obsidian.nvim",
    version = "*",  -- recommended, use latest release instead of latest commit
    lazy = true,
    -- ft = "markdown",
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    event = {
      --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
      --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
      --   -- refer to `:h file-pattern` for more examples
         "BufReadPre ~/vaults/**/*.md",
         "BufNewFile ~/vaults/**/*.md",
       },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      mappings = {
        --["<C-Space>"] = {
        --  action = function()
        --    return require("obsidian").util.toggle_checkbox()
        --  end,
        -- opts = { buffer = true },
        --},
        --["<C-CR>"] = {
        --  action = function()
        --    return vim.cmd("ObsidianFollowLink")
        --  end,
        -- opts = { buffer = true },
        --}
      },
      ui = {
        enable = true,
        checkboxes = {
          [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
          ["x"] = { char = "󰱒", hl_group = "ObsidianDone" },
          ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
          ["!"] = { char = "󰅾", hl_group = "ObsidianImportant" },
        },
      },
      workspaces = {
        {
          name = "personal",
          path = "~/vaults/sdb",
        },
        {
          name = "work",
          path = "~/vaults/clt",
        },
      },
      daily_notes = {
        folder = 'dailies',
        date_format = '%Y-%m-%d',
        default_tags = { "daily-notes" },
        template = "daily-mo",
      },
      templates = {
        subdir = "templates"
      },
      completion = {
        nvim_cmp = true,
        min_chars = 2,
      },
      follow_url_func = function(url)
         vim.ui.open(url)
      end,
      note_id_func = function(title)
        if title ~= nil then
          return title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
        else
          return tostring(os.time())
        end
      end,
      callbacks = {
        enter_note = function(client)
          vim.keymap.set("n", "<leader>q", ":ObsidianQuickSwitch<CR>", { buffer = true, desc = "Obsidian: Quick Switch", })
          vim.keymap.set("n", "<C-Space>", ":ObsidianToggleCheckbox<CR>", { buffer = true, desc = "Obsidian: Toggle Checkbox", })
          vim.keymap.set("n", "<CR>", ":ObsidianFollowLink<CR>", { buffer = true, desc = "Obsidian: Follow Link", })
        end,
        --post_set_workspace = function(client, workspace)
        --  vim.cmd("cd " .. workspace.path)
        --end,
      },
    }
}
