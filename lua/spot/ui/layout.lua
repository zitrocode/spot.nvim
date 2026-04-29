local config = require("spot.config")

local M = {}

-- Internal helpers

--- Compute the starting column that centres a window of `width` columns in
--- the current editor.
---
--- @param width integer
--- @return integer
local function center_col(width)
  return math.floor((vim.o.columns - width) / 2)
end

--- Return the geometry for the search input window.
--- Always one row tall and centred horizontally.
---
--- @return spot.Layout.Geometry
function M.search()
  local cfg = config.get()
  local width = cfg.windows.width

  --- @type spot.Layout.Geometry
  return {
    row = 0,
    col = center_col(width),
    width = width,
    height = 1,
  }
end

--- Return the geometry the results window.
--- Placed inmediately below the search window (row = search.height + border gap)
---
--- @param entry_count integer: number of entries to display; drives the height.
--- @return spot.Layout.Geometry
function M.results(entry_count)
  local cfg = config.get()
  local width = cfg.windows.width
  --- +2 accounts for the search window row (0) plus its border top and buttom.
  --- The search window is 1 row tall with a rounded border (2 extra rows), so
  --- the results window starts at row 3.
  local row = 3
  local height = math.max(1, math.min(entry_count, cfg.windows.max_height))

  --- @type spot.Layout.Geometry
  return {
    row = row,
    col = center_col(width),
    width = width,
    height = height,
  }
end

return M
