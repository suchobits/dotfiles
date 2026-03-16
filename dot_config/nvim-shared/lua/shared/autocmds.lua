-- Return to dashboard when the last real buffer is closed
vim.api.nvim_create_autocmd("BufDelete", {
  group = vim.api.nvim_create_augroup("shared_dashboard_on_empty", { clear = true }),
  callback = function()
    vim.schedule(function()
      local bufs = vim.tbl_filter(function(b)
        return vim.api.nvim_buf_is_valid(b)
          and vim.bo[b].buflisted
          and vim.api.nvim_buf_get_name(b) ~= ""
      end, vim.api.nvim_list_bufs())

      if #bufs == 0 then
        -- Close any remaining unnamed buffers and open dashboard
        if pcall(require, "snacks") then
          vim.cmd("enew | bw# | lua Snacks.dashboard()")
        end
      end
    end)
  end,
})
