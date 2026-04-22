local state = require("spot.state")
local window = require("spot.ui.window")

local M = {}

local function move_cursor(delta)
  local total = #state.entries
  if total == 0 then
    return
  end

  state.index = math.max(1, math.min(state.index + delta, total))
  vim.api.nvim_win_set_cursor(state.windows.results.win, { state.index, 0 })
end

local function open_file()
  local path = state.entries[state.index]

  if not path then
    return
  end

  window.close(state.windows.search.win)
  window.close(state.windows.results.win)

  vim.api.nvim_set_current_win(state.origin.win)
  vim.cmd.edit(vim.fn.fnameescape(path))
end

M.setup = function(search_buf)
  local opts = { buffer = search_buf, silent = true }

  vim.keymap.set({ "n" }, "j", function()
    move_cursor(1)
  end, opts)

  vim.keymap.set({ "n" }, "k", function()
    move_cursor(-1)
  end, opts)

  vim.keymap.set({ "n", "i" }, "<CR>", open_file, opts)

  vim.keymap.set({ "n" }, "q", function()
    window.close(state.windows.search.win)
    window.close(state.windows.results.win)
  end, opts)
end

return M
