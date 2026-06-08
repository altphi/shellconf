require("mini.surround").setup({
  custom_surroundings = {
    [')'] = { output = { left = '(', right = ')' } },
    ['('] = { output = { left = '(', right = ')' } },
    ['['] = { output = { left = '[', right = ']' } },
    [']'] = { output = { left = '[', right = ']' } },
    ['{'] = { output = { left = '{', right = '}' } },
    ['}'] = { output = { left = '{', right = '}' } },
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
