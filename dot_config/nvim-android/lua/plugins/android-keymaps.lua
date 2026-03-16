return {
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>A", group = "android" },
      },
    },
  },
  {
    dir = ".",
    name = "android-commands",
    config = function()
      local tmux = require("shared.tmux")
      local map = vim.keymap.set
      map("n", "<leader>Ar", function()
        tmux.run("adb shell am start -n $(./gradlew -q printPackageName)/.MainActivity")
      end, { desc = "Run app (adb)" })
      map("n", "<leader>Al", function()
        tmux.run("adb logcat")
      end, { desc = "Logcat" })
    end,
  },
}
