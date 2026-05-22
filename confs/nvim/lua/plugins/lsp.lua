return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        local opts = { buffer = ev.buf, noremap = true, silent = true }
        --vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts) -- Go to definition
        --vim.keymap.set("n", "K", vim.lsp.buf.hover, opts) -- Show hover info
        --vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts) -- Code actions
        --vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- Rename symbol
        --vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts) -- Show diagnostics
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover({ border = "double" }) end, opts)
        vim.keymap.set("n", "<C-k>", function() vim.lsp.buf.signature_help({ border = "double" }) end, opts)
        vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format, { desc = 'Format buffer' })
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    end,
    })

      -- Add padding inside floating previews (hover, signature help)
      local orig_open_floating_preview = vim.lsp.util.open_floating_preview
      function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.pad_top = opts.pad_top or 1
        opts.pad_bottom = opts.pad_bottom or 1
        contents = vim.tbl_map(function(line) return " " .. line .. " " end, contents)
        return orig_open_floating_preview(contents, syntax, opts, ...)
      end

      -- Optional: Diagnostics styling
      vim.diagnostic.config({
        virtual_text = false,
        float = {
          border = "rounded",
          pad_top = 1,
          pad_bottom = 1,
          format = function(d) return " " .. d.message .. " " end,
        },
      })
      vim.api.nvim_create_autocmd("CursorHold", {
        callback = function()
          vim.diagnostic.open_float(nil, { focus = false })
        end,
      })
      -- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#1f2335" })
      -- vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#7aa2f7", bg = "#1f2335" })

      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
        vim.lsp.handlers.hover,
        {
          border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
          max_width = 100,
        }
      )

      require("mason-lspconfig").setup({
        ensure_installed = { "eslint", "phpactor", "ts_ls" },
        handlers = {
          -- Default handler (for all servers without custom config)
          function(server_name)
            require("lspconfig")[server_name].setup({})
          end,

          -- Custom config for phpactor
          phpactor = function()
            require("lspconfig").phpactor.setup({
              filetypes = { "php" },
              init_options = {
                ["language_server_phpstan.enabled"] = false,
                ["language_server_psalm.enabled"] = false,
              },
            })
          end,

          -- Custom config for ts_ls
          ts_ls = function()
            require("lspconfig").ts_ls.setup({
              filetypes = {
                "typescript",
                "typescriptreact",
                "javascript",
                "javascriptreact",
              },
            })
          end,

          lua_ls = function()
            require("lspconfig").lua_ls.setup({
              settings = {
                Lua = {
                  runtime = {
                    version = 'LuaJIT', -- Neovim uses LuaJIT
                  },
                  diagnostics = {
                    globals = { 'vim' }, -- Recognize Neovim's `vim` global
                  },
                  workspace = {
                    library = vim.api.nvim_get_runtime_file("", true),
                    checkThirdParty = false,
                  },
                  telemetry = {
                    enable = false,
                  }
                }
              }
            })
          end,

          r_ls = function()
            require("lspconfig").r_language_server.setup({
              on_attach = function(client, bufnr)
                --local opts = { noremap=true, silent=true, buffer=bufnr }
                --vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                --vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
              end,
            })
          end,
        },
      })

      -- Scheme LSP (not available through Mason)
      vim.lsp.config('scheme_langserver', {
        filetypes = { "scheme" },
      })
      vim.lsp.enable('scheme_langserver')
    end
  },
  {
    "neovim/nvim-lspconfig",
  },
}

