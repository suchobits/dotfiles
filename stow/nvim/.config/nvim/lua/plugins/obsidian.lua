-- obsidian.nvim - the community fork (`obsidian-nvim/`).
--
-- Scoped to the one vault at ~/Developer/vault/suchobits: it loads on
-- markdown files under that path, plus on demand for `:Obsidian` and the
-- `<leader>o` keys. Markdown anywhere else in the config never triggers it.
--
-- Rendering: the vault is drawn by obsidian.nvim's own `ui` module, so the
-- render-markdown.nvim spec below is told to skip vault buffers. 
-- obsidian's `ui.hl_groups` hard-code a Material palette upstream, so they are
-- re-linked to Vira Carbon's `@markup.*` groups.
--
-- `ripgrep` (search/completion) is already in darwin/packages.nix.
-- `:Obsidian paste_img` also wants `pngpaste` (not installed) - see README.
local vault = vim.fn.expand("~/Developer/vault/suchobits")

local function in_vault(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  return name:sub(1, #vault + 1) == vault .. "/"
end

return {
  {
    "obsidian-nvim/obsidian.nvim",
    -- Deliberate deviation from lazy.lua's `version = false`: upstream warns
    -- `main` can break between releases. Commits are still pinned in
    -- lazy-lock.json, so `:Lazy update` is the only moment this bites.
    version = "*",
    event = {
      "BufReadPre " .. vault .. "/*.md",
      "BufReadPre " .. vault .. "/**/*.md",
      "BufNewFile " .. vault .. "/*.md",
      "BufNewFile " .. vault .. "/**/*.md",
    },
    cmd = "Obsidian",
    -- stylua: ignore
    keys = {
      { "<leader>on", "<cmd>Obsidian new<cr>",          desc = "Obsidian: new note" },
      { "<leader>oo", "<cmd>Obsidian quick_switch<cr>", desc = "Obsidian: quick switch" },
      { "<leader>os", "<cmd>Obsidian search<cr>",       desc = "Obsidian: search vault" },
      { "<leader>ot", "<cmd>Obsidian today<cr>",        desc = "Obsidian: today's note" },
      { "<leader>oy", "<cmd>Obsidian yesterday<cr>",    desc = "Obsidian: yesterday's note" },
      { "<leader>ob", "<cmd>Obsidian backlinks<cr>",    desc = "Obsidian: backlinks" },
      { "<leader>ol", "<cmd>Obsidian links<cr>",        desc = "Obsidian: links in note" },
      { "<leader>oT", "<cmd>Obsidian template<cr>",     desc = "Obsidian: insert template" },
      { "<leader>op", "<cmd>Obsidian paste_img<cr>",    desc = "Obsidian: paste image" },
      { "<leader>or", "<cmd>Obsidian rename<cr>",       desc = "Obsidian: rename note" },
      { "<leader>ow", "<cmd>Obsidian workspace<cr>",    desc = "Obsidian: switch workspace" },
    },
    opts = {
      legacy_commands = false,
      workspaces = {
        { name = "suchobits", path = vault },
      },
      picker = { name = "snacks.picker" },
      ui = {
        enable = true,
        -- render-markdown is turned off for the vault instead (see below).
        ignore_conceal_warn = true,
        hl_groups = {
          ObsidianTodo = { link = "@markup.list.unchecked" },
          ObsidianDone = { link = "@markup.list.checked" },
          ObsidianRightArrow = { link = "@markup.list" },
          ObsidianTilde = { link = "@markup.strikethrough" },
          ObsidianImportant = { link = "DiagnosticError" },
          ObsidianBullet = { link = "@markup.list" },
          ObsidianRefText = { link = "@markup.link.label" },
          ObsidianExtLinkIcon = { link = "@markup.link" },
          ObsidianHighlightText = { link = "Search" },
          ObsidianTag = { link = "@markup.link.label" },
          ObsidianBlockID = { link = "Comment" },
        },
      },
      callbacks = {
        -- Buffer-local, so these bind only inside vault notes.
        enter_note = function()
          local map = function(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = true, desc = desc })
          end
          map("<cr>", require("obsidian.api").smart_action, "Obsidian: follow link / toggle checkbox")
          map("]o", function()
            require("obsidian.actions").nav_link("next")
          end, "Obsidian: next link")
          map("[o", function()
            require("obsidian.actions").nav_link("prev")
          end, "Obsidian: prev link")
        end,
      },
    },
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    optional = true,
    opts = function(_, opts)
      local prev = opts.ignore
      opts.ignore = function(buf)
        return in_vault(buf) or (prev ~= nil and prev(buf)) or false
      end
    end,
  },
}
