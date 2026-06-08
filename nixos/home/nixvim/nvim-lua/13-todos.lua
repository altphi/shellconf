local tags = { "TODO", "WIP", "FIXME", "HACK", "XXX" }
local rg_pattern = "\\b(" .. table.concat(tags, "|") .. ")\\b"
local count_cache = {}

vim.api.nvim_set_hl(0, "TodoStatusLine", { fg = "#5fd7d7", ctermfg = 14, bold = true })

local function todo_col(text)
  for _, tag in ipairs(tags) do
    local col = text:find("%f[%w_]" .. tag .. "%f[^%w_]")
    if col then
      return col
    end
  end
end

local function count_buffer_todos(bufnr)
  local changedtick = vim.api.nvim_buf_get_changedtick(bufnr)
  local cached = count_cache[bufnr]

  if cached and cached.changedtick == changedtick then
    return cached.count
  end

  local count = 0
  for _, text in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    if todo_col(text) then
      count = count + 1
    end
  end

  count_cache[bufnr] = { changedtick = changedtick, count = count }
  return count
end

local function project_root()
  local filename = vim.api.nvim_buf_get_name(0)
  local start = filename ~= "" and vim.fs.dirname(filename) or vim.uv.cwd()
  local git_dir = vim.fs.find(".git", { path = start, upward = true })[1]

  return git_dir and vim.fs.dirname(git_dir) or start
end

vim.api.nvim_create_user_command("TodoQuickfix", function()
  local root = project_root()
  local lines = vim.fn.systemlist({
    "rg",
    "--vimgrep",
    "--hidden",
    "--glob",
    "!**/.git/*",
    rg_pattern,
    root,
  })

  if vim.v.shell_error > 1 then
    vim.notify("TODO search failed: " .. table.concat(lines, "\n"), vim.log.levels.ERROR)
    return
  end

  vim.fn.setqflist({}, " ", {
    title = "TODO comments: " .. vim.fn.fnamemodify(root, ":~"),
    lines = lines,
    efm = "%f:%l:%c:%m",
  })

  if #lines == 0 then
    vim.cmd("cclose")
    vim.notify("No TODO comments found in " .. vim.fn.fnamemodify(root, ":~"))
    return
  end

  vim.cmd("botright copen")
end, { desc = "List project TODO comments in quickfix" })

vim.api.nvim_create_user_command("TodoLoclist", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local title = filename ~= "" and vim.fn.fnamemodify(filename, ":~:.") or "[No Name]"
  local items = {}

  for lnum, text in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    local col = todo_col(text)
    if col then
      table.insert(items, { bufnr = bufnr, lnum = lnum, col = col, text = text })
    end
  end

  vim.fn.setloclist(0, {}, " ", {
    title = "TODO comments: " .. title,
    items = items,
  })

  if #items == 0 then
    vim.cmd("lclose")
    vim.notify("No TODO comments found in " .. title)
    return
  end

  vim.cmd("botright lopen")
end, { desc = "List buffer TODO comments in the location list" })

vim.keymap.set("n", "<leader>tq", "<cmd>TodoQuickfix<CR>", { desc = "TODOs to quickfix" })
vim.keymap.set("n", "<leader>tl", "<cmd>TodoLoclist<CR>", { desc = "TODOs to location list" })
vim.keymap.set("n", "]q", "<cmd>cnext<CR>", { desc = "Next quickfix item", silent = true })
vim.keymap.set("n", "[q", "<cmd>cprevious<CR>", { desc = "Previous quickfix item", silent = true })
vim.keymap.set("n", "]l", "<cmd>lnext<CR>", { desc = "Next location-list item", silent = true })
vim.keymap.set("n", "[l", "<cmd>lprevious<CR>", { desc = "Previous location-list item", silent = true })

vim.api.nvim_create_autocmd("BufWipeout", {
  callback = function(args)
    count_cache[args.buf] = nil
  end,
})

function _G.nvim_todo_statusline()
  local bufnr = vim.api.nvim_get_current_buf()
  local count = count_buffer_todos(bufnr)

  if count == 0 then
    return ""
  end

  return "%#TodoStatusLine#T:" .. count .. "%##"
end

function _G.nvim_todo_diagnostic_statusline()
  local diagnostic_status = ""
  if package.loaded["vim.diagnostic"] and next(vim.diagnostic.count()) then
    diagnostic_status = vim.diagnostic.status()
  end

  local todo_status = _G.nvim_todo_statusline()
  if diagnostic_status == "" and todo_status == "" then
    return ""
  end

  if diagnostic_status == "" then
    return todo_status .. " "
  end

  if todo_status == "" then
    return diagnostic_status .. " "
  end

  return diagnostic_status:gsub("%%##$", "") .. " " .. todo_status .. " "
end

do
  local todo_status = "%{%v:lua.nvim_todo_statusline()%}"
  local combined_status = "%{%v:lua.nvim_todo_diagnostic_statusline()%}"
  local diagnostic_expr =
    "luaeval('(package.loaded[''vim.diagnostic''] and next(vim.diagnostic.count()) and vim.diagnostic.status() .. '' '') or '''' ')"
  local diagnostic_status = "%{% " .. diagnostic_expr .. " %}"
  local broken_diagnostic_status = "{ " .. diagnostic_expr .. " }"
  local broken_todo_status = "{ v:lua.nvim_todo_statusline() }"

  vim.o.statusline = vim.o.statusline:gsub(vim.pesc(broken_diagnostic_status), function()
    return diagnostic_status
  end, 1)
  vim.o.statusline = vim.o.statusline:gsub(vim.pesc(broken_todo_status), "", 1)

  if not vim.o.statusline:find("nvim_todo_diagnostic_statusline", 1, true) then
    local diagnostic_and_todo = diagnostic_status .. todo_status
    if vim.o.statusline:find(diagnostic_and_todo, 1, true) then
      vim.o.statusline = vim.o.statusline:gsub(vim.pesc(diagnostic_and_todo), function()
        return combined_status
      end, 1)
    elseif vim.o.statusline:find(diagnostic_status, 1, true) then
      vim.o.statusline = vim.o.statusline:gsub(vim.pesc(diagnostic_status), function()
        return combined_status
      end, 1)
    elseif vim.o.statusline:find(todo_status, 1, true) then
      vim.o.statusline = vim.o.statusline:gsub(vim.pesc(todo_status), function()
        return combined_status
      end, 1)
    else
      vim.o.statusline = vim.o.statusline .. combined_status
    end
  end
end
