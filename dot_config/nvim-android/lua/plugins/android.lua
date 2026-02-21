return {
  -- Kotlin LSP
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        kotlin_language_server = {
          root_dir = function(fname)
            local util = require("lspconfig.util")
            return util.root_pattern(
              "settings.gradle", "settings.gradle.kts",
              "build.gradle", "build.gradle.kts",
              "gradlew"
            )(fname)
          end,
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
}
