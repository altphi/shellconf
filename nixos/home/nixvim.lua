------------------------------
-- Disable syntax highlighting
------------------------------
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

-----------------------
-- general nvim options
-----------------------
vim.opt.undodir = vim.fn.stdpath("data") .. "/.nvim-undo//"
vim.fn.mkdir(vim.fn.stdpath("cache"), "p")

-- disable comment continuation in normal mode
vim.opt.formatoptions:remove("o")
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("DisableNormalModeCommentContinuation", { clear = true }),
  callback = function()
    vim.opt_local.formatoptions:remove("o")
  end,
})

-- treesitter
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

--------------------------
-- plugins
--------------------------
require("fidget").setup({})

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
      gs.setqflist(0, { use_location_list = true, open = false }, function(err)
        if err then
          vim.notify(err, vim.log.levels.ERROR)
          return
        end

        require("telescope.builtin").loclist({
          prompt_title = "Git hunks in buffer",
        })
      end)
    end, { desc = "Git hunks in buffer" })

    map("n", "<leader>hQ", function()
      gs.setqflist("all", { open = false }, function()
        trouble.close("loclist")
        trouble.open({ mode = "qflist", focus = true, win = { position = "bottom", size = 0.15 } })
        require("telescope.builtin").loclist({
          prompt_title = "Git hunks in repo",
        })
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
  modes = {
    char = {
      enabled = false,
    },
    -- search was broken the last time I tried... kept matching one less character than I'd typed and label presses didn't trigger.
    search = {
      enabled = false,
    },
  },
  label = {
    min_pattern_length = 0,
    current = true,
    distance = true,
    before = false,
    after = true,
    style = "overlay",
    rainbow = {
      enabled = false
    }
  },
})
vim.keymap.set("n", "<leader>j", function() require("flash").jump() end)


require("mini.surround").setup({
  custom_surroundings = {
    -- [")"] = { output = { left = "(", right = ")" } },
    -- ["("] = { output = { left = "(", right = ")" } },
    -- ["["] = { output = { left = "[", right = "]" } },
    -- ["]"] = { output = { left = "[", right = "]" } },
    -- ["{"] = { output = { left = "{", right = "}" } },
    -- ["}"] = { output = { left = "{", right = "}" } },
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

map_move("]m", function() ts_move.goto_next_start("@function.outer", "textobjects") end, "Next function start")
map_move("]]", function() ts_move.goto_next_start("@class.outer", "textobjects") end, "Next class start")
map_move("]o", function() ts_move.goto_next_start("@loop.outer", "textobjects") end, "Next loop start")
map_move("]s", function() ts_move.goto_next_start("@local.scope", "locals") end, "Next scope")
map_move("]z", function() ts_move.goto_next_start("@fold", "folds") end, "Next fold")

map_move("]M", function() ts_move.goto_next_end("@function.outer", "textobjects") end, "Next function end")
map_move("][", function() ts_move.goto_next_end("@class.outer", "textobjects") end, "Next class end")

map_move("[m", function() ts_move.goto_previous_start("@function.outer", "textobjects") end, "Previous function start")
map_move("[[", function() ts_move.goto_previous_start("@class.outer", "textobjects") end, "Previous class start")

map_move("[M", function() ts_move.goto_previous_end("@function.outer", "textobjects") end, "Previous function end")
map_move("[]", function() ts_move.goto_previous_end("@class.outer", "textobjects") end, "Previous class end")

vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)
vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })

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

local builtin = require("telescope.builtin")
local make_entry = require("telescope.make_entry")
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
vim.keymap.set("n", "<leader>s", treesitter_symbols, { desc = "Search Tree-sitter symbols" })

vim.keymap.set("n", "<leader>:", builtin.command_history, { desc = "nvim command history" })

vim.keymap.set("n", "<leader>c", builtin.git_status, { desc = "Telescope: Changed files" })
vim.keymap.set("n", "<leader>g",
  function() builtin.live_grep({ grep_open_files = true, prompt_title = "Telescope: Grep Open Files" }) end,
  { desc = "Telescope: Live grep" })
vim.keymap.set("n", "<leader>G", function() builtin.live_grep({ prompt_title = "Telescope: Grep Project" }) end,
  { desc = "Telescope: Live grep" })
vim.keymap.set("n", "<leader>b", function() builtin.buffers({ sort_mru = true, sort_lastused = true }) end,
  { desc = "Telescope: Buffers" })
vim.keymap.set("n", "<leader>m", builtin.marks, { desc = "Telescope: Marks" })
vim.keymap.set("n", "<leader>J", builtin.jumplist, { desc = "Telescope: Jumps" })
vim.keymap.set("n", "<leader>s", treesitter_symbols, { desc = "Search Tree-sitter symbols" })
vim.keymap.set("n", "<leader>S", builtin.lsp_dynamic_workspace_symbols, { desc = "Search workspace symbols" })
vim.keymap.set("n", "<leader>?", ":Telescope keymaps<CR>", { silent = true })
vim.keymap.set("n", "<leader>d", "<cmd>Telescope diagnostics<CR>", { desc = "Telescope: diagnostics" })
vim.keymap.set("n", "<leader>rf", function()
  builtin.lsp_references({ include_declaration = false, include_current_line = false })
end, { desc = "Telescope: lsp_references (usages only)" })
vim.keymap.set("n", "<leader>rr", builtin.registers, { desc = "Registers" })
vim.keymap.set("n", "<leader>ic", builtin.lsp_incoming_calls, { desc = "Telescope: lsp_incoming_calls" })
vim.keymap.set("n", "<leader>f", function()
  require("telescope").extensions.frecency.frecency({ workspace = "CWD" })
end, { desc = "Telescope: Frecent files" })


-- Completion
local luasnip = require("luasnip")
luasnip.config.setup({})

local cmp = require("cmp")
cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = { completeopt = "menu,menuone,noinsert", autocomplete = false },
  view = {
    docs = {
      auto_open = false,
    },
  },
  window = {
    completion = cmp.config.window.bordered({ border = "rounded" }),
    documentation = cmp.config.window.bordered({ border = "rounded" }),
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-n>"] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_next_item()
      else
        cmp.complete({
          config = {
            sources = {
              { name = "buffer" },
            },
          },
        })
      end
    end),
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-g>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        if cmp.visible_docs() then
          cmp.close_docs()
        else
          cmp.open_docs()
        end
      else
        fallback()
      end
    end),
    ["<C-y>"] = cmp.mapping.confirm({ select = true }),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<C-Space>"] = cmp.mapping.complete({
      config = {
        sources = {
          { name = "nvim_lsp" },
        },
      },
    }),
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
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "path" },
    { name = "buffer" },
  },
})
cmp.setup.filetype("markdown", {
  completion = { autocomplete = false },
})
cmp.setup.filetype("lua", {
  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" },
  },
})

-- Treesitter context
require("treesitter-context").setup({
  enable = true,
  max_lines = 3,
  separator = "─",
})
vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "#2e2e3e" })
vim.api.nvim_set_hl(0, "TreesitterContextSeparator", { fg = "#555577" })


-- Telescope

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





-- TODO keep or no?
--require("nvim-navic").setup({
--  icons = {
--    enabled = false,
--  },
--  separator = " > ",
--  lsp = {
--    auto_attach = true,
--  },
--})
----vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"

-------------
-- statusline
-------------
vim.o.laststatus = 0
vim.keymap.set("n", "<leader>e", function()
  vim.o.laststatus = vim.o.laststatus == 0 and 2 or 0
end, { desc = "Toggle status line" })

local function statusline_bufnr()
  local winid = tonumber(vim.g.statusline_winid)
  if winid and vim.api.nvim_win_is_valid(winid) then
    return vim.api.nvim_win_get_buf(winid)
  end

  return vim.api.nvim_get_current_buf()
end

function _G.nvim_diagnostic_statusline(bufnr)
  bufnr = bufnr or statusline_bufnr()
  local parts = {}
  local counts = vim.diagnostic.count(bufnr)
  local nvim_statusline_diagnostic_highlights = {
    [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
    [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
    [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
    [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
  }

  for _, item in ipairs({
    { severity = vim.diagnostic.severity.ERROR, label = "E" },
    { severity = vim.diagnostic.severity.WARN,  label = "W" },
    { severity = vim.diagnostic.severity.INFO,  label = "I" },
    { severity = vim.diagnostic.severity.HINT,  label = "H" },
  }) do
    local count = counts[item.severity]
    if count and count > 0 then
      local highlight = nvim_statusline_diagnostic_highlights[item.severity]
      table.insert(parts, ("%%#%s#%s:%d%%##"):format(highlight, item.label, count))
    end
  end

  return table.concat(parts, " ")
end

_G.statusline = _G.statusline or {}

_G.statusline.count_todos_in_open_buffers = function()
  local count = 0

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].buflisted then
      for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
        count = count + select(2, line:gsub("TODO", ""))
        count = count + select(2, line:gsub("FIXME", ""))
      end
    end
  end

  return count
end

_G.statusline.todo_count = function()
  local count = _G.statusline.count_todos_in_open_buffers()

  if count == 0 then
    return ""
  end

  return ("%%#DiagnosticSignHint#T:%d%%##"):format(count)
end


local statusline_todo_count = "%{%v:lua.statusline.todo_count()%}"
local statusline_diagnostics = "%{%v:lua.nvim_diagnostic_statusline()%}"
local statusline_position = "%l:%c %P"
local navic_breadcrumbs = "%{%v:lua.require'nvim-navic'.get_location()%}"

vim.o.statusline = table.concat({
  navic_breadcrumbs,
  "%=",
  statusline_diagnostics,
  " ",
  statusline_todo_count,
  " ",
  statusline_position,
})

-----------------------
---LSP
-----------------------

-- init.lua
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf }

    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "grr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "grn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "gca", vim.lsp.buf.code_action, opts)

    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or not client:supports_method("textDocument/formatting") then
      return
    end
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = opts.buffer,
      callback = function()
        vim.lsp.buf.format({
          bufnr = opts.buffer,
          async = false,
        })
      end,
    })
  end,
})

vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      runtime = { version = "LuaJIT" },
      workspace = {
        checkThirdParty = false,
        ignoreDir = { ".git", ".jj", ".direnv", "node_modules", "result", "nixos/home/result", "nixos/sys/result" },
        ignoreSubmodules = true,
        library = { vim.env.VIMRUNTIME .. "/lua" },
        maxPreload = 300,
        preloadFileSize = 100,
        useGitIgnore = true,
      },
      completion = {
        showWord = "Disable",
        workspaceWord = false,
      },
      telemetry = { enable = false },
    }
  },
})

vim.lsp.enable({
  "eslint",
  "phpactor",
  "vtsls",
  "lua_ls",
  "nixd",
  "scheme_langserver",
  "clangd",
})

vim.lsp.config('clangd', {
  cmd = { 'clangd' },
  filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
  root_markers = {
    '.clangd',
    'compile_commands.json',
    'compile_flags.txt',
    '.git',
    '.jj',
  },
})

-- LSP diagnostics
vim.diagnostic.config({ virtual_text = false, })

-- Rustacean
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


---------------------
-- Misc auto commands
---------------------

-- TODO keep or no keep?
-- clear highlights on insert
-- vim.api.nvim_create_autocmd("InsertEnter", {
--   pattern = "*",
--   callback = function()
--     vim.cmd([[match none]])
--   end,
-- })

-- restore cursor to last position
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- highlight whitespace at EOL
local group = vim.api.nvim_create_augroup("ExtraWhitespace", { clear = true })

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile", "InsertLeave" }, {
  group = group,
  pattern = "*",
  callback = function()
    vim.cmd([[match ExtraWhitespace /\s\+$/]])
  end,
})

vim.api.nvim_create_autocmd("InsertEnter", {
  group = group,
  pattern = "*",
  callback = function()
    vim.cmd([[match none]])
  end,
})

-- cursorline color and toggle
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
    -- weaker to stronger contrast for light -> 255..250 and for dark -> 232..241
    ctermbg = get_system_appearance() == "light" and 252 or 237,
  })

  local search_bg_color = get_system_appearance() == "light" and 230 or 101;
  vim.api.nvim_set_hl(0, "Search", { ctermbg = search_bg_color, })
  vim.api.nvim_set_hl(0, "CurSearch", { ctermbg = search_bg_color, })
end

apply_cursor_line_highlight()
vim.api.nvim_create_autocmd({ "ColorScheme", "FocusGained", "VimEnter" }, {
  callback = apply_cursor_line_highlight,
})

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


-----------------
-- Handy commands
-----------------

vim.api.nvim_create_user_command("ClearRegisters", function()
  local regs = [[abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-"*+]]

  for r in regs:gmatch(".") do
    pcall(vim.fn.setreg, r, {})
  end

  vim.fn.setreg("/", "")
  -- persist the cleared registers by calling wshada?
  -- vim.cmd("wshada!");
end, {})

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

vim.api.nvim_create_user_command("DeleteFile", delete_current_file, {
  desc = "Delete the file for the current buffer",
})

--

local function toggle_line_numbers()
  local enabled = not vim.wo.number
  vim.wo.number = enabled
  vim.wo.relativenumber = enabled
end

vim.keymap.set("n", "<leader>ll", toggle_line_numbers, { desc = "Toggle line numbers" })

--

local function toggle_cursor_line()
  vim.wo.cursorline = not vim.wo.cursorline
end
vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave" }, {
  pattern = "*",
  callback = function()
    toggle_cursor_line()
  end,
})
vim.keymap.set("n", "<leader>cl", toggle_cursor_line, { desc = "Toggle cursor line" })

--------------------------------------------------
-- Keymaps that aren't paired with functions above
--------------------------------------------------
local map = vim.keymap.set

map("n", "'", "`") -- make ' jump straight to mark's column

map("n", "\\wb", function()
  local folder = vim.fn.expand("~/code/blog/posts")
  local date = os.date("%Y-%m-%d")
  local seconds = os.time()
  local filename = string.format("%s/%s_%d.md", folder, date, seconds)
  vim.fn.mkdir(folder, "p")
  vim.cmd("edit " .. filename)
end, { desc = "Create new timestamped file" })

-- tmux navigator
vim.g.tmux_navigator_no_mappings = 1
map("n", "<M-h>", "<cmd>TmuxNavigateLeft<CR>")
map("n", "<M-j>", "<cmd>TmuxNavigateDown<CR>")
map("n", "<M-k>", "<cmd>TmuxNavigateUp<CR>")
map("n", "<M-l>", "<cmd>TmuxNavigateRight<CR>")

-- quickfix nav
map("n", "]q", "<cmd>cnext<CR>zz", { desc = "Next quickfix item", silent = true })
map("n", "[q", "<cmd>cprev<CR>zz", { desc = "Previous quickfix item", silent = true })
map("n", "]Q", "<cmd>clast<CR>zz", { desc = "Last quickfix item", silent = true })
map("n", "[Q", "<cmd>cfirst<CR>zz", { desc = "First quickfix item", silent = true })

-- loclist nav
map("n", "]l", "<cmd>lnext<CR>zz", { desc = "Next location-list item", silent = true })
map("n", "[l", "<cmd>lprev<CR>zz", { desc = "Previous location-list item", silent = true })
map("n", "]L", "<cmd>llast<CR>zz", { desc = "Last location-list item", silent = true })
map("n", "[L", "<cmd>lfirst<CR>zz", { desc = "First location-list item", silent = true })

map("n", "<leader>q", "<cmd>copen<CR>")
map("n", "<leader>Q", "<cmd>cclose<CR>")
map("n", "<leader>l", "<cmd>lopen<CR>")
map("n", "<leader>L", "<cmd>lclose<CR>")

-- via the primeagen
-- move visual blocks up and down
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")
-- cursor remains in place post J line join
map("n", "J", "mzJ`z")
-- keep various motions centered on page
-- not sure I like this... tbd
-- map("n", "n", "nzzzv")
-- map("n", "N", "Nzzzv")
-- map("n", "<C-d>", "<C-d>zz")
-- map("n", "<C-u>", "<C-u>zz")
-- map("n", "<C-f>", "<C-f>zz")
-- map("n", "<C-b>", "<C-b>zz")
-- map("n", "}", "}zz")
-- map("n", "{", "{zz")
-- map("n", "*", "*zzzv")
-- map("n", "#", "#zzzv")
-- map("n", "g*", "g*zzzv")
-- map("n", "g#", "g#zzzv")
-- map("n", "<C-o>", "<C-o>zz")
-- map("n", "<C-i>", "<C-i>zz")

-- avoid overwriting the yank register
map("x", "<leader>p", [["_dP]])
--map({ "n", "v" }, "<leader>d", [["_d]])
--map({ "n", "v" }, "<leader>c", [["_c]])

-- keep visual selection selected after indents
map("v", "<", "<gv")
map("v", ">", ">gv")

-- reselect the most recently pasted region
map("n", "gp", "`[v`]")

map("n", "<leader>y", function() require("yazi").toggle() end, { desc = "Yazi" })
map("n", "<leader>z", "zMzv", { desc = "Close all folds except current line", })
map("n", "<leader>Z", "zMzO", { desc = "Close all folds except current fold", })

-- delete without yanking
map("n", "x", [["_x]])
map("n", "X", [["_X]])

-- jump to recent buffer
map("n", "<leader><leader>", "<C-^>")

-- jj/git hunks (and lsp format on save the hunks stuff)
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

local function has_lsp_format_client(bufnr, method)
  return #vim.lsp.get_clients({ bufnr = bufnr, method = method }) > 0
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

local function lsp_format_buffer(bufnr)
  if has_lsp_format_client(bufnr, "textDocument/formatting") then
    vim.lsp.buf.format({ bufnr = bufnr })
  end
end

local function lsp_format_visual_selection(bufnr)
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  lsp_format_line_range(bufnr, start_line, end_line)
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


-- Obsidian
-- ----------

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
  -- ui = { enable = true, },
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
  -- templates = { folder = "templates" },
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
      vim.keymap.set("n", "<leader>o", ":Obsidian quick_switch<CR>", {
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

-- TODO this one doesn't seem to work
vim.keymap.set("n", "gd", "gdzt");

--- Github link copying
-- Git and diagnostics
-- TODO turn these into commands and not keybindings
--vim.keymap.set("n", "<leader>Gy", function()
--  require("gitlinker").get_buf_range_url("n")
--end, { desc = "Copy GitHub link" })
--vim.keymap.set("v", "<leader>Gy", function()
--  require("gitlinker").get_buf_range_url("v")
--end, { desc = "Copy GitHub link (selection)" })
--vim.keymap.set("n", "<leader>Go", function()
--  require("gitlinker").get_buf_range_url("n", { action_callback = require("gitlinker.actions").open_in_browser })
--end, { desc = "Open GitHub link" })
--vim.keymap.set("v", "<leader>Go", function()
--  require("gitlinker").get_buf_range_url("v", { action_callback = require("gitlinker.actions").open_in_browser })
--end, { desc = "Open GitHub link (selection)" })
