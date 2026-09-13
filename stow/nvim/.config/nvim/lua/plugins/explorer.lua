-- snacks.nvim explorer and file picker hide dotfiles by default, which causes
-- dotfile repos and XDG directories (.config/, .zshrc, etc.) to appear empty.
-- Enable dotfiles by default while keeping .git and OS artifacts excluded.
local filter = {
  hidden = true,
  ignored = false,
  exclude = {
    "**/.git",
    "**/.DS_Store",
    "**/Thumbs.db",
  },
}

return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = filter,
          files = filter,
        },
      },
    },
  },
}
