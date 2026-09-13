-- Markdown rendering.
--
-- `markdown-preview.nvim` (bundled by `lang.markdown`, on-demand browser
-- view via `<leader>cp`) is left as the extra ships it - not disabled here.
--
-- Corrections to what the extra ships:
--   * heading.icons - the extra blanks it (`{}`), this sets it back on.
--   * checkbox.enabled - the extra turns it off; this sets it back on.
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      heading = {
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
      },
      checkbox = {
        enabled = true,
      },
    },
  },

  -- `lang.markdown` runs markdownlint-cli2 through nvim-lint. Its rules
  -- (line length, bare URLs, first-line-must-be-h1, no-inline-html) are
  -- house style for published docs and just noise on personal notes, so
  -- drop it for markdown. marksman (LSP) and prettier (format) stay.
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.markdown = {}
    end,
  },
}
