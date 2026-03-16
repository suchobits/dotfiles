-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local tmux = require("shared.tmux")

-- === Run ===
vim.keymap.set("n", "<leader>rr", function()
  tmux.run("go run .")
end, { desc = "Go Run (.)" })

vim.keymap.set("n", "<leader>rf", function()
  local file = vim.fn.expand("%:t")
  tmux.run("go run " .. file)
end, { desc = "Go Run (current file)" })

vim.keymap.set("n", "<leader>rb", function()
  tmux.run("go build ./...")
end, { desc = "Go Build" })

-- === Tests (tmux) ===
vim.keymap.set("n", "<leader>rt", function()
  tmux.run("go test ./...")
end, { desc = "Go Test (all)" })

vim.keymap.set("n", "<leader>rv", function()
  tmux.run("go test -v ./...")
end, { desc = "Go Test -v (verbose)" })

vim.keymap.set("n", "<leader>rc", function()
  local func = vim.fn.search([[func \(Test\|Benchmark\)\w\+]], "bcnW")
  if func == 0 then
    vim.notify("No test function found", vim.log.levels.WARN)
    return
  end
  local line = vim.fn.getline(func)
  local name = line:match("func%s+(Test%w+)") or line:match("func%s+(Benchmark%w+)")
  if name then
    tmux.run("go test -v -run " .. name .. " ./...")
  end
end, { desc = "Go Test (at cursor)" })

-- === Gopher.nvim (code gen) ===
vim.keymap.set("n", "<leader>cie", "<cmd>GoIfErr<cr>", { desc = "Generate if err" })
vim.keymap.set("n", "<leader>cit", "<cmd>GoTagAdd json<cr>", { desc = "Add json tags" })
vim.keymap.set("n", "<leader>ciT", "<cmd>GoTagRm json<cr>", { desc = "Remove json tags" })
vim.keymap.set("n", "<leader>cig", "<cmd>GoGenerate<cr>", { desc = "Go Generate" })
vim.keymap.set("n", "<leader>cic", "<cmd>GoCmt<cr>", { desc = "Generate doc comment" })

-- === LSP ===
vim.keymap.set("n", "<leader>cL", "<cmd>LspRestart<cr>", { desc = "Restart LSP" })
