return {
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      opts.defaults = opts.defaults or {}
      opts.defaults["<leader>A"] = { name = "+android" }
    end,
  },
  {
    dir = ".",
    name = "android-commands",
    config = function()
      vim.api.nvim_create_user_command("AndroidBuild", function()
        vim.cmd("!./gradlew assembleDebug")
      end, {})
      vim.api.nvim_create_user_command("AndroidInstall", function()
        vim.cmd("!./gradlew installDebug")
      end, {})
      vim.api.nvim_create_user_command("AndroidRun", function()
        vim.cmd("!adb shell am start -n $(./gradlew -q printPackageName)/.MainActivity")
      end, {})
      vim.api.nvim_create_user_command("AndroidLogcat", function()
        vim.cmd("split | terminal adb logcat")
      end, {})

      local map = vim.keymap.set
      map("n", "<leader>Ab", "<cmd>AndroidBuild<cr>", { desc = "Build Debug APK" })
      map("n", "<leader>Ai", "<cmd>AndroidInstall<cr>", { desc = "Install on device" })
      map("n", "<leader>Ar", "<cmd>AndroidRun<cr>", { desc = "Run app" })
      map("n", "<leader>Al", "<cmd>AndroidLogcat<cr>", { desc = "Logcat" })
    end,
  },
}
