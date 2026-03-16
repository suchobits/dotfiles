-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local tmux = require("shared.tmux")

-- Build tool detection
local function find_root_file(patterns)
  return vim.fs.find(patterns, { upward = true, path = vim.fn.expand("%:p:h") })[1]
end

local function is_gradle()
  return find_root_file({ "build.gradle", "build.gradle.kts" }) ~= nil
end

local function is_maven()
  return find_root_file({ "pom.xml" }) ~= nil
end

-- Spring Boot run
vim.keymap.set("n", "<leader>rs", function()
  if is_gradle() then
    tmux.run("./gradlew bootRun")
  elseif is_maven() then
    tmux.run("./mvnw spring-boot:run")
  else
    vim.notify("No Gradle or Maven project found", vim.log.levels.WARN)
  end
end, { desc = "Spring Boot Run" })

-- Run all tests
vim.keymap.set("n", "<leader>rt", function()
  if is_gradle() then
    tmux.run("./gradlew test")
  elseif is_maven() then
    tmux.run("./mvnw test")
  else
    vim.notify("No Gradle or Maven project found", vim.log.levels.WARN)
  end
end, { desc = "Run All Tests" })

-- Continuous tests (TDD mode)
vim.keymap.set("n", "<leader>rc", function()
  if is_gradle() then
    tmux.run("./gradlew test --continuous")
  elseif is_maven() then
    tmux.run("./mvnw test")
    vim.notify("Maven has no native --continuous; re-run with <leader>rt", vim.log.levels.INFO)
  else
    vim.notify("No Gradle or Maven project found", vim.log.levels.WARN)
  end
end, { desc = "Continuous Tests (TDD)" })

-- Restart LSP (useful when KLS crashes on Spring types)
vim.keymap.set("n", "<leader>cL", "<cmd>LspRestart<cr>", { desc = "Restart LSP" })

-- Run tests for current file
vim.keymap.set("n", "<leader>rf", function()
  local class = vim.fn.expand("%:t:r") -- filename without extension
  if is_gradle() then
    tmux.run("./gradlew test --tests '*" .. class .. "'")
  elseif is_maven() then
    tmux.run("./mvnw -Dtest=" .. class .. " test")
  else
    vim.notify("No Gradle or Maven project found", vim.log.levels.WARN)
  end
end, { desc = "Run Tests (current file)" })

-- Hurl: run current file
vim.keymap.set("n", "<leader>rh", function()
  local file = vim.api.nvim_buf_get_name(0)
  if not file:match("%.hurl$") then
    vim.notify("Not a .hurl file", vim.log.levels.WARN)
    return
  end
  tmux.run("hurl --test " .. vim.fn.shellescape(file), { beside = true })
end, { desc = "Run Hurl Test (current)" })

-- Hurl: pick file to run
vim.keymap.set("n", "<leader>rH", function()
  local root = vim.fn.getcwd()
  local files = vim.fn.glob(root .. "/**/*.hurl", false, true)
  if #files == 0 then
    vim.notify("No .hurl files found", vim.log.levels.WARN)
    return
  end
  local relative = vim.tbl_map(function(f)
    return f:sub(#root + 2)
  end, files)
  vim.ui.select(relative, { prompt = "Run Hurl test:" }, function(choice)
    if not choice then
      return
    end
    tmux.run("hurl --test " .. vim.fn.shellescape(root .. "/" .. choice), { beside = true })
  end)
end, { desc = "Run Hurl Test (pick)" })
