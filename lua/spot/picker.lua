local router = require("spot.router")
local source_registry = require("spot.source")
local state = require("spot.state")

local M = {}

--- Return the subset of `entries` whose lowercased form contains `query`.
--- Using a plan substring search keeps things fast for large lists.
--- A future caller can swap this for a scoring-based fuzzy matcher by
--- replacing only this fuction.
---
--- @param entries string[]
--- @param query string
--- @return string[]
local function filter_entries(entries, query)
  if not query or query == "" then
    return entries
  end

  local q = query:lower()
  local out = {}

  for _, entry in ipairs(entries) do
    if entry:lower():find(q, 1, true) then
      out[#out + 1] = entry
    end
  end

  return out
end

--- Load entries from `source_name` into state and reset selection.
--- Extracted so both `load()` and `update_query()` share the same path.
---
--- @param source_name string
local function load_source(source_name)
  local source = source_registry.get(source_name)
  local entries = source.load()
  state.set_source_name(source_name)
  state.set_entries(entries)
  state.set_results(entries)
  state.set_selected_index(1)
end

--- Load entries from the default source on picker open.
--- Called once by `spot.open()` before the UI is rendered.
function M.load()
  local cfg = require("spot.config").get()
  load_source(cfg.default_source)
end

--- Process a new query string.
---
--- Resolves the prefix, switches sources if needed, filters, and updates
--- state. Returns the router result so the UI can update the title bar.
---
--- @param query string
--- @return spot.Router.Result
function M.update_query(query)
  local route = router.resolve(query)

  -- Switch source if the prefix changed since the last keystroke.
  -- Checking by name avoids a redundant load() on every character typed
  -- when the user stays within the same source.
  if route.source ~= state.get_source_name() then
    -- Guard: only switch if the source is actually registered.
    local ok = pcall(source_registry.get, route.source)
    if ok then
      load_source(route.source)
    else
      -- Source not registered yet — stay on the current source but still
      -- update query so the filter runs. Notify once to aid development.
      vim.notify(
        ("spot: source %q is not registered (prefix matched but source missing)"):format(route.source),
        vim.log.levels.WARN
      )
    end
  end

  state.set_query(query)
  local filtered = filter_entries(state.get_entries(), query)
  state.set_results(filtered)
  state.set_selected_index(1)

  return route
end

--- Produce display lines for `entries` using the active source's formatter.
---
--- @param entries string[]
--- @return string[]
function M.display(entries)
  local source = source_registry.get(state.get_source_name())
  return source.display(entries)
end

--- Execute the action for the entry at `selected_index`.
--- Closes the picker first, then delegates to the source's `execute`.
---
--- @param close_fn function
function M.execute_seleted(close_fn)
  local results = state.get_results()
  local entry = results[state.get_selected_index()]

  if not entry then
    return
  end

  close_fn()

  local source = source_registry.get(state.get_source_name())
  source.execute(entry, state)
end

return M
