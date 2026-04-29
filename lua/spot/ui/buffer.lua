local M = {}

--- Create a scratch buffer with standard spot options applied.
---
--- @param opts spot.Buffer.Opts
--- @return integer buf
function M.create(opts)
  local buf = vim.api.nvim_create_buf(false, true)

  local set = function(name, value)
    vim.api.nvim_set_option_value(name, value, { buf = buf })
  end

  set("buftype", "nofile")
  set("bufhidden", "wipe")
  set("swapfile", false)
  set("modifiable", opts.modifiable == true)

  return buf
end

--- Replace all lines in a buffer.
---
--- Temporarily enables `modifiable` regardless of the buffer's normal settings.
--- writes the new content, then restores the option to `false`.
--- This is the **only** sanctioned way to write to a results buffer from
--- outside `spot.ui`.
---
--- @param buf integer
--- @param lines string[]
function M.set_lines(buf, lines)
  print("Buf: ", buf)
  vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
end

return M
