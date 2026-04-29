local M = {}

--- @type spot.State
local _data = {
  is_open = false,
  query = "",
  entries = {},
  results = {},
  selected_index = 1,
  origin_win = nil,
  source_name = "files",
  windows = {
    search = { buf = nil, win = nil },
    results = { buf = nil, win = nil },
  },
}

---@return boolean
function M.is_open()
  return _data.is_open
end

---@return string
function M.get_query()
  return _data.query
end

---@return string[]
function M.get_entries()
  return _data.entries
end

---@return string[]
function M.get_results()
  return _data.results
end

---@return integer
function M.get_selected_index()
  return _data.selected_index
end

---@return integer|nil
function M.get_origin_win()
  return _data.origin_win
end

---@return string
function M.get_source_name()
  return _data.source_name
end

---@return spot.State.Windows
function M.get_windows()
  return _data.windows
end

-- Setters

---@param value boolean
function M.set_open(value)
  _data.is_open = value
end

---@param value string
function M.set_query(value)
  _data.query = value or ""
end

---@param value string[]
function M.set_entries(value)
  _data.entries = value or {}
end

---@param value string[]
function M.set_results(value)
  _data.results = value or {}
end

---@param value integer
function M.set_selected_index(value)
  _data.selected_index = value
end

---@param value integer|nil
function M.set_origin_win(value)
  _data.origin_win = value
end

---@param value string
function M.set_source_name(value)
  _data.source_name = value
end

--- Replace the search window handles atomically.
---@param buf integer
---@param win integer
function M.set_search_window(buf, win)
  _data.windows.search.buf = buf
  _data.windows.search.win = win
end

--- Replace the results window handles atomically.
---@param buf integer
---@param win integer
function M.set_results_window(buf, win)
  _data.windows.results.buf = buf
  _data.windows.results.win = win
end

--- Reset all state to initial values.
--- Called by `spot.close()` to ensure a clean slate for the next open.
function M.reset()
  _data.is_open = false
  _data.query = ""
  _data.entries = {}
  _data.results = {}
  _data.selected_index = 1
  _data.origin_win = nil
  _data.windows.search.buf = nil
  _data.windows.search.win = nil
  _data.windows.results.buf = nil
  _data.windows.results.win = nil
  -- Note: source_name is intentionally preserved across sessions so the
  -- picker reopens with the same source the user was last using.
end

return M
