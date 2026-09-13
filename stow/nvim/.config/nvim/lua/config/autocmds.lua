-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Keep the compiled spell file (`spell/en.utf-8.add.spl`) in sync with the
-- tracked word list. Neovim rebuilds it after `zg`, but not for the list
-- shipped in the repo or edited by hand, so do it here: once on startup
-- when the `.spl` is missing or stale, and after any save of the `.add`
-- (see README "Markdown"). The `.spl` itself is gitignored.
local function compile_spell(path)
  local spl = path .. ".spl"
  local fresh = vim.fn.filereadable(spl) == 1 and vim.fn.getftime(spl) >= vim.fn.getftime(path)
  if vim.fn.filereadable(path) == 1 and not fresh then
    vim.cmd("silent mkspell! " .. vim.fn.fnameescape(path))
  end
end

compile_spell(vim.fn.stdpath("config") .. "/spell/en.utf-8.add")

vim.api.nvim_create_autocmd("BufWritePost", {
  group = vim.api.nvim_create_augroup("mkspell_on_save", { clear = true }),
  pattern = "*/spell/*.add",
  callback = function(ev)
    compile_spell(ev.file)
  end,
})
