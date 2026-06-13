return {
  std = "luajit",
  cache = false,
  self = false,

  codes = true,
  ranges = true,
  max_line_length = false,

  ignore = {
    "212/_.*", -- unused argument, for vars with "_" prefix
    "214",     -- used variable with unused hint ("_" prefix)
    "431",     -- shadowing an upvalue
  },

  globals = {
    "vim.b",
    "vim.bo",
    "vim.g",
    "vim.lsp.util",
    "vim.o",
    "vim.opt",
    "vim.wo",
  },

  read_globals = {
    "_",

    "vim.api",
    "vim.cmd",
    "vim.defer_fn",
    "vim.diagnostic",
    "vim.env",
    "vim.fn",
    "vim.fs",
    "vim.keymap",
    "vim.log",
    "vim.lsp",
    "vim.notify",
    "vim.notify_once",
    "vim.pesc",
    "vim.schedule",
    "vim.split",
    "vim.system",
    "vim.tbl_contains",
    "vim.tbl_deep_extend",
    "vim.tbl_extend",
    "vim.tbl_map",
    "vim.treesitter",
    "vim.trim",
    "vim.ui",
    "vim.uv",
    "vim.v",
  },
}
