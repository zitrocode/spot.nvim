local M = {}

--- Register all picker keymaps on the search buffer.
---
---@param search_buf integer: the search input buffer handle.
---@param actions spot.Keymap.Actions: callbacks for each key action.
function M.setup(search_buf, actions)
  local function opts(desc)
    return { buffer = search_buf, silent = true, nowait = true, desc = desc }
  end

  vim.keymap.set({ "n" }, "j", actions.cursor_down, opts("spot: next result"))
  vim.keymap.set({ "n" }, "k", actions.cursor_up, opts("spot: previous result"))
  vim.keymap.set({ "n", "i" }, "<CR>", actions.confirm, opts("spot: confirm selection"))
  vim.keymap.set({ "n" }, "<Esc>", actions.close, opts("spot: close picker"))
  vim.keymap.set({ "n" }, "q", actions.close, opts("spot: close picker"))
end

return M
