vim.g.bullets_enabled_file_types = { "markdown" }
vim.g.bullets_enable = 1
vim.g.bullets_checkbox_markers = " ~x"
vim.g.bullets_outline_levels = { "std-", "std*", "std+", "num", "rom", "abc", "ROM" }
vim.g.bullets_set_mappings = 0
vim.g.bullets_custom_mappings = {
  { "imap", "<CR>", "<Plug>(bullets-newline)" },
  { "inoremap", "<C-CR>", "<CR>" },
  { "nmap", "o", "<Plug>(bullets-newline)" },
}
local function open_vault_file(name)
  local workspace = _G.Obsidian and _G.Obsidian.workspace
  local base_path = workspace and tostring(workspace.path) or "~/vaults/sdb"
  local path = vim.fn.resolve(vim.fn.expand(base_path .. "/" .. name))

  if vim.fn.filereadable(path) == 1 then
    vim.cmd("edit " .. vim.fn.fnameescape(path))
  else
    vim.notify(name .. " not found in path: " .. path, vim.log.levels.WARN)
  end
end

require("obsidian").setup({
  legacy_commands = false,
  ui = {
    enable = true,
  },
  checkbox = {
    order = { " ", "~", "x" },
  },
  workspaces = {
    { name = "personal", path = "~/vaults/sdb" },
    { name = "work", path = "~/vaults/clt" },
  },
  daily_notes = {
    folder = "dailies",
    date_format = "%Y-%m-%d",
    default_tags = { "daily-notes" },
    template = "daily-mo",
  },
  templates = { folder = "templates" },
  completion = {
    nvim_cmp = true,
    min_chars = 2,
  },
  note_id_func = function(title)
    if title ~= nil then
      return title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
    else
      return tostring(os.time())
    end
  end,
  callbacks = {
    enter_note = function()
      vim.keymap.set("n", "<leader>q", ":Obsidian quick_switch<CR>", {
        buf = 0,
        desc = "Obsidian: Quick Switch",
      })
      vim.keymap.set("n", "<C-Space>", ":Obsidian toggle_checkbox<CR>", {
        buf = 0,
        desc = "Obsidian: Toggle Checkbox",
      })
      vim.keymap.set("n", "<CR>", ":Obsidian follow_link<CR>", {
        buf = 0,
        desc = "Obsidian: Follow Link",
      })
    end,
  },
})
local function load_clt_workspace()
  vim.cmd("Obsidian workspace work")
end
local function load_personal_workspace()
  vim.cmd("Obsidian workspace personal")
end
vim.keymap.set("n", "\\ws", function()
  load_personal_workspace()
  vim.cmd("edit " .. vim.fn.expand("~/vaults/sdb/inbox.md"))
end, { desc = "Load obsidian personal inbox" })
vim.keymap.set("n", "\\ww", function()
  load_clt_workspace()
  vim.cmd("edit " .. vim.fn.expand("~/vaults/clt/inbox.md"))
end, { desc = "Load obsidian work inbox" })
vim.keymap.set("n", "\\wt", function()
  load_personal_workspace()
  open_vault_file("todo.md")
end, { desc = "Open Personal todo.md" })
vim.keymap.set("n", "\\wT", function()
  load_clt_workspace()
  open_vault_file("todo.md")
end, { desc = "Open CLT todo.md" })
vim.keymap.set("n", "\\wd", function()
  load_personal_workspace()
  vim.cmd("Obsidian today")
end, { desc = "Open Personal daily" })
