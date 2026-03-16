local M = {}

--- Run a command in a tmux split pane, or a Neovim terminal split if not in tmux.
---@param cmd string Shell command to run
---@param opts? { beside?: boolean, vertical?: boolean }
function M.run(cmd, opts)
  opts = opts or {}
  if not vim.env.TMUX then
    vim.cmd((opts.vertical and "vsplit" or "split") .. " | terminal " .. cmd)
    return
  end
  local root = vim.fn.getcwd()
  local split_args = opts.beside
    and string.format("-h -t {bottom} -c %s", vim.fn.shellescape(root))
    or string.format("-v -c %s", vim.fn.shellescape(root))
  local pane_id = vim.fn.system("tmux split-window " .. split_args .. " -P -F '#{pane_id}'"):gsub("%s+", "")
  vim.fn.system(string.format("tmux send-keys -t %s %s Enter", pane_id, vim.fn.shellescape(cmd)))
end

return M
