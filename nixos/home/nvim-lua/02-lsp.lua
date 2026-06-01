require("lazydev").setup({})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local opts = { buf = ev.buf, silent = true }
    local hover_opts = {
      border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
      max_width = 100,
    }
    vim.keymap.set("n", "K", function()
      vim.lsp.buf.hover(hover_opts)
    end, opts)
    vim.keymap.set("n", "<C-k>", function()
      vim.lsp.buf.signature_help({ border = "double" })
    end, opts)
    vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format, vim.tbl_extend("force", opts, { desc = "Format buffer" }))
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

vim.diagnostic.config({
  virtual_text = false,
  float = {
    border = "rounded",
    pad_top = 1,
    pad_bottom = 1,
    format = function(d)
      return " " .. d.message .. " "
    end,
  },
})
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, { focus = false })
  end,
})

local lsp_format_on_save_filetypes = {
  javascript = true,
  javascriptreact = true,
  lua = true,
  nix = true,
  php = true,
  r = true,
  rmd = true,
  rust = true,
  scheme = true,
  typescript = true,
  typescriptreact = true,
}

vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("LspFormatOnSave", { clear = true }),
  pattern = "*",
  callback = function(ev)
    if not lsp_format_on_save_filetypes[vim.bo[ev.buf].filetype] then
      return
    end

    if #vim.lsp.get_clients({ bufnr = ev.buf, method = "textDocument/formatting" }) > 0 then
      vim.lsp.buf.format({ bufnr = ev.buf })
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

    local formatted = vim.fn.systemlist(
      { "beautysh", "--indent-size", "2", "-" },
      vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false)
    )
    if vim.v.shell_error == 0 then
      vim.api.nvim_buf_set_lines(ev.buf, 0, -1, false, formatted)
    else
      vim.notify(table.concat(formatted, "\n"), vim.log.levels.ERROR, { title = "beautysh" })
    end
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
vim.lsp.config("ts_ls", {
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
vim.lsp.config("r_language_server", {})
vim.lsp.config("nixd", {})
vim.lsp.config("scheme_langserver", { filetypes = { "scheme" } })
vim.lsp.enable({
  "eslint",
  "phpactor",
  "ts_ls",
  "lua_ls",
  "r_language_server",
  "nixd",
  "scheme_langserver",
})
