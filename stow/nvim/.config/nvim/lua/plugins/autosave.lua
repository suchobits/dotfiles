-- Autosave. LazyVim maps `<C-s>` to "save file", but `<C-s>` is the tmux
-- prefix (see `stow/tmux`). `:w` still works as normal.
-- This writes changed buffers a couple of seconds after you stop typing;
--
-- okuuva/auto-save.nvim is the maintained fork of the (abandoned)
-- pocco81/auto-save.nvim - it fixes the undo/redo breakage of the original.
return {
  "okuuva/auto-save.nvim",
  version = "^1",
  event = { "InsertLeave", "TextChanged" },
  opts = {
    -- wait for a typing pause rather than writing on every keystroke group
    debounce_delay = 2000,
  },
}
