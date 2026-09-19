-- Swift / iOS - hand-rolled, no LazyVim extra. build/run/test/debug via
-- xcodebuild.nvim + sourcekit LSP; simulator and on-device (pymobiledevice3).
-- Tools from nix: xcbeautify/swiftformat/swiftlint/pymobiledevice3
-- (packages.nix), xcode-build-server (xcode-build-server.nix). lldb-dap
-- ships with Xcode. In-nvim pbxproj editing (xcp) is skipped - use XcodeGen.

-- New empty *.swift files get an Xcode-style header stamped from
-- templates/swift/<kind>.txt (kind from the filename suffix, else "empty").
do
  local dir = vim.fn.stdpath("config") .. "/templates/swift/"
  local suffixes = { "View", "ViewModel", "Model", "Service", "Store", "Tests" }

  vim.api.nvim_create_autocmd("BufNewFile", {
    group = vim.api.nvim_create_augroup("swift_templates", { clear = true }),
    pattern = "*.swift",
    callback = function(ev)
      local lines = vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false)
      if #lines > 1 or (lines[1] or "") ~= "" then
        return
      end

      local name = vim.fn.fnamemodify(ev.file, ":t:r")
      local kind = "empty"
      for _, s in ipairs(suffixes) do
        if vim.endswith(name, s) and vim.fn.filereadable(dir .. s:lower() .. ".txt") == 1 then
          kind = s:lower()
          break
        end
      end
      local path = dir .. kind .. ".txt"
      if vim.fn.filereadable(path) == 0 then
        return
      end

      local author = vim.trim(vim.fn.system({ "git", "config", "user.name" }))
      if vim.v.shell_error ~= 0 then
        author = ""
      end
      local now = os.date("*t")
      local subs = {
        filename = name,
        group = vim.fn.fnamemodify(ev.file, ":h:t"),
        author = author,
        date = string.format("%d/%d/%d", now.month, now.day, now.year % 100),
      }

      local out, cursor = {}, nil
      for i, line in ipairs(vim.fn.readfile(path)) do
        line = line:gsub("{(%w+)}", function(k)
          return subs[k]
        end)
        local col = line:find("{cursor}", 1, true)
        if col and not cursor then
          cursor = { i, col - 1 }
        end
        out[i] = line:gsub("{cursor}", "")
      end
      vim.api.nvim_buf_set_lines(ev.buf, 0, -1, false, out)
      if cursor then
        vim.api.nvim_win_set_cursor(0, cursor)
      end
    end,
  })
end

-- Auto-reload buffers changed outside nvim (Xcode, the simulator build).
-- LazyVim's checktime fires on FocusGained; this polling backstop covers
-- tmux / ssh where focus events do not propagate. Scoped to Swift/ObjC
-- buffers only - unscoped, it polled every open file every 2s and surfaced
-- unrelated stale-file errors (E211) on files touched by other tools.
local swift_fts = { swift = true, objc = true, objcpp = true }
if not vim.g._swift_autoread then
  vim.g._swift_autoread = true
  vim.o.autoread = true
  vim.fn.timer_start(2000, function()
    if vim.bo.buftype == "" and swift_fts[vim.bo.filetype] and vim.fn.mode() == "n" then
      vim.cmd("silent! checktime")
    end
  end, { ["repeat"] = -1 })
end

return {
  -- Ships with Xcode, not Mason. The nvim-lspconfig preset handles
  -- filetypes + root markers; only cmd needs the toolchain path.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        sourcekit = {
          cmd = { "xcrun", "sourcekit-lsp" },
        },
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "swift" } },
  },

  -- Inline images: `:XcodebuildFailingSnapshots` diffs, asset previews,
  -- markdown images. Kitty graphics protocol (Ghostty supports it).
  -- `magick` (packages.nix) is only needed for non-PNG or resizing.
  --
  -- `doc.inline = false`: don't draw generated diagrams (mermaid, from
  -- `mermaid-cli`) in the buffer text - inline mode hides them whenever the
  -- cursor is on the block and shifts the source around. `float` shows the
  -- render in a popup while the cursor is on the block instead; `<leader>cp`
  -- (markdown-preview.nvim) is the full-document view.
  {
    "folke/snacks.nvim",
    opts = { image = { enabled = true, doc = { inline = false, float = true } } },
  },

  {
    "stevearc/conform.nvim",
    opts = { formatters_by_ft = { swift = { "swiftformat" } } },
  },
  {
    "mfussenegger/nvim-lint",
    opts = { linters_by_ft = { swift = { "swiftlint" } } },
  },

  {
    "wojciech-kulik/xcodebuild.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "folke/snacks.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    ft = { "swift", "objc", "objcpp" },
    cmd = {
      "XcodebuildSetup",
      "XcodebuildPicker",
      "XcodebuildBuild",
      "XcodebuildBuildRun",
      "XcodebuildBuildForTesting",
      "XcodebuildTest",
      "XcodebuildSelectDevice",
      "XcodebuildSelectScheme",
      "XcodebuildToggleLogs",
      "XcodebuildTestExplorerToggle",
    },
    opts = {
      logs = {
        logs_formatter = "xcbeautify --disable-colored-output --disable-logging",
      },
      commands = {
        -- Let device builds mint/download the automatic-signing profile.
        -- Without it, xcodebuild fails on any bundle ID Xcode hasn't run
        -- on a device yet. Keeps the plugin's default flag.
        extra_build_args = { "-parallelizeTargets", "-allowProvisioningUpdates" },
      },
      integrations = {
        -- Off: it runs `xcode-build-server config`, broken on Xcode 26.
        -- `xc-lsp` (shell) is used instead (see nvim README, Swift).
        xcode_build_server = { enabled = false },
        lldb = { port = 13000 }, -- Xcode's bundled lldb-dap
        -- On-device debugging (iOS 17+ needs the passwordless-sudo tunnel
        -- script - see the nvim README's Swift section).
        pymobiledevice = { enabled = true },
        -- File-tree -> .xcodeproj sync needs `xcp` (brew-only). Add files
        -- via Xcode, or regenerate with XcodeGen.
        nvim_tree = { enabled = false },
        neo_tree = { enabled = false },
        oil_nvim = { enabled = false },
      },
    },
    -- stylua: ignore
    keys = {
      { "<leader>X",  "<cmd>XcodebuildPicker<cr>",              desc = "Xcodebuild actions" },
      { "<leader>xb", "<cmd>XcodebuildBuild<cr>",               desc = "Build" },
      { "<leader>xr", "<cmd>XcodebuildBuildRun<cr>",            desc = "Build & run" },
      { "<leader>xt", "<cmd>XcodebuildTest<cr>",                desc = "Run tests" },
      { "<leader>xt", "<cmd>XcodebuildTestSelected<cr>", mode = "v", desc = "Run selected tests" },
      { "<leader>xT", "<cmd>XcodebuildTestClass<cr>",           desc = "Run test class" },
      { "<leader>xe", "<cmd>XcodebuildTestExplorerToggle<cr>",  desc = "Toggle test explorer" },
      { "<leader>xl", "<cmd>XcodebuildToggleLogs<cr>",          desc = "Toggle logs" },
      { "<leader>xd", "<cmd>XcodebuildSelectDevice<cr>",        desc = "Select device" },
      { "<leader>xs", "<cmd>XcodebuildSelectScheme<cr>",        desc = "Select scheme" },
    },
    config = function(_, opts)
      require("xcodebuild").setup(opts)

      if LazyVim.has("nvim-dap") then
        require("xcodebuild.integrations.dap").setup()
      end

      -- Auto-open Trouble on build/test failure (errors are already on the
      -- quickfix list); close it again on success.
      if LazyVim.has("trouble.nvim") then
        vim.api.nvim_create_autocmd("User", {
          pattern = { "XcodebuildBuildFinished", "XcodebuildTestsFinished" },
          callback = function(event)
            if event.data.cancelled then
              return
            end
            local trouble = require("trouble")
            if event.data.success then
              trouble.close()
            elseif not event.data.failedCount or event.data.failedCount > 0 then
              if next(vim.fn.getqflist()) then
                trouble.open("quickfix")
              else
                trouble.close()
              end
              trouble.refresh()
            end
          end,
        })
      end
    end,
  },
}
