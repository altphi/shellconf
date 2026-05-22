local M = {}

function M.open_vault_file(name)
  local obsidian = require("obsidian")
  local client = obsidian.get_client()
  local workspace = client.current_workspace
  local base_path = tostring(workspace.path or "~/vaults/sdb")
  local path = vim.fn.resolve(vim.fn.expand(base_path .. "/" .. name))

  if vim.fn.filereadable(path) == 1 then
    vim.cmd("edit " .. vim.fn.fnameescape(path))
  else
    vim.notify(name .. " not found in path: " .. path, vim.log.levels.WARN)
  end
end

function M.delete_current_file()
  local bufnr = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(bufnr)

  if filepath == "" then
    vim.notify("Buffer has no file", vim.log.levels.WARN)
    return
  end

  vim.ui.select({ "Yes", "No" }, {
    prompt = "Delete " .. vim.fn.fnamemodify(filepath, ":~:.") .. "?",
  }, function(choice)
    if choice ~= "Yes" then
      return
    end

    local ok, err = os.remove(filepath)
    if not ok then
      vim.notify("Failed to delete file: " .. err, vim.log.levels.ERROR)
      return
    end

    vim.api.nvim_buf_delete(bufnr, { force = true })
    vim.notify("Deleted " .. filepath)
  end)
end

return M
