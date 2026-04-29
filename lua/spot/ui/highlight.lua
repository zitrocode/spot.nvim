local M = {}

--- Define all higlight groups used by spot.nvim,
--- Safe to call multiple times (each call is idempotent).
function M.setup()
  -- The selected results row.
  -- Links to `PmenuSel` by default; users can override with `:hi SpotSelect`.
  vim.api.nvim_set_hl(0, "SpotSelect", { link = "PmenuSel", default = true })
end

--- Apply result-window highlight to a window after it has been created.
---
--- @param win integer: the result window handle.
function M.apply(win)
  vim.api.nvim_set_option_value("cursorline", true, { win = win })
  vim.api.nvim_set_option_value("winhighlight", "CursorLine:SpotSelect", { win = win })
end

return M
