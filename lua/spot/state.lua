local M = {}

M.search = nil
M.files = {}
M.entries = {}
M.origin = {
  win = nil,
}

M.windows = {
  search = { buf = nil, win = nil },
  results = { buf = nil, win = nil },
}

M.index = 1

return M
