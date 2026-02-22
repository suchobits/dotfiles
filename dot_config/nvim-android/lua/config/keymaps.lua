-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function run_in_tmux(cmd, opts)
  opts = opts or {}
  if not vim.env.TMUX then
    vim.cmd((opts.vertical and "vsplit" or "split") .. " | terminal " .. cmd)
    return
  end
  local root = vim.fn.getcwd()
  local split_args = opts.beside
    and string.format("-h -t {bottom} -c %s", vim.fn.shellescape(root))
    or string.format("-v -c %s", vim.fn.shellescape(root))
  local pane_id = vim.fn.system("tmux split-window " .. split_args .. " -P -F '#{pane_id}'"):gsub("%s+", "")
  vim.fn.system(string.format("tmux send-keys -t %s %s Enter", pane_id, vim.fn.shellescape(cmd)))
end

-- Install debug APK on device/emulator
vim.keymap.set("n", "<leader>rs", function()
  run_in_tmux("./gradlew installDebug")
end, { desc = "Install Debug APK" })

-- Assemble debug APK (build only)
vim.keymap.set("n", "<leader>ra", function()
  run_in_tmux("./gradlew assembleDebug")
end, { desc = "Assemble Debug APK" })

-- Run all tests
vim.keymap.set("n", "<leader>rt", function()
  run_in_tmux("./gradlew test")
end, { desc = "Run All Tests" })

-- Continuous tests (TDD mode)
vim.keymap.set("n", "<leader>rc", function()
  run_in_tmux("./gradlew test --continuous")
end, { desc = "Continuous Tests (TDD)" })

-- Restart LSP (useful when KLS crashes)
vim.keymap.set("n", "<leader>cL", "<cmd>LspRestart<cr>", { desc = "Restart LSP" })

-- Run tests for current file
vim.keymap.set("n", "<leader>rf", function()
  local class = vim.fn.expand("%:t:r")
  run_in_tmux("./gradlew test --tests '*" .. class .. "'")
end, { desc = "Run Tests (current file)" })
