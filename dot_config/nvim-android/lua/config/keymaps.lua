-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
require("shared.keymaps")

local tmux = require("shared.tmux")

-- Install debug APK on device/emulator
vim.keymap.set("n", "<leader>rs", function()
  tmux.run("./gradlew installDebug")
end, { desc = "Install Debug APK" })

-- Assemble debug APK (build only)
vim.keymap.set("n", "<leader>ra", function()
  tmux.run("./gradlew assembleDebug")
end, { desc = "Assemble Debug APK" })

-- Run all tests
vim.keymap.set("n", "<leader>rt", function()
  tmux.run("./gradlew test")
end, { desc = "Run All Tests" })

-- Continuous tests (TDD mode)
vim.keymap.set("n", "<leader>rc", function()
  tmux.run("./gradlew test --continuous")
end, { desc = "Continuous Tests (TDD)" })

-- Restart LSP (useful when KLS crashes)
vim.keymap.set("n", "<leader>cL", "<cmd>LspRestart<cr>", { desc = "Restart LSP" })

-- Run tests for current file
vim.keymap.set("n", "<leader>rf", function()
  local class = vim.fn.expand("%:t:r")
  tmux.run("./gradlew test --tests '*" .. class .. "'")
end, { desc = "Run Tests (current file)" })
