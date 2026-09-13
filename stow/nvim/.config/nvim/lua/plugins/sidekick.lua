-- Enabled by the `ai.sidekick` extra; this is just local prefs. Used
-- mainly as a pane to watch/drive CLI agents. Next Edit Suggestions need
-- `:LspCopilotSignIn`, else they no-op.
return {
  {
    "folke/sidekick.nvim",
    opts = {
      cli = {
        -- Run agents in tmux (stow/tmux) so they outlive nvim.
        mux = { backend = "tmux", enabled = true },
      },
    },
  },
}
