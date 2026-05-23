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
