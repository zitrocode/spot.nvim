local config = require("spot.config")

local M = {}

local function center_col(width)
  return math.floor((vim.o.columns - width) / 2)
end

function M.create(name, buf, enter, row, opts)
  opts = opts or {}

  local width = opts.width or config.options.windows.width
  local border = opts.border or config.options.windows.border

  return vim.api.nvim_open_win(buf, enter, {
    relative = "editor",
    row = row,
    col = center_col(width),

    width = width,
    height = opts.height,
    border = border,
    style = "minimal",

    title = name,
  })
end

function M.link_close(parent_win, child_win)
  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(parent_win),

    callback = function()
      if vim.api.nvim_win_is_valid(child_win) then
        vim.api.nvim_win_close(child_win, true)
      end
    end,
  })
end

M.close = function(win)
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end
end

M.resize_to_content = function(win, count)
  local height = math.max(1, math.min(count, 16))
  vim.api.nvim_win_set_config(win, {
    height = height,
  })
end

return M
