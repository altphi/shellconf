return {
  "Olical/conjure",
  ft = { "scheme", "racket", "clojure", "fennel", "lisp" },
  dependencies = { "PaterJason/cmp-conjure" },
  config = function()
    vim.g["conjure#mapping#prefix"] = "<leader>c"
  end,
}
