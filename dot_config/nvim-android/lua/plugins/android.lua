return {
  -- JetBrains Kotlin LSP (replaces community kotlin_language_server)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        kotlin_language_server = { enabled = false },
        kotlin_lsp = {
          cmd = { "kotlin-lsp", "--stdio" },
          filetypes = { "kotlin" },
          root_markers = {
            "settings.gradle",
            "settings.gradle.kts",
            "build.gradle",
            "build.gradle.kts",
            "gradlew",
          },
          mason = false,
        },
      },
    },
  },

  -- Kotlin formatting + linting
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        kotlin = { "ktlint" },
        xml = { "xmllint" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        kotlin = { "ktlint" },
      },
    },
  },

  -- XML support for Android layouts
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        lemminx = {},
      },
    },
  },

  -- which-key group labels for discoverability
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>r", group = "run" },
        { "g", group = "goto" },
      },
    },
  },
}
