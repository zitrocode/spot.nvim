local buffer = require("spot.ui.buffer")
local finder = require("spot.finder")
local state = require("spot.state")
local windows = require("spot.ui.window")

local M = {}

function M.setup(search_buf)
  vim.api.nvim_create_autocmd("TextChangedI", {
    buffer = search_buf,

    callback = function()
      local query = vim.api.nvim_buf_get_lines(search_buf, 0, 1, false)[1]
      state.search = query
      state.entries = finder.filter(state.files, query)

      local display = finder.display(state.entries)
      buffer.set_lines(state.windows.results.buf, display)
      windows.resize_to_content(state.windows.results.win, #display)
    end,
  })
end

return M
