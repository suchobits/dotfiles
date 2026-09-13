-- JetBrains kotlin-lsp, not the `lang.kotlin` extra (unmaintained fwcd via
-- Mason). Bundles its own JBR; Android Gradle support is experimental, so
-- expect false diagnostics in `:app` modules. `filetypes` is set here
-- because the pinned nvim-lspconfig has no `lsp/kotlin_lsp.lua` yet.
-- Binary on $PATH via darwin/kotlin-lsp.nix.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        kotlin_lsp = {
          cmd = { "kotlin-lsp", "--stdio" },
          filetypes = { "kotlin" },
          single_file_support = false,
          root_markers = {
            "settings.gradle",
            "settings.gradle.kts",
            "build.gradle",
            "build.gradle.kts",
            "pom.xml",
          },
        },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "kotlin" } },
  },
}
