{ pkgs, ... }:

let
  treesitter = pkgs.vimPlugins.nvim-treesitter.withPlugins (p: with p; [
    bash
    javascript
    latex
    lua
    markdown
    markdown_inline
    nix
    php
    r
    rust
    scheme
    typescript
    vim
  ]);
in
{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraPackages = with pkgs; [
      akkuPackages.scheme-langserver
      fd
      gh
      git
      lazygit
      lua-language-server
      nixd
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted
      nodejs_24
      phpactor
      rPackages.languageserver
      ripgrep
      tree-sitter
    ];

    extraPlugins = with pkgs.vimPlugins; [
      aerial-nvim
      barbar-nvim
      bullets-vim
      cmp-buffer
      cmp-conjure
      cmp-nvim-lsp
      cmp-path
      cmp_luasnip
      conjure
      gitlinker-nvim
      gitsigns-nvim
      grug-far-nvim
      lazydev-nvim
      lazygit-nvim
      luasnip
      mason-nvim
      mason-nvim-dap-nvim
      mini-surround
      nvim-cmp
      nvim-dap
      nvim-dap-ui
      nvim-dap-virtual-text
      nvim-lspconfig
      nvim-nio
      nvim-treesitter-context
      nvim-treesitter-textobjects
      nvim-web-devicons
      obsidian-nvim
      plenary-nvim
      rustaceanvim
      telescope-file-browser-nvim
      telescope-fzf-native-nvim
      telescope-nvim
      treesitter
      trouble-nvim
      vim-tmux-navigator
    ];

    extraConfigLua = ''
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      vim.g.mapleader = " "
      vim.g.maplocalleader = ","

      vim.opt.number = false
      vim.opt.relativenumber = false
      vim.opt.tabstop = 2
      vim.opt.shiftwidth = 2
      vim.opt.expandtab = true
      vim.opt.clipboard = "unnamedplus"
      vim.opt.ignorecase = true
      vim.opt.linespace = 2
      vim.opt.conceallevel = 2
      vim.opt.autowriteall = true
      vim.opt.signcolumn = "yes"
      vim.opt.termguicolors = false
      vim.opt.scrolloff = 5
      vim.opt.guicursor = {
        "n-v-c:block",
        "i-ci:block-blinkwait700-blinkon400-blinkoff250",
        "r-cr:block-blinkwait700-blinkon400-blinkoff250",
      }
      vim.opt.diffopt:append({
        "iwhite",
        "algorithm:histogram",
        "indent-heuristic",
        "context:3",
      })
      vim.opt.wrap = false
      vim.opt.linebreak = true
      vim.opt.textwidth = 0
      vim.opt.sidescrolloff = 5
      vim.opt.foldmethod = "expr"
      vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
      vim.opt.foldlevel = 99
      vim.opt.updatetime = 200
      vim.opt.swapfile = false
      vim.opt.undofile = true
      vim.opt.undodir = vim.fn.stdpath("data") .. "/.nvim-undo//"
      vim.fn.mkdir(vim.fn.stdpath("cache"), "p")

      vim.cmd("set title")

      vim.api.nvim_set_hl(0, "DiffAdd", { fg = "#a6e3a1", bg = "NONE" })
      vim.api.nvim_set_hl(0, "DiffDelete", { fg = "#f38ba8", bg = "NONE" })
      vim.api.nvim_set_hl(0, "DiffChange", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "DiffText", { bg = "#45475a" })

      local autosave_timer = vim.uv.new_timer()
      autosave_timer:start(15000, 15000, vim.schedule_wrap(function()
        if not vim.bo.modified then
          return
        end
        vim.cmd("silent! wall")
      end))

      local function open_vault_file(name)
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

      vim.api.nvim_create_autocmd("BufReadPost", {
        callback = function()
          local mark = vim.api.nvim_buf_get_mark(0, '"')
          local lcount = vim.api.nvim_buf_line_count(0)
          if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
          end
        end,
      })

      vim.api.nvim_set_hl(0, "ExtraWhitespace", { bg = "red", ctermbg = "red" })
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

      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*",
        callback = function()
          local mode = vim.api.nvim_get_mode().mode
          if mode ~= "i" and vim.bo.filetype ~= "markdown" then
            local pos = vim.api.nvim_win_get_cursor(0)
            vim.cmd("%s/\\s\\+$//e")
            pcall(vim.api.nvim_win_set_cursor, 0, pos)
          end
        end,
      })

      vim.api.nvim_create_user_command("RemoveTrailingWhitespace", "%s/\\s\\+$//e", {})
      vim.api.nvim_create_user_command("BlameToggle", "Gitsigns blame", {})
      vim.api.nvim_create_user_command("LineNumbersToggle", function()
        vim.o.number = not vim.o.number
      end, {})
      vim.api.nvim_create_user_command("DeleteFile", delete_current_file, {
        desc = "Delete the file for the current buffer",
      })

      vim.keymap.set("n", "<leader>ll", function()
        vim.wo.number = true
        vim.defer_fn(function()
          vim.wo.number = false
        end, 3000)
      end)
      vim.keymap.set("n", "\\wb", function()
        local folder = vim.fn.expand("~/code/blog/posts")
        local date = os.date("%Y-%m-%d")
        local seconds = os.time()
        local filename = string.format("%s/%s_%d.md", folder, date, seconds)
        vim.fn.mkdir(folder, "p")
        vim.cmd("edit " .. filename)
      end, { desc = "Create new timestamped file" })
      vim.keymap.set("n", "<C-s>", "<cmd>w<CR>", { desc = "Save file" })
      vim.keymap.set("i", "<C-s>", "<Esc><cmd>w<CR>a", { desc = "Save file" })
      vim.keymap.set("n", "<A-Down>", "<cmd>m .+1<CR>==", { desc = "Move line down" })
      vim.keymap.set("n", "<A-Up>", "<cmd>m .-2<CR>==", { desc = "Move line up" })
      vim.keymap.set("i", "<A-Down>", "<Esc><cmd>m .+1<CR>==gi", { desc = "Move line down" })
      vim.keymap.set("i", "<A-Up>", "<Esc><cmd>m .-2<CR>==gi", { desc = "Move line up" })
      vim.keymap.set("v", "<A-Down>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
      vim.keymap.set("v", "<A-Up>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
      vim.keymap.set("x", "<leader>s", [[:s/\%V]])

      require("lazydev").setup({})

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local opts = { buffer = ev.buf, noremap = true, silent = true }
          vim.keymap.set("n", "K", function()
            vim.lsp.buf.hover({ border = "double" })
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
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
        max_width = 100,
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

      require("nvim-treesitter.configs").setup({
        indent = { enable = true },
        highlight = { enable = true },
        incremental_selection = { enable = true },
        textobjects = {
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]m"] = { query = "@function.outer", desc = "Next function start" },
              ["]]"] = { query = "@class.outer", desc = "Next class start" },
              ["]o"] = { query = "@loop.outer", desc = "Next loop start" },
              ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
              ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
            },
            goto_next_end = {
              ["]M"] = "@function.outer",
              ["]["] = "@class.outer",
            },
            goto_previous_start = {
              ["[m"] = "@function.outer",
              ["[["] = "@class.outer",
            },
            goto_previous_end = {
              ["[M"] = "@function.outer",
              ["[]"] = "@class.outer",
            },
          },
        },
      })
      local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")
      vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
      vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)

      require("treesitter-context").setup({
        enable = true,
        max_lines = 3,
        separator = "─",
      })
      vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "#2e2e3e" })
      vim.api.nvim_set_hl(0, "TreesitterContextSeparator", { fg = "#555577" })

      local function telescope_grep_in_directory()
        require("telescope.builtin").find_files({
          prompt_title = "Select a directory to grep",
          find_command = { "fd", "--type", "d", "--hidden", "--exclude", ".git" },
          attach_mappings = function(_, map)
            map("i", "<CR>", function(prompt_bufnr)
              local selection = require("telescope.actions.state").get_selected_entry()
              require("telescope.actions").close(prompt_bufnr)
              require("telescope.builtin").live_grep({
                cwd = selection.path,
                prompt_title = "Grep in " .. selection.path,
              })
            end)
            return true
          end,
        })
      end

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
        },
      })
      telescope.load_extension("fzf")
      telescope.load_extension("file_browser")

      vim.keymap.set("n", "<leader>ee", ":Telescope file_browser<CR>", { desc = "File browser with preview" })
      vim.keymap.set("n", "<leader>ef", ":Telescope file_browser path=%:p:h select_buffer=true<CR>", { desc = "File browser focusing current file" })
      vim.api.nvim_create_user_command("E", "Telescope file_browser path=%:p:h select_buffer=true", {})
      vim.api.nvim_create_user_command("Explore", "Telescope file_browser path=%:p:h select_buffer=true", {})

      local builtin = require("telescope.builtin")
      local find_files = function()
        builtin.find_files({
          hidden = true,
          find_command = { "fd", "--hidden", "--exclude", ".git" },
        })
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
      vim.keymap.set("n", "<leader>f", find_files, { desc = "Telescope: Find files (including hidden)" })
      vim.keymap.set("n", "<leader>g", builtin.live_grep, { desc = "Telescope: Live grep" })
      vim.keymap.set("n", "<leader>b", builtin.buffers, { desc = "Telescope: Buffers" })
      vim.keymap.set("n", "<leader>s", builtin.treesitter, { desc = "Search Tree-sitter symbols" })
      vim.keymap.set("n", "<leader>?", ":Telescope keymaps<CR>", { silent = true })
      vim.keymap.set("n", "<leader>of", ":Telescope oldfiles only_cwd=true<CR>", { silent = true })
      vim.keymap.set("n", "<leader>dg", telescope_grep_in_directory, { desc = "Telescope live_grep in selected directory" })
      vim.keymap.set("n", "<leader>dd", "<cmd>Telescope diagnostics<CR>", { desc = "Telescope: diagnostics" })
      vim.keymap.set("n", "<leader>rr", function()
        builtin.lsp_references({ include_declaration = false, include_current_line = false })
      end, { desc = "Telescope: lsp_references (usages only)" })
      vim.keymap.set("n", "<leader>ic", builtin.lsp_incoming_calls, { desc = "Telescope: lsp_incoming_calls" })
      vim.keymap.set("n", "<leader>oc", builtin.lsp_outgoing_calls, { desc = "Telescope: lsp_outgoing_calls" })

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

      require("aerial").setup({
        backends = { "treesitter", "markdown" },
        filter_kind = {
          "Class",
          "Enum",
          "Interface",
          "Struct",
          "Module",
          "Method",
          "Function",
        },
        post_parse_symbol = function(bufnr, item, _ctx)
          local ft = vim.bo[bufnr].filetype
          if ft == "markdown" then
            return true
          end
          return not item.parent or item.kind == "Function" or item.kind == "Method"
        end,
      })
      vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle<CR>", { desc = "Toggle Aerial outline" })

      vim.g.bullets_enabled_file_types = { "markdown" }
      vim.g.bullets_enable = 1
      vim.g.bullets_checkbox_markers = " ~x"
      vim.g.bullets_outline_levels = { "std-", "std*", "std+", "num", "rom", "abc", "ROM" }
      vim.g.bullets_set_mappings = 0

      vim.g["conjure#mapping#prefix"] = "<leader>c"

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
        templates = { subdir = "templates" },
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
          enter_note = function()
            vim.keymap.set("n", "<leader>q", ":Obsidian quick_switch<CR>", { buffer = true, desc = "Obsidian: Quick Switch" })
            vim.keymap.set("n", "<C-Space>", ":Obsidian toggle_checkbox<CR>", { buffer = true, desc = "Obsidian: Toggle Checkbox" })
            vim.keymap.set("n", "<CR>", ":Obsidian follow_link<CR>", { buffer = true, desc = "Obsidian: Follow Link" })
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

      require("nvim-dap-virtual-text").setup()
      require("mason").setup()
      require("mason-nvim-dap").setup({
        ensure_installed = { "js", "php", "r", "codelldb" },
        automatic_installation = false,
      })
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
      dap.configurations.javascript = {
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch file",
          program = "''${file}",
          cwd = vim.fn.getcwd(),
          sourceMaps = true,
          runtimeExecutable = "node",
          console = "integratedTerminal",
          internalConsoleOptions = "neverOpen",
        },
      }
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
          program = "''${file}",
          cwd = vim.fn.getcwd(),
          console = "integratedTerminal",
        },
      }

      require("gitlinker").setup({})
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
      vim.keymap.set("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", { desc = "Trouble: Buffer Diagnostics" })
      vim.keymap.set("n", "<leader>xs", "<cmd>Trouble symbols toggle focus=false<CR>", { desc = "Trouble: Symbols (LSP)" })
      vim.keymap.set("n", "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<CR>", { desc = "Trouble: LSP Definitions / References" })
      vim.keymap.set("n", "<leader>qq", "<cmd>Trouble qflist toggle<CR>", { desc = "Trouble: Quickfix List" })
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
            opts.buffer = bufnr
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

      require("mini.surround").setup({
        custom_surroundings = nil,
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

      vim.g.barbar_auto_setup = false
      vim.api.nvim_set_hl(0, "BufferCurrent", { ctermfg = 15, ctermbg = 0 })
      vim.api.nvim_set_hl(0, "BufferCurrentMod", { ctermfg = 15, ctermbg = 0 })
      vim.api.nvim_set_hl(0, "BufferCurrentIcon", { ctermfg = 11 })
      vim.api.nvim_set_hl(0, "BufferInactive", { ctermfg = 7 })
      vim.api.nvim_set_hl(0, "BufferInactiveMod", { ctermfg = 8, ctermbg = 0 })
      vim.api.nvim_set_hl(0, "BufferInactiveIcon", { ctermfg = 8 })
      require("barbar").setup({
        animation = false,
        preset = "default",
        icons = { filetype = { enabled = false } },
      })
      vim.keymap.set("n", "<C-p>", "<Cmd>BufferPrevious<CR>", { desc = "Buffer: Previous" })
      vim.keymap.set("n", "<C-n>", "<Cmd>BufferNext<CR>", { desc = "Buffer: Next" })
      vim.keymap.set("n", "<A-1>", "<Cmd>BufferGoto 1<CR>", { desc = "Buffer: Go to 1" })
      vim.keymap.set("n", "<A-2>", "<Cmd>BufferGoto 2<CR>", { desc = "Buffer: Go to 2" })
      vim.keymap.set("n", "<A-3>", "<Cmd>BufferGoto 3<CR>", { desc = "Buffer: Go to 3" })
      vim.keymap.set("n", "<A-4>", "<Cmd>BufferGoto 4<CR>", { desc = "Buffer: Go to 4" })
      vim.keymap.set("n", "<A-5>", "<Cmd>BufferGoto 5<CR>", { desc = "Buffer: Go to 5" })
      vim.keymap.set("n", "<A-6>", "<Cmd>BufferGoto 6<CR>", { desc = "Buffer: Go to 6" })
      vim.keymap.set("n", "<A-7>", "<Cmd>BufferGoto 7<CR>", { desc = "Buffer: Go to 7" })
      vim.keymap.set("n", "<A-8>", "<Cmd>BufferGoto 8<CR>", { desc = "Buffer: Go to 8" })
      vim.keymap.set("n", "<A-9>", "<Cmd>BufferGoto 9<CR>", { desc = "Buffer: Go to 9" })
      vim.keymap.set("n", "<A-0>", "<Cmd>BufferLast<CR>", { desc = "Buffer: Last" })
      vim.keymap.set("n", "<A-p>", "<Cmd>BufferPin<CR>", { desc = "Buffer: Pin" })
      vim.keymap.set("n", "<A-w>", "<Cmd>BufferClose<CR>", { desc = "Buffer: Close" })
      vim.keymap.set("n", "<C-s-p>", "<Cmd>BufferPickDelete<CR>", { desc = "Buffer: Pick Delete" })
      vim.keymap.set("n", "<Space>bb", "<Cmd>BufferOrderByBufferNumber<CR>", { desc = "Buffer: Order by number" })
      vim.keymap.set("n", "<Space>bn", "<Cmd>BufferOrderByName<CR>", { desc = "Buffer: Order by name" })
      vim.keymap.set("n", "<Space>bd", "<Cmd>BufferOrderByDirectory<CR>", { desc = "Buffer: Order by directory" })
      vim.keymap.set("n", "<Space>bl", "<Cmd>BufferOrderByLanguage<CR>", { desc = "Buffer: Order by language" })
      vim.keymap.set("n", "<Space>bw", "<Cmd>BufferOrderByWindowNumber<CR>", { desc = "Buffer: Order by window" })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "rust",
        callback = function(ev)
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
              local is_binary = pid and (cmdline:find("target/debug/" .. name, 1, true) or cmdline:find("target/release/" .. name, 1, true))
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
          end, { desc = "Rust: Launch debuggable", buffer = ev.buf })
          vim.keymap.set("n", "<leader>dA", attach_to_running, { desc = "Rust: Attach to running process", buffer = ev.buf })
        end,
      })

      vim.g.tmux_navigator_no_mappings = 1
      vim.keymap.set("n", "<M-h>", "<cmd>TmuxNavigateLeft<CR>")
      vim.keymap.set("n", "<M-j>", "<cmd>TmuxNavigateDown<CR>")
      vim.keymap.set("n", "<M-k>", "<cmd>TmuxNavigateUp<CR>")
      vim.keymap.set("n", "<M-l>", "<cmd>TmuxNavigateRight<CR>")
    '';
  };
}
