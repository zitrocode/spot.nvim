local spot = require("spot")

-- Open the finder `:Spot`
vim.api.nvim_create_user_command("Spot", function()
  spot.open()
end, { desc = "Open spot.nvim file finder" })
