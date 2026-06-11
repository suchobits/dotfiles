vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt -- keeping it dry

opt.relativenumber = true -- for easier motions
opt.number = true         -- show actual line number for current position

-- tabs and indentation
opt.tabstop = 2       -- 2 spaces for tabs
opt.shiftwidth = 2    -- 2 spaces for indent width
opt.expandtab = true  -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting a new one

opt.wrap = false -- do not wrap lines

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true  -- when using mixed case assumes case sensitive search

opt.cursorline = true

-- turn on termguicolors for colorschemes 
-- (requires alacritty, ghostty or any other true color terminal)
opt.termguicolors = true
opt.background = "dark" -- colorschemes can be light or dark, this will select dark
opt.signcolumn = "yes"  -- show sign column so that text doesn't shift

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

