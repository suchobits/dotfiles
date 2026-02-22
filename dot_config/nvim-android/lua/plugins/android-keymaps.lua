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
      local function run_in_tmux(cmd)
        if not vim.env.TMUX then
          vim.cmd("split | terminal " .. cmd)
          return
        end
        local root = vim.fn.getcwd()
        local pane_id = vim.fn.system(
          string.format("tmux split-window -v -c %s -P -F '#{pane_id}'", vim.fn.shellescape(root))
        ):gsub("%s+", "")
        vim.fn.system(string.format("tmux send-keys -t %s %s Enter", pane_id, vim.fn.shellescape(cmd)))
      end

      local map = vim.keymap.set
      map("n", "<leader>Ar", function()
        run_in_tmux("adb shell am start -n $(./gradlew -q printPackageName)/.MainActivity")
      end, { desc = "Run app (adb)" })
      map("n", "<leader>Al", function()
        run_in_tmux("adb logcat")
      end, { desc = "Logcat" })
    end,
  },
}
