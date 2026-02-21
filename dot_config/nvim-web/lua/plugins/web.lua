return {
  -- TypeScript tooling
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {},
  },

  -- Tailwind CSS colors in completion
  { "roobert/tailwindcss-colorizer-cmp.nvim", config = true },

  -- Package.json info
  { "vuki656/package-info.nvim", dependencies = "MunifTanjim/nui.nvim", config = true },
}
