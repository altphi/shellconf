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

--vim.lsp.config("eslint", {})
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
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = { enable = false },
    },
  },
})
vim.lsp.config("nixd", {})
vim.lsp.config("scheme_langserver", { filetypes = { "scheme" } })
vim.lsp.enable({
  -- "eslint",
  "phpactor",
  "vtsls",
  "lua_ls",
  "nixd",
  "scheme_langserver",
})
