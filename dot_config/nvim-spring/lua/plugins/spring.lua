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
              "build.gradle", "build.gradle.kts"
            )(fname)
          end,
        },
      },
    },
  },

  -- Spring Boot LS integration
  {
    "JavaHello/spring-boot.nvim",
    ft = { "java", "kotlin", "yaml", "jproperties" },
    dependencies = {
      "mfussenegger/nvim-jdtls",
    },
    opts = {},
  },

  -- Kotlin formatting + linting
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        kotlin = { "ktlint" },
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
}
