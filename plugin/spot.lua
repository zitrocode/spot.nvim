--- Entry point for spot.nvim
---
--- This file is loaded automatically by Neovim when the plugin is installed.
--- It is responsable only for registering user-facing commands.
--- All logic lives in the `lua/spot/` modules, keeping this intentionally thin.
---
--- Commands are idepotent: calling `:Spot` twice is safe.

local spot = require("spot")

--- Register a single user command.
---
--- @param name string: the command name (e.g. "Spot").
--- @param callback function(): the function to invoke.
--- @param desc string: A human-readable shown in `:help` and completion
local function create_command(name, callback, desc)
  vim.api.nvim_create_user_command(name, callback, { desc = desc })
end

create_command("Spot", spot.open, "Open the spot.nvim picker")
create_command("SpotFocus", spot.focus, "Focus the spot.nvim picker")
create_command("SpotClose", spot.close, "Close the spot.nvim picker")
create_command("SpotToggle", spot.toggle, "Toggle the spot.nvim picker")
