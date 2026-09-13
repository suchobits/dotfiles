-- nvim half of christoomey/vim-tmux-navigator. The tmux half is a TPM
-- plugin in stow/tmux/.tmux.conf, which rebinds <C-hjkl> at the tmux root
-- level with an "is this pane running vim?" check and forwards the key
-- into nvim when so. This side receives it and, when nvim is already at
-- its edge-most split, hands off to `tmux select-pane` - so <C-hjkl>
-- crosses the nvim-split / tmux-pane boundary without a second keystroke
-- (notably into the sidekick agent pane).
--
-- The `keys` field is required: LazyVim's core keymaps bind <C-hjkl> to
-- plain `<C-w>h` on the VeryLazy event, which runs after plugin/ files,
-- so defining them here as lazy keys is what wins.
return {
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Go to Left Window/Pane" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Go to Lower Window/Pane" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Go to Upper Window/Pane" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Go to Right Window/Pane" },
    },
  },
}
