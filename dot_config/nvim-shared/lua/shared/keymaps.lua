-- Shared keymaps applied to all nvim-* configs
vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- Shared autocmds
require("shared.autocmds")
