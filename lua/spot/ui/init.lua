local buffer = require("spot.ui.buffer")
local highlight = require("spot.ui.highlight")
local keymaps = require("spot.ui.keymaps")
local layout = require("spot.ui.layout")
local search = require("spot.ui.search")
local window = require("spot.ui.window")

local picker = require("spot.picker")
local state = require("spot.state")

local M = {}

--- Move the results cursor by `delta` rows, clamped to the valid range.
--- Ajusts both `state.selected_index` and the actual window cursor position
---
--- @param delta integer: positive = down, negative = up
local function move_cursor(delta)
  local total = #state.get_results()
  if total == 0 then
    return
  end

  local new_index = math.max(1, math.min(state.get_selected_index() + delta, total))
  state.set_selected_index(new_index)

  local results_win = state.get_windows().results.win
  if results_win and vim.api.nvim_win_is_valid(results_win) then
    vim.api.nvim_win_set_cursor(results_win, { new_index, 0 })
  end
end

--- Close both picker windows and reset volatile state.
local function close_windows()
  local wins = state.get_windows()
  window.close(wins.search.win)
  window.close(wins.results.win)
  state.reset()
end

--- Render `entries` into the results buffer and resize the results window.
---
--- @param entries string[]
local function render(entries)
  local wins = state.get_windows()
  local display_lines = picker.display(entries)
  buffer.set_lines(wins.results.buf, display_lines)
  window.resize(wins.results.win, #display_lines)
end

--- Update the search window title to reflect the active source.
--- Called whenever the router switches source mid-query.
---
--- @param title string  Human-readable source label from the router result.
local function update_title(title)
  local wins = state.get_windows()
  local win = wins.search.win
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_set_config(win, {
      title = " " .. title .. " ",
    })
  end
end

--- Open the picker UI
---
--- Expects `picker.load()` to have already been called so that
--- `state.get_results()` is populated.
function M.open()
  -- Create buffers
  local search_buf = buffer.create({ modifiable = true })
  local results_buf = buffer.create({ modifiable = false })

  -- Compute layout geometry
  local results = state.get_results()
  local search_geo = layout.search()
  local results_geo = layout.results(#results)

  -- Open windows
  local search_win = window.open(search_buf, search_geo, {
    title = " Spot ",
    enter = true,
  })
  local results_win = window.open(results_buf, results_geo, {
    title = " Results ",
  })

  -- Persist handles
  state.set_search_window(search_buf, search_win)
  state.set_results_window(results_buf, results_win)

  -- Lifecycle: Closing the search window also closes results
  window.link_close(search_win, results_win)

  -- Highlight
  highlight.setup()
  highlight.apply(results_win)

  -- Initial render
  render(results)

  -- Search input wiring
  search.setup(search_buf, {
    on_change = function(query)
      local route = picker.update_query(query)

      -- Update the title bar to show the active source name
      update_title(route.title)

      render(state.get_results())

      -- Clamp cursro when the results seet skrinks
      if state.get_selected_index() > #state.get_results() then
        move_cursor(0)
      end
    end,
  })

  -- keymaps (actions injected explicitly - no hidden module coupling)
  keymaps.setup(search_buf, {
    cursor_down = function()
      move_cursor(1)
    end,
    cursor_up = function()
      move_cursor(-1)
    end,
    confirm = function()
      picker.execute_seleted(close_windows)
    end,
    close = function()
      close_windows()
    end,
  })

  -- Enter insert mode so the user can type inmediately
  vim.cmd("startinsert")
end

-- Close the picker progmmatically (e.g. from `:SpotClose`).
M.close = close_windows

return M
