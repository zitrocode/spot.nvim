local format = require("spot.finder.format")

local M = {}

function M.files()
  local files = vim.fn.systemlist({
    "fd",
    "--type",
    "f",
    "--hidden",
    "--follow",
    "--exclude",
    ".git",
  })

  return format.sort(files)
end

return M
