-- shared modules (run_in_tmux, etc.)
vim.opt.rtp:prepend(vim.fn.stdpath("config"):gsub("[^/]+$", "nvim-shared"))

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
