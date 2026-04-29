local M = {}

--- @type table<string, spot.Source>
local _registry = {}

--- Register a source implementation
--- If a source with the same `name` is already registered it will be replaced,
--- which allows users to override build-ins with their own implementation.
---
--- @param source spot.Source
function M.register(source)
  assert(type(source) == "table", "spot.source.register: source must be a table")
  assert(
    type(source.name) == "string" and source.name ~= "",
    "spot.source.register: source.name must be a non-empty string"
  )
  assert(type(source.load) == "function", "spot.source.register: source.load must be a function")
  assert(type(source.display) == "function", "spot.source.register: source.display must be a function")
  assert(type(source.execute) == "function", "spot.source.register: source.execute must be a function")

  _registry[source.name] = source
end

--- Retrieve a registered source by name.
---
--- @param name string
--- @return spot.Source
function M.get(name)
  local source = _registry[name]

  if not source then
    error(("spot.source: no source registered with name %q"):format(name))
  end

  return source
end

--- Return the names of all registered sources, sorted alphabetically.
---
--- @return string[]
function M.list()
  local names = vim.tbl_keys(_registry)
  table.sort(names)
  return names
end

return M
