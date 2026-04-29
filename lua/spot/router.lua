local config = require("spot.config")

local M = {}

--- Resolve `query` to a source name and normalised query.
---
--- @param query string
--- @return spot.Router.Result
function M.resolve(query)
  local cfg = config.get()

  -- Build a sorted list of prefixes, longest first, so ">>" is tried
  -- before ">" and there is no ambiguity between overlapping =, prefixes.
  local sorted_prefixes = vim.tbl_keys(cfg.prefixes)
  table.sort(sorted_prefixes, function(a, b)
    return #a > #b
  end)

  for _, prefix in ipairs(sorted_prefixes) do
    if vim.startswith(query, prefix) then
      local route = cfg.prefixes[prefix]

      return {
        source = route.source,
        query = query,
        title = route.desc,
      }
    end
  end

  -- No prefix mathed - fall back to the default source
  return {
    source = cfg.default_source,
    query = query,
    title = cfg.default_source,
  }
end
return M
