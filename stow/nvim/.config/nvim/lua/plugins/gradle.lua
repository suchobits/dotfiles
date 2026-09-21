-- Gradle build/test/run for Kotlin/JVM (Spring Boot today) - v1 of the
-- xcodebuild.nvim-equivalent for Kotlin. No Android layer yet (see nvim
-- README's Android section). Code lives in dotfiles-gradle (private,
-- unstable while it's developed), symlinked to <config>/gradle.
return {
  {
    dir = vim.fn.stdpath("config") .. "/gradle",
    name = "gradle-runner",
    ft = "kotlin",
    -- stylua: ignore
    keys = {
      { "<leader>kb", function() require("gradle").build() end,      desc = "Gradle build" },
      { "<leader>kt", function() require("gradle").test() end,       desc = "Gradle test" },
      { "<leader>kc", function() require("gradle").clean() end,      desc = "Gradle clean" },
      { "<leader>kr", function() require("gradle").run() end,        desc = "Gradle run" },
      { "<leader>kl", function() require("gradle").toggle_log() end, desc = "Toggle Gradle log" },
    },
    config = function()
      -- Same Trouble-on-failure pattern as xcodebuild.nvim in swift.lua.
      if LazyVim.has("trouble.nvim") then
        vim.api.nvim_create_autocmd("User", {
          pattern = "GradleTaskFinished",
          callback = function(event)
            local trouble = require("trouble")
            if event.data.success then
              trouble.close()
            elseif next(vim.fn.getqflist()) then
              trouble.open("quickfix")
            end
          end,
        })
      end
    end,
  },
}
