-- shared modules (run_in_tmux, etc.)
local shared_path = vim.fn.stdpath("config"):gsub("[^/]+$", "nvim-shared")
vim.opt.rtp:prepend(shared_path)
package.path = shared_path .. "/lua/?.lua;" .. shared_path .. "/lua/?/init.lua;" .. package.path

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
