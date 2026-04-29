local config = require("spot.config")
local picker = require("spot.picker")
local source = require("spot.source")
local state = require("spot.state")
local ui = require("spot.ui")

local M = {}

--- Configure spot.nvim
---
--- Call this once from your init file. Calling it multiple times is safe;
--- each call the provided options on top of the defaults
---
--- @param opts? spot.Config
function M.setup(opts)
  config.setup(opts)

  -- Register built-in sources listend in config (in order).
  for _, name in ipairs(config.get().sources) do
    local ok, src = pcall(require, "spot.source." .. name)
    if ok then
      source.register(src)
      return
    end

    vim.notify(("spot: built-in source %q not found"):format(name), vim.log.levels.WARN)
  end
end

-- Open the picker for the currently active source
function M.open()
  -- Guard: do nothing if the picker is already visible.
  if state.is_open() then
    return
  end

  -- Ensure at least the default source is available even if setup() was skippend.
  if #source.list() == 0 then
    M.setup()
  end

  state.set_origin_win(vim.api.nvim_get_current_win())
  picker.load()
  ui.open()
  state.set_open(true)
end

-- Focus the search input window
function M.focus()
  local ui_window = require("spot.ui.window")
  ui_window.foucs(state.get_windows().search.win)
end

-- Close the picker
function M.close()
  ui.close()
  state.set_open(false)
end

function M.toggle()
  if state.is_open() then
    M.close()
    return
  end

  M.open()
end

return M
