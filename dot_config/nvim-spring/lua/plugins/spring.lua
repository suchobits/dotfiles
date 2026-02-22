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
            "pom.xml",
          },
          mason = false,
        },
      },
    },
  },

  -- Kotlin formatting + linting (ktlint reads .editorconfig automatically)
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        kotlin = { "ktlint" },
      },
      formatters = {
        ktlint = {
          cwd = require("conform.util").root_file({
            ".editorconfig", "build.gradle", "build.gradle.kts",
            "settings.gradle", "settings.gradle.kts", "pom.xml",
          }),
        },
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

  -- which-key group label for run keymaps
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
