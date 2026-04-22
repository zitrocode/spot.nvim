local M = {}

---@class spot.Config
M.defaults = {
  windows = {
    width = 60,
    max_results_height = 20,
    border = "rounded",
  },
  icons_enabled = false,
  keymaps = {},
}

---@type spot.Config
M.options = nil

---@param options? spot.Config
function M.setup(options)
  M.options = vim.tbl_deep_extend("force", {}, M.defaults, options or {})
end

---@param options? spot.Config
---@return spot.Config
function M.extend(options)
  return options and vim.tbl_deep_extend("force", {}, M.options, options) or M.options
end

setmetatable(M, {
  __index = function(_, k)
    if k == "options" then
      return M.defaults
    end
  end,
})

return M
