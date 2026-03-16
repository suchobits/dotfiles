return {
  -- Extend gopls with extra analyses (LazyVim extras.lang.go handles the rest)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
              analyses = {
                shadow = true,
                unusedvariable = true,
              },
            },
          },
        },
      },
    },
  },

  -- neotest-golang: use gotestsum for more reliable test output
  {
    "nvim-neotest/neotest",
    opts = {
      adapters = {
        ["neotest-golang"] = {
          runner = "gotestsum",
          dap_go_enabled = true,
        },
      },
    },
  },

  -- gopher.nvim: Go code generation (iferr, struct tags, test gen, interface impl)
  {
    "olexsmir/gopher.nvim",
    ft = "go",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {},
  },

  -- which-key group labels
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
