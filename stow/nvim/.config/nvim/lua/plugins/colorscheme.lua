-- Vira Carbon - local colorscheme living in <config>/vira, loaded by lazy via `dir`.
return {
  {
    dir = vim.fn.stdpath("config") .. "/vira",
    name = "vira-carbon",
    lazy = false,
    priority = 1000,
  },
  -- LazyVim owns the `:colorscheme` call, so hand it the name rather than setting it here.
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "vira-carbon",
    },
  },
}
