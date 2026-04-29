local M = {}

--- Attach a `TextChangeI` autocmd to `search_buf` that extracts the first
--- line and forwards it to `handlers.on_change`.
---
--- @param search_buf integer: the search input buffer handle
--- @param handlers spot.Search.Handlers: callback table
function M.setup(search_buf, handlers)
  vim.api.nvim_create_autocmd("TextChangedI", {
    buffer = search_buf,
    desc = "spot: update results on quert change",
    callback = function()
      local query = vim.api.nvim_buf_get_lines(search_buf, 0, 1, false)[1] or ""
      handlers.on_change(query)
    end,
  })
end

return M
