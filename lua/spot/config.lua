local M = {}

--- @type spot.Config
M.defaults = {
  windows = {
    width = 80,
    max_height = 16,
  },

  -- All sources registered automatically during setup().
  sources = { "files" },

  -- Fallback source when the query has no recognised prefix.
  default_source = "files",

  -- Prefix routing table.
  prefixes = {},
}

--- The resolved configuration produced by `setup()`.
--- `nil` until `setup()` is called; `get()` falls back to `defaults`.
---
--- @type spot.Config | nil
M._options = nil

--- Apply user configuration on top of the defaults.
---
--- @param opts? spot.Config  Partial overrides; omitted keys keep their defaults.
function M.setup(opts)
  M._options = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
end

--- Return the active configuration, falling back to defaults if `setup()` has
--- not been called yet.
---
--- @return spot.Config
function M.get()
  return M._options or M.defaults
end

return M
