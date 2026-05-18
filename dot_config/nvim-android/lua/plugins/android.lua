return {
  -- Kotlin treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "kotlin" } },
  },

  -- JetBrains Kotlin LSP (native vim.lsp.config via lsp/kotlin_lsp.lua)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        kotlin_lsp = { enabled = false },
        kotlin_language_server = { enabled = false },
        lemminx = {},
      },
    },
    init = function()
      vim.lsp.enable("kotlin_lsp")
    end,
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
        kotlin = { "detekt" },
      },
      linters = {
        detekt = {
          cmd = "detekt",
          args = {
            "--input",
            function() return vim.api.nvim_buf_get_name(0) end,
            "--config",
            function()
              local config = vim.fn.findfile("detekt.yml", ".;")
              return config ~= "" and config or vim.fn.stdpath("config") .. "/detekt.yml"
            end,
            "--report", "xml:/dev/stdout",
          },
          stdin = false,
          append_fname = false,
          ignore_exitcode = true,
          parser = function(output)
            local diagnostics = {}
            for line, col, severity, message in
              output:gmatch('<error line="(%d+)" column="(%d+)" severity="(%w+)" message="(.-)"')
            do
              table.insert(diagnostics, {
                lnum = tonumber(line) - 1,
                col = tonumber(col) - 1,
                severity = severity == "error" and vim.diagnostic.severity.ERROR
                  or vim.diagnostic.severity.WARN,
                message = message:gsub("&apos;", "'"):gsub("&amp;", "&"):gsub("&lt;", "<"):gsub("&gt;", ">"),
                source = "detekt",
              })
            end
            return diagnostics
          end,
        },
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
