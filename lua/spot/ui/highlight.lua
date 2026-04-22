local M = {}

function M.setup()
  vim.api.nvim_set_hl(0, "SpotSelect", {
    link = "PmenuSel",
  })
end

function M.apply(win)
  vim.api.nvim_set_option_value("cursorline", true, { win = win })
  vim.api.nvim_set_option_value("winhighlight", "CursorLine:SpotSelect", { win = win })
end

return M
