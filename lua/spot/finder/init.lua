local fd = require("spot.finder.fd")
local filter = require("spot.finder.filter")
local format = require("spot.finder.format")

local M = {}

M.load = function()
  local entries = fd.files()
  entries = format.sort(entries)

  return entries
end

M.filter = function(entries, query)
  return filter.entries(entries, query)
end

M.display = function(entries)
  return format.display(entries)
end

return M
