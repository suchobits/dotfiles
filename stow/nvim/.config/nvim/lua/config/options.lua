-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Project spell dictionary. LazyVim keeps `spell` on for markdown/gitcommit;
-- the word list lives in the repo at `spell/en.utf-8.add` (stowed here).
-- Setting `spellfile` explicitly makes Vim recompile the `.spl` when the
-- `.add` changes and makes `zg` append to the tracked file instead of some
-- other writable `spell/` dir on the runtimepath.
vim.opt.spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
