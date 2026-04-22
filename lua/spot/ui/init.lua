local state = require("spot.state")

local buffer = require("spot.ui.buffer")
local highlight = require("spot.ui.highlight")
local keymaps = require("spot.ui.keymaps")
local search = require("spot.ui.search")
local window = require("spot.ui.window")

local finder = require("spot.finder")

local M = {}

function M.open()
  -- Buffers
  state.windows.search.buf = buffer.create({ modifiable = true })
  state.windows.results.buf = buffer.create()

  -- Windows
  state.windows.search.win = window.create("Search Files", state.windows.search.buf, true, 0, { height = 1 })
  state.windows.results.win =
    window.create("Results", state.windows.results.buf, false, 3, { height = math.min(16, #state.entries) })

  -- Lifecycle
  window.link_close(state.windows.search.win, state.windows.results.win)

  -- Highlight
  highlight.setup()
  highlight.apply(state.windows.results.win)

  -- Initial render
  local display = finder.display(state.entries)
  buffer.set_lines(state.windows.results.buf, display)

  -- Search
  search.setup(state.windows.search.buf)

  -- Keymaps
  keymaps.setup(state.windows.search.buf)
end

return M
