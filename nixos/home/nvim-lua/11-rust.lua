vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function(ev)
    local dap = require("dap")
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
