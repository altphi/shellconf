local function has_lsp_format_client(bufnr, method)
  return #vim.lsp.get_clients({ bufnr = bufnr, method = method }) > 0
end

local function line_end_col(bufnr, lnum)
  local line = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, true)[1] or ""
  return #line - 1
end

local function lsp_format_line_range(bufnr, start_line, end_line)
  vim.lsp.buf.format({
    bufnr = bufnr,
    range = {
      start = { start_line, 0 },
      ["end"] = { end_line, line_end_col(bufnr, end_line) },
    },
  })
end

local function lsp_format_line_ranges(bufnr, ranges)
  if #ranges == 0 then
    return false
  end

  if not has_lsp_format_client(bufnr, "textDocument/rangeFormatting") then
    vim.notify_once(
      ("[LSP] No range formatter for %s; skipping changed-hunk format"):format(vim.bo[bufnr].filetype),
      vim.log.levels.WARN
    )
    return false
  end

  local line_count = vim.api.nvim_buf_line_count(bufnr)
  for i = #ranges, 1, -1 do
    local range = ranges[i]
    local start_line = math.max(range.start, 1)
    local end_line = math.min(range["end"], line_count)
    if start_line <= end_line then
      lsp_format_line_range(bufnr, start_line, end_line)
    end
  end

  return true
end

local function lsp_format_visual_selection(bufnr)
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  lsp_format_line_range(bufnr, start_line, end_line)
end

local function lsp_format_buffer(bufnr)
  if has_lsp_format_client(bufnr, "textDocument/formatting") then
    vim.lsp.buf.format({ bufnr = bufnr })
  end
end

local function git_hunk_ranges(bufnr)
  local ok, gitsigns = pcall(require, "gitsigns")
  if not ok or not gitsigns.get_hunks then
    vim.notify_once("[LSP] gitsigns hunks are not available; skipping changed-hunk format", vim.log.levels.WARN)
    return nil
  end

  local ranges = {}
  local hunks = gitsigns.get_hunks(bufnr) or {}
  for _, hunk in ipairs(hunks) do
    if hunk.added.count > 0 then
      ranges[#ranges + 1] = {
        start = hunk.added.start,
        ["end"] = hunk.added.start + hunk.added.count - 1,
      }
    end
  end

  return ranges
end

local function jj_root_for_buf(bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if bufname == "" then
    return nil
  end

  local jj_dirs = vim.fs.find(".jj", {
    path = vim.fs.dirname(bufname),
    upward = true,
    type = "directory",
    limit = 1,
  })
  if not jj_dirs[1] then
    return nil
  end

  return vim.fs.dirname(jj_dirs[1])
end

local function relative_path(root, path)
  root = vim.fs.normalize(root)
  path = vim.fs.normalize(path)

  local prefix = root:sub(-1) == "/" and root or root .. "/"
  if path:sub(1, #prefix) ~= prefix then
    return nil
  end

  return path:sub(#prefix + 1)
end

local function jj_hunk_ranges(bufnr, root)
  if vim.fn.executable("jj") == 0 then
    vim.notify_once("[LSP] jj is not executable; skipping changed-hunk format", vim.log.levels.WARN)
    return nil
  end

  local relpath = relative_path(root, vim.api.nvim_buf_get_name(bufnr))
  if not relpath then
    vim.notify_once("[LSP] Buffer is outside jj workspace; skipping changed-hunk format", vim.log.levels.WARN)
    return nil
  end

  local result = vim.system({
    "jj",
    "--no-pager",
    "--color=never",
    "--quiet",
    "--no-integrate-operation",
    "diff",
    "--git",
    "--context=0",
    "--",
    relpath,
  }, { cwd = root, text = true }):wait()

  if result.code ~= 0 then
    local message = vim.trim(result.stderr or result.stdout or "")
    vim.notify(message ~= "" and message or "[LSP] jj diff failed", vim.log.levels.ERROR)
    return nil
  end

  local ranges = {}
  for line in (result.stdout or ""):gmatch("[^\r\n]+") do
    local start, count = line:match("^@@ %-%d+,?%d* %+(%d+),?(%d*) @@")
    if start then
      start = tonumber(start)
      count = count ~= "" and tonumber(count) or 1
      if start and count and count > 0 then
        ranges[#ranges + 1] = {
          start = start,
          ["end"] = start + count - 1,
        }
      end
    end
  end

  return ranges
end

local function lsp_format_git_hunks(bufnr)
  return lsp_format_line_ranges(bufnr, git_hunk_ranges(bufnr) or {})
end

local function lsp_format_jj_hunks(bufnr, root)
  return lsp_format_line_ranges(bufnr, jj_hunk_ranges(bufnr, root) or {})
end

local function lsp_format_local_hunks(bufnr)
  local jj_root = jj_root_for_buf(bufnr)
  if jj_root then
    if vim.bo[bufnr].modified then
      vim.notify_once("[LSP] Save before manually formatting jj hunks", vim.log.levels.WARN)
      return false
    end

    return lsp_format_jj_hunks(bufnr, jj_root)
  end

  return lsp_format_git_hunks(bufnr)
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspFormatting", { clear = true }),
  callback = function(ev)
    local opts = { buf = ev.buf, silent = true }
    vim.keymap.set("n", "<leader>lf", function()
      lsp_format_buffer(ev.buf)
    end, vim.tbl_extend("force", opts, { desc = "Format buffer" }))
    vim.keymap.set("x", "<leader>lf", function()
      lsp_format_visual_selection(ev.buf)
    end, vim.tbl_extend("force", opts, { desc = "Format selection" }))
    vim.keymap.set("n", "<leader>lF", function()
      lsp_format_local_hunks(ev.buf)
    end, vim.tbl_extend("force", opts, { desc = "Format changed hunks" }))
  end,
})

-- Values: "file" formats the whole buffer, "hunks" formats changed hunks.
local lsp_format_on_save_filetypes = {
  javascript = "hunks",
  javascriptreact = "hunks",
  lua = "file",
  nix = "file",
  php = "hunks",
  r = "file",
  rust = "file",
  scheme = "file",
  typescript = "hunks",
  typescriptreact = "hunks",
}

local lsp_format_on_save_group = vim.api.nvim_create_augroup("LspFormatOnSave", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
  group = lsp_format_on_save_group,
  pattern = "*",
  callback = function(ev)
    local format_mode = lsp_format_on_save_filetypes[vim.bo[ev.buf].filetype]
    if not format_mode then
      return
    end

    if format_mode == "file" then
      lsp_format_buffer(ev.buf)
    elseif format_mode == "hunks" then
      local jj_root = jj_root_for_buf(ev.buf)
      if jj_root then
        vim.b[ev.buf].lsp_format_jj_hunks_after_save = jj_root
      else
        lsp_format_git_hunks(ev.buf)
      end
    else
      vim.notify_once(
        ("[LSP] Invalid format-on-save mode %q for %s"):format(tostring(format_mode), vim.bo[ev.buf].filetype),
        vim.log.levels.WARN
      )
    end
  end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
  group = lsp_format_on_save_group,
  pattern = "*",
  callback = function(ev)
    local jj_root = vim.b[ev.buf].lsp_format_jj_hunks_after_save
    if not jj_root then
      return
    end
    vim.b[ev.buf].lsp_format_jj_hunks_after_save = nil

    if lsp_format_jj_hunks(ev.buf, jj_root) and vim.bo[ev.buf].modified then
      vim.api.nvim_buf_call(ev.buf, function()
        vim.cmd("silent noautocmd write")
      end)
    end
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("ZshFormatOnSave", { clear = true }),
  pattern = "*",
  callback = function(ev)
    if vim.bo[ev.buf].filetype ~= "zsh" then
      return
    end

    local lines = vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false)
    local stdin = table.concat(lines, "\n")
    if vim.bo[ev.buf].endofline then
      stdin = stdin .. "\n"
    end

    local result = vim.system({ "beautysh", "--indent-size", "2", "-" }, { stdin = stdin, text = true }):wait()
    if result.code == 0 then
      local formatted = vim.split(result.stdout or "", "\n", { plain = true })
      if (result.stdout or ""):sub(-1) == "\n" then
        table.remove(formatted)
      end
      vim.api.nvim_buf_set_lines(ev.buf, 0, -1, false, formatted)
    else
      local message = vim.trim(result.stderr or "")
      message = message:match("[^\n]+") or message
      if message == "" then
        message = ("beautysh failed with exit code %s"):format(result.code)
      elseif #message > 240 then
        message = message:sub(1, 240) .. "..."
      end
      vim.notify(message, vim.log.levels.ERROR, { title = "beautysh" })
    end
  end,
})
