local state = require("spot.state")

local M = {}

--- Open a floating window using a pre-computed geometry.
---
--- @param buf integer: buffer to display
--- @param geometry spot.Layout.Geometry: position and size from `spot.ui.layout`
--- @param opts spot.Window.Opts
--- @return integer win
function M.open(buf, geometry, opts)
  return vim.api.nvim_open_win(buf, opts.enter or false, {
    relative = "editor",
    row = geometry.row,
    col = geometry.col,
    width = geometry.width,
    height = geometry.height,
    border = "rounded",
    style = "minimal",
    title = opts.title,
  })
end

-- lifecycle

--- Close a window if it is still valid
--- Silently does nothing when `win` is nil or already closed.
--- Alson stops insert mode to avoid leaving the editor in an incosistent state.
---
--- @param win integer | nil
M.close = function(win)
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end

  vim.cmd("stopinsert")
end

--- Link two windows so that closing `parent` automatically closes `child`.
--- Uses a one-shot `WinClosed` autocmd scoped to `parent`'s handle.
---
--- @param parent integer
--- @param child integer
function M.link_close(parent, child)
  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(parent),
    once = true,
    callback = function()
      M.close(child)
      state.set_open(false)
    end,
  })
end

--- Resize a window's height, clamped to the configured maximum.
---
--- @param win integer
--- @param entry_count integer: desired number of visible rows.
M.resize = function(win, entry_count)
  if not (win and vim.api.nvim_win_is_valid(win)) then
    return
  end

  local max = require("spot.config").get().windows.max_height
  local height = math.max(1, math.min(entry_count, max))
  vim.api.nvim_win_set_config(win, { height = height })
end

--- Move focus to `win`
---
--- @param win integer | nil
M.foucs = function(win)
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_set_current_win(win)
  end
end

return M
