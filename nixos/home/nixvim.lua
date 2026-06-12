-- Core
vim.opt.diffopt:append({
  "iwhite",
  "algorithm:histogram",
  "indent-heuristic",
  "context:3",
})
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.undodir = vim.fn.stdpath("data") .. "/.nvim-undo//"
vim.fn.mkdir(vim.fn.stdpath("cache"), "p")

local function delete_current_file()
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

local function toggle_line_numbers()
  local enabled = not vim.wo.number
  vim.wo.number = enabled
  vim.wo.relativenumber = enabled
end

local function toggle_cursor_line()
  vim.wo.cursorline = not vim.wo.cursorline
end

vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile", "InsertLeave" }, {
  pattern = "*",
  callback = function()
    vim.cmd([[match ExtraWhitespace /\s\+$/]])
  end,
})

vim.api.nvim_create_autocmd("InsertEnter", {
  pattern = "*",
  callback = function()
    vim.cmd([[match none]])
  end,
})

vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave" }, {
  pattern = "*",
  callback = function()
    toggle_cursor_line()
  end,
})

vim.keymap.set("n", "<leader>ll", toggle_line_numbers, { desc = "Toggle line numbers" })
vim.keymap.set("n", "\\wb", function()
  local folder = vim.fn.expand("~/code/blog/posts")
  local date = os.date("%Y-%m-%d")
  local seconds = os.time()
  local filename = string.format("%s/%s_%d.md", folder, date, seconds)
  vim.fn.mkdir(folder, "p")
  vim.cmd("edit " .. filename)
end, { desc = "Create new timestamped file" })
vim.keymap.set("n", "<leader>cl", toggle_cursor_line, { desc = "Toggle cursor line" })

vim.o.laststatus = 2
vim.keymap.set("n", "<leader>e", function()
  vim.o.laststatus = vim.o.laststatus == 0 and 2 or 0
end, { desc = "Toggle status line" })

-- Project root
local markers = {
  ".jj",
  ".git",
  "flake.nix",
  "package.json",
  "Cargo.toml",
}

vim.api.nvim_create_autocmd({ "VimEnter", "BufEnter" }, {
  callback = function(args)
    local path = vim.api.nvim_buf_get_name(args.buf)
    if path == "" then
      return
    end

    local stat = vim.uv.fs_stat(path)
    local start = stat and stat.type == "directory" and path or vim.fs.dirname(path)
    local root = vim.fs.root(start, markers)

    if root and root ~= vim.fn.getcwd() then
      vim.cmd.tcd(vim.fn.fnameescape(root))
    end
  end,
})

-- Syntax highlighting
vim.cmd("syntax off")

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client then
      client.server_capabilities.semanticTokensProvider = nil
      vim.lsp.semantic_tokens.enable(false, { client_id = client.id })
    end
  end,
})

-- LSP
require("lazydev").setup({})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(args)
    local opts = { buf = args.buf, silent = true }
    local hover_opts = {
      border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
      max_width = 100,
    }
    vim.keymap.set("n", "K", function()
      if vim.tbl_contains({ "javascript", "javascriptreact", "typescript", "typescriptreact" }, vim.bo.filetype) then
        vim.lsp.buf.definition({
          on_list = function(options)
            vim.lsp.util.preview_location(options.items[1].user_data, hover_opts)
          end,
        })
      else
        vim.lsp.buf.hover(hover_opts)
      end
    end, opts)
    vim.keymap.set("n", "<C-k>", function()
      vim.lsp.buf.signature_help({ border = "double" })
    end, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "gI", vim.lsp.buf.implementation, opts)
  end,
})

local orig_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or "rounded"
  opts.pad_top = opts.pad_top or 1
  opts.pad_bottom = opts.pad_bottom or 1
  contents = vim.tbl_map(function(line)
    return " " .. line .. " "
  end, contents)
  return orig_open_floating_preview(contents, syntax, opts, ...)
end

local diagnostic_float_opts = {
  border = "rounded",
  pad_top = 1,
  pad_bottom = 1,
  scope = "line",
  format = function(d)
    return " " .. d.message .. " "
  end,
}

local function show_line_diagnostics(focus)
  vim.diagnostic.open_float(nil, vim.tbl_extend("force", diagnostic_float_opts, { focus = focus }))
end

vim.diagnostic.config({
  virtual_text = false,
  float = diagnostic_float_opts,
})

vim.keymap.set("n", "gl", function()
  show_line_diagnostics(true)
end, { desc = "Show line diagnostics" })

vim.api.nvim_create_autocmd("CursorHold", {
  group = vim.api.nvim_create_augroup("LineDiagnostics", { clear = true }),
  callback = function()
    show_line_diagnostics(false)
  end,
})

vim.lsp.config("eslint", {})
vim.lsp.config("phpactor", {
  filetypes = { "php" },
  init_options = {
    ["language_server_phpstan.enabled"] = false,
    ["language_server_psalm.enabled"] = false,
  },
})

vim.lsp.config("vtsls", {
  filetypes = {
    "typescript",
    "typescriptreact",
    "javascript",
    "javascriptreact",
  },
})
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = {
        checkThirdParty = false,
        ignoreDir = {
          "result",
          "nixos/home/result",
          "nixos/sys/result",
        },
      },
      telemetry = { enable = false },
    },
  },
})
vim.lsp.config("nixd", {})
vim.lsp.config("scheme_langserver", { filetypes = { "scheme" } })
vim.lsp.enable({
  "eslint",
  "phpactor",
  "vtsls",
  "lua_ls",
  "nixd",
  "scheme_langserver",
})

vim.lsp.config("ast_grep", {
  cmd = { "ast-grep", "lsp" },
  filetypes = { "c", "cpp", "rust", "go", "java", "python", "javascript", "typescript", "html", "css", "kotlin", "dart", "lua" },
  root_dir = require("lspconfig.util").root_pattern("sgconfig.yaml", "sgconfig.yml"),
})

-- Formatting
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

    local ok, result = pcall(function()
      return vim.system({ "shfmt", "-ln", "zsh", "-i", "2", "-" }, { stdin = stdin, text = true }):wait()
    end)
    if not ok then
      vim.notify_once(("shfmt failed to start: %s"):format(result), vim.log.levels.WARN, { title = "shfmt" })
      return
    end

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
        message = ("shfmt failed with exit code %s"):format(result.code)
      elseif #message > 240 then
        message = message:sub(1, 240) .. "..."
      end
      vim.notify_once(message, vim.log.levels.WARN, { title = "shfmt" })
    end
  end,
})

-- Treesitter
require("nvim-treesitter").setup({
  install_dir = vim.fn.stdpath("data") .. "/site",
  highlight = { enable = false },
})

vim.api.nvim_create_autocmd("FileType", {
  callback = function(ev)
    local parser = vim.treesitter.get_parser(ev.buf)
    if not parser then
      return
    end

    vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

require("nvim-treesitter-textobjects").setup({
  move = { set_jumps = true },
})

local ts_move = require("nvim-treesitter-textobjects.move")
local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")

local function map_move(lhs, rhs, desc)
  vim.keymap.set({ "n", "x", "o" }, lhs, rhs, { desc = desc })
end

map_move("]m", function()
  ts_move.goto_next_start("@function.outer", "textobjects")
end, "Next function start")
map_move("]]", function()
  ts_move.goto_next_start("@class.outer", "textobjects")
end, "Next class start")
map_move("]o", function()
  ts_move.goto_next_start("@loop.outer", "textobjects")
end, "Next loop start")
map_move("]s", function()
  ts_move.goto_next_start("@local.scope", "locals")
end, "Next scope")
map_move("]z", function()
  ts_move.goto_next_start("@fold", "folds")
end, "Next fold")

map_move("]M", function()
  ts_move.goto_next_end("@function.outer", "textobjects")
end, "Next function end")
map_move("][", function()
  ts_move.goto_next_end("@class.outer", "textobjects")
end, "Next class end")

map_move("[m", function()
  ts_move.goto_previous_start("@function.outer", "textobjects")
end, "Previous function start")
map_move("[[", function()
  ts_move.goto_previous_start("@class.outer", "textobjects")
end, "Previous class start")

map_move("[M", function()
  ts_move.goto_previous_end("@function.outer", "textobjects")
end, "Previous function end")
map_move("[]", function()
  ts_move.goto_previous_end("@class.outer", "textobjects")
end, "Previous class end")

vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)
vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })

require("treesitter-context").setup({
  enable = true,
  max_lines = 3,
  separator = "─",
})
vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "#2e2e3e" })
vim.api.nvim_set_hl(0, "TreesitterContextSeparator", { fg = "#555577" })

-- Telescope
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
    ast_grep = {
      command = {
        "ast-grep",
        "--json=stream",
      },
      grep_open_files = false,
      lang = nil,
    },
  },
})
telescope.load_extension("fzf")
telescope.load_extension("file_browser")
telescope.load_extension("ast_grep")

vim.keymap.set("n", "<leader>ee", ":Telescope file_browser<CR>", { desc = "File browser with preview" })
vim.keymap.set("n", "<leader>ef", ":Telescope file_browser path=%:p:h select_buffer=true<CR>",
  { desc = "File browser focusing current file" })

local builtin = require("telescope.builtin")
local make_entry = require("telescope.make_entry")

local function is_rust_test_attribute(line)
  return line:match("^#%s*%[%s*test%s*%]")
      or line:match("^#%s*%[%s*[%w_]+::test")
      or line:match("^#%s*%[%s*rstest")
end

local function rust_symbol_has_test_attribute(bufnr, lnum)
  if vim.bo[bufnr].filetype ~= "rust" then
    return false
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, math.max(0, lnum - 8), lnum - 1, false)
  for i = #lines, 1, -1 do
    local line = vim.trim(lines[i])
    if line == "" then
      return false
    end
    if line:match("^#%s*%[") then
      if is_rust_test_attribute(line) then
        return true
      end
    else
      return false
    end
  end

  return false
end

local function treesitter_symbols()
  local opts = { bufnr = vim.api.nvim_get_current_buf(), show_line = true }
  local base_entry_maker = make_entry.gen_from_treesitter(opts)

  opts.entry_maker = function(raw_entry)
    local entry = base_entry_maker(raw_entry)
    if entry and rust_symbol_has_test_attribute(opts.bufnr, entry.lnum) then
      entry.text = "[test] " .. entry.text
      entry.ordinal = "[test] " .. entry.ordinal
    end
    return entry
  end

  builtin.treesitter(opts)
end

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
vim.keymap.set("n", "<leader>s", treesitter_symbols, { desc = "Search Tree-sitter symbols" })
vim.keymap.set("n", "<leader>S", builtin.lsp_dynamic_workspace_symbols, { desc = "Search workspace symbols" })
vim.keymap.set("n", "<leader>?", ":Telescope keymaps<CR>", { silent = true })
vim.keymap.set("n", "<leader>of", ":Telescope oldfiles only_cwd=true<CR>", { silent = true })
vim.keymap.set("n", "<leader>dd", "<cmd>Telescope diagnostics<CR>", { desc = "Telescope: diagnostics" })
vim.keymap.set("n", "<leader>rf", function()
  builtin.lsp_references({ include_declaration = false, include_current_line = false })
end, { desc = "Telescope: lsp_references (usages only)" })
vim.keymap.set("n", "<leader>rr", builtin.registers, { desc = "Registers" })
vim.keymap.set("n", "<leader>ic", builtin.lsp_incoming_calls, { desc = "Telescope: lsp_incoming_calls" })
vim.keymap.set("n", "<leader>oc", builtin.lsp_outgoing_calls, { desc = "Telescope: lsp_outgoing_calls" })
vim.keymap.set("n", "<leader>f", function()
  require("telescope").extensions.frecency.frecency({ workspace = "CWD" })
end, { desc = "Telescope: Frecent files" })

-- Completion
local cmp = require("cmp")
local luasnip = require("luasnip")
luasnip.config.setup({})
cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = { completeopt = "menu,menuone,noinsert" },
  window = {
    completion = cmp.config.window.bordered({ border = "rounded" }),
    documentation = cmp.config.window.bordered({ border = "rounded" }),
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-y>"] = cmp.mapping.confirm({ select = true }),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<C-Space>"] = cmp.mapping.complete({}),
    ["<C-l>"] = cmp.mapping(function()
      if luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      end
    end, { "i", "s" }),
    ["<C-h>"] = cmp.mapping(function(fallback)
      if luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = {
    { name = "lazydev", group_index = 0 },
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "path" },
    { name = "buffer" },
  },
})
cmp.setup.filetype("markdown", {
  completion = { autocomplete = false },
})

-- Obsidian
vim.g.bullets_enabled_file_types = { "markdown" }
vim.g.bullets_enable = 1
vim.g.bullets_checkbox_markers = " ~x"
vim.g.bullets_outline_levels = { "std-", "std*", "std+", "num", "rom", "abc", "ROM" }
vim.g.bullets_set_mappings = 0
vim.g.bullets_custom_mappings = {
  { "imap",     "<CR>",   "<Plug>(bullets-newline)" },
  { "inoremap", "<C-CR>", "<CR>" },
  { "nmap",     "o",      "<Plug>(bullets-newline)" },
}
local function open_vault_file(name)
  local obsidian_state = rawget(_G, "Obsidian")
  local workspace = obsidian_state and obsidian_state.workspace
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
    { name = "work",     path = "~/vaults/clt" },
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

-- Debugging
require("nvim-dap-virtual-text").setup()
local dap = require("dap")
local dapui = require("dapui")
dapui.setup()
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end
vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Continue" })
vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Debug: Open REPL" })

dap.adapters["pwa-node"] = {
  type = "server",
  host = "127.0.0.1",
  port = "${port}",
  executable = {
    command = vim.g.nixvim_js_debug_adapter,
    args = { "${port}" },
  },
}

dap.adapters.php = {
  type = "executable",
  command = "node",
  args = { vim.g.nixvim_php_debug_adapter },
}

local js_configurations = {
  {
    type = "pwa-node",
    request = "launch",
    name = "Launch file",
    program = "${file}",
    cwd = vim.fn.getcwd(),
    sourceMaps = true,
    runtimeExecutable = "node",
    console = "integratedTerminal",
    internalConsoleOptions = "neverOpen",
  },
}
dap.configurations.javascript = js_configurations
dap.configurations.javascriptreact = js_configurations
dap.configurations.typescript = js_configurations
dap.configurations.typescriptreact = js_configurations

dap.configurations.php = {
  {
    type = "php",
    request = "launch",
    name = "Listen for Xdebug",
    port = 9003,
    pathMappings = { ["/opt/abhe"] = "~/code/abhe" },
  },
}
dap.adapters.r = {
  type = "executable",
  command = "R",
  args = { "--no-save", "-e", "library(debugR);debugR::run()" },
}
dap.configurations.r = {
  {
    type = "r",
    request = "launch",
    name = "Debug R Script",
    program = "${file}",
    cwd = vim.fn.getcwd(),
    console = "integratedTerminal",
  },
}

-- Git and diagnostics
vim.keymap.set("n", "<leader>Gy", function()
  require("gitlinker").get_buf_range_url("n")
end, { desc = "Copy GitHub link" })
vim.keymap.set("v", "<leader>Gy", function()
  require("gitlinker").get_buf_range_url("v")
end, { desc = "Copy GitHub link (selection)" })
vim.keymap.set("n", "<leader>Go", function()
  require("gitlinker").get_buf_range_url("n", { action_callback = require("gitlinker.actions").open_in_browser })
end, { desc = "Open GitHub link" })
vim.keymap.set("v", "<leader>Go", function()
  require("gitlinker").get_buf_range_url("v", { action_callback = require("gitlinker.actions").open_in_browser })
end, { desc = "Open GitHub link (selection)" })

require("trouble").setup({
  position = "bottom",
  height = 10,
  width = 50,
  mode = "workspace_diagnostics",
  auto_open = false,
  auto_close = true,
  signs = {
    error = "",
    warning = "",
    hint = "",
    information = "",
    other = "",
  },
  use_diagnostic_signs = true,
})
vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", { desc = "Trouble: Workspace Diagnostics" })
vim.keymap.set("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>",
  { desc = "Trouble: Buffer Diagnostics" })
vim.keymap.set("n", "<leader>xs", "<cmd>Trouble symbols toggle focus=false<CR>", { desc = "Trouble: Symbols (LSP)" })
vim.keymap.set("n", "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<CR>",
  { desc = "Trouble: LSP Definitions / References" })
vim.keymap.set("n", "<leader>xq", "<cmd>Trouble qflist toggle<CR>", { desc = "Trouble: Quickfix List" })
vim.keymap.set("n", "<leader>xL", "<cmd>Trouble loclist toggle<CR>", { desc = "Trouble: Location List" })

require("gitsigns").setup({
  signs = {
    add = { text = "+" },
    change = { text = "~" },
    delete = { text = "_" },
    topdelete = { text = "‾" },
    changedelete = { text = "~" },
  },
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns
    local trouble = require("trouble")

    local function map(mode, lhs, rhs, opts)
      opts = opts or {}
      opts.buf = bufnr
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    map("n", "<leader>hq", function()
      gs.setqflist(0, { use_location_list = true, open = false }, function()
        trouble.close("qflist")
        trouble.open({ mode = "loclist", focus = true, win = { position = "bottom", size = 0.15 } })
      end)
    end, { desc = "Git hunks in buffer" })

    map("n", "<leader>hQ", function()
      gs.setqflist("all", { open = false }, function()
        trouble.close("loclist")
        trouble.open({ mode = "qflist", focus = true, win = { position = "bottom", size = 0.15 } })
      end)
    end, { desc = "Git hunks in repo" })

    map("n", "]c", function()
      if vim.wo.diff then
        return "]c"
      end
      vim.schedule(function()
        gs.next_hunk()
      end)
      return "<Ignore>"
    end, { expr = true, desc = "Next Git hunk" })

    map("n", "[c", function()
      if vim.wo.diff then
        return "[c"
      end
      vim.schedule(function()
        gs.prev_hunk()
      end)
      return "<Ignore>"
    end, { expr = true, desc = "Previous Git hunk" })

    map("n", "<leader>hn", gs.next_hunk, { desc = "Next Git hunk" })
    map("n", "<leader>hp", gs.prev_hunk, { desc = "Previous Git hunk" })
    map("n", "<leader>hl", gs.preview_hunk, { desc = "Preview Git hunk" })
    map("n", "<leader>hb", function()
      gs.blame_line({ full = true })
    end, { desc = "Git blame line" })
    map("n", "<leader>hr", function()
      vim.ui.input({ prompt = "Are you sure? (y/n): " }, function(input)
        if input and (input:lower() == "y" or input:lower() == "yes") then
          gs.reset_hunk()
          print("Hunk reset")
        else
          print("Hunk reset cancelled")
        end
      end)
    end, { desc = "Reset Git hunk with confirmation" })
  end,
})

require("grug-far").setup({})

require("flash").setup({
  event = "VeryLazy",
  ---@type Flash.Config
  opts = {},
  keys = {
    { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
    { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
    { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
    { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
  },
})

-- UI
require("mini.surround").setup({
  custom_surroundings = {
    [")"] = { output = { left = "(", right = ")" } },
    ["("] = { output = { left = "(", right = ")" } },
    ["["] = { output = { left = "[", right = "]" } },
    ["]"] = { output = { left = "[", right = "]" } },
    ["{"] = { output = { left = "{", right = "}" } },
    ["}"] = { output = { left = "{", right = "}" } },
  },
  highlight_duration = 500,
  mappings = {
    add = "sa",
    delete = "sd",
    find = "sf",
    find_left = "sF",
    highlight = "sh",
    replace = "sr",
    suffix_last = "l",
    suffix_next = "n",
  },
  n_lines = 20,
  respect_selection_type = false,
  search_method = "cover",
  silent = false,
})

local function get_system_appearance()
  if vim.fn.executable("darkman") == 1 then
    local ok, output = pcall(vim.fn.system, { "darkman", "get" })
    if ok and vim.v.shell_error == 0 then
      local appearance = vim.trim(output)
      if appearance == "light" or appearance == "dark" then
        return appearance
      end
    end
  end

  return vim.o.background
end

local function apply_cursor_line_highlight()
  vim.api.nvim_set_hl(0, "CursorLine", {
    ctermbg = get_system_appearance() == "light" and 15 or 234,
  })
end

apply_cursor_line_highlight()
vim.api.nvim_create_autocmd({ "ColorScheme", "FocusGained", "VimEnter" }, {
  callback = apply_cursor_line_highlight,
})

-- Rust
local extension_path = vim.env.HOME .. "/.nix-profile/share/vscode/extensions/vadimcn.vscode-lldb/"
local codelldb_path = extension_path .. "adapter/codelldb"
local liblldb_path = extension_path .. "lldb/lib/liblldb.so"
local codelldb_adapter = require("rustaceanvim.config").get_codelldb_adapter(codelldb_path, liblldb_path)

vim.g.rustaceanvim = {
  dap = {
    adapter = codelldb_adapter,
  },
  server = {
    default_settings = {
      ["rust-analyzer"] = {
        check = { command = "clippy" },
        cargo = { allFeatures = true },
      },
    },
  },
}

vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function(ev)
    local dap = require("dap")

    local function pkg_name_from_cargo()
      local cargo_toml = vim.fn.findfile("Cargo.toml", ".;")
      if cargo_toml == "" then
        return nil
      end
      for line in io.lines(cargo_toml) do
        local n = line:match('^name%s*=%s*"([^"]+)"')
        if n then
          return n
        end
      end
      return nil
    end

    local function attach_to_running()
      local name = pkg_name_from_cargo()
      if not name then
        vim.notify("No Cargo.toml package name found", vim.log.levels.WARN)
        return
      end
      local handle = io.popen("pgrep -af " .. vim.fn.shellescape(name))
      if not handle then
        vim.notify("pgrep failed", vim.log.levels.ERROR)
        return
      end
      local entries = {}
      for line in handle:lines() do
        local pid, cmdline = line:match("^(%d+)%s+(.*)$")
        local is_binary = pid and
            (cmdline:find("target/debug/" .. name, 1, true) or cmdline:find("target/release/" .. name, 1, true))
        local is_cargo = pid and (cmdline:match("^cargo%s") or cmdline:find("/cargo ", 1, true))
        if is_binary or is_cargo then
          table.insert(entries, { pid = pid, cmdline = cmdline })
        end
      end
      handle:close()
      table.sort(entries, function(a, b)
        local function score(c)
          if c:find("target/debug/", 1, true) then
            return 0
          end
          if c:find("target/release/", 1, true) then
            return 1
          end
          return 2
        end
        return score(a.cmdline) < score(b.cmdline)
      end)
      if #entries == 0 then
        vim.notify("No running process matching: " .. name, vim.log.levels.WARN)
        return
      end
      local function go(pid)
        dap.adapters.codelldb = codelldb_adapter
        dap.run({
          type = "codelldb",
          request = "attach",
          name = "Attach to " .. name,
          pid = tonumber(pid),
          sourceLanguages = { "rust" },
        })
      end
      if #entries == 1 then
        go(entries[1].pid)
      else
        vim.ui.select(entries, {
          prompt = "Attach to which " .. name .. " process?",
          format_item = function(e)
            return e.pid .. "  " .. e.cmdline
          end,
        }, function(choice)
          if choice then
            go(choice.pid)
          end
        end)
      end
    end

    vim.keymap.set("n", "<leader>dR", function()
      vim.cmd.RustLsp("debuggables")
    end, { desc = "Rust: Launch debuggable", buf = ev.buf })
    vim.keymap.set("n", "<leader>dA", attach_to_running, { desc = "Rust: Attach to running process", buf = ev.buf })
  end,
})

-- Tmux
vim.g.tmux_navigator_no_mappings = 1
vim.keymap.set("n", "<M-h>", "<cmd>TmuxNavigateLeft<CR>")
vim.keymap.set("n", "<M-j>", "<cmd>TmuxNavigateDown<CR>")
vim.keymap.set("n", "<M-k>", "<cmd>TmuxNavigateUp<CR>")
vim.keymap.set("n", "<M-l>", "<cmd>TmuxNavigateRight<CR>")

-- TODOs
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

-- from `:h registers` the Yank-ring: store yanked text in registers 1-9.
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    if vim.v.event.operator == 'y' then
      for i = 9, 1, -1 do -- Shift all numbered registers.
        vim.fn.setreg(tostring(i), vim.fn.getreg(tostring(i - 1)))
      end
    end
  end,
})

-- misc keymaps (this whole file needs organizing)
vim.keymap.set("n", "<leader>yf", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
end)
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- user commands
vim.api.nvim_create_user_command("ClearRegisters", function()
  local regs = [[abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-"*+]]

  for r in regs:gmatch(".") do
    pcall(vim.fn.setreg, r, {})
  end

  vim.fn.setreg("/", "")
  -- persist the cleared registers by calling wshada?
  -- vim.cmd("wshada!");
end, {})

vim.api.nvim_create_user_command("DeleteFile", delete_current_file, {
  desc = "Delete the file for the current buffer",
})
