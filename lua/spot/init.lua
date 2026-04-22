local config = require("spot.config")
local state = require("spot.state")

local finder = require("spot.finder")
local ui = require("spot.ui")

local M = {}

M.setup = config.setup

function M.reset()
  state.files = finder.load()
  state.entries = state.files

  state.search = nil
  state.index = 1

  state.origin.win = vim.api.nvim_get_current_win()
end

function M.open()
  M.reset()
  ui.open()
end

return M
