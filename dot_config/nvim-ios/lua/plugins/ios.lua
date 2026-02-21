return {
  -- The core iOS/macOS plugin
  {
    "wojciech-kulik/xcodebuild.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-tree.lua",
      "stevearc/oil.nvim",
      "nvim-treesitter/nvim-treesitter",
      "mfussenegger/nvim-dap",
    },
    config = function()
      require("xcodebuild").setup({})
    end,
  },

  -- Swift LSP (sourcekit-lsp — comes with Xcode)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        sourcekit = {
          cmd = { "sourcekit-lsp" },
          filetypes = { "swift", "objective-c", "objective-cpp" },
          root_dir = function(filename, _)
            local util = require("lspconfig.util")
            return util.root_pattern("buildServer.json")(filename)
              or util.root_pattern("*.xcodeproj", "*.xcworkspace")(filename)
              or util.root_pattern("compile_commands.json", "Package.swift")(filename)
              or util.find_git_ancestor(filename)
          end,
        },
      },
    },
  },

  -- Swift formatting + linting
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        swift = { "swiftformat" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        swift = { "swiftlint" },
      },
    },
  },
}
