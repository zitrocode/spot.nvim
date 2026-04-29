local M = {}

-- Internal helpers

--- Count the number of path separators in `path` to derive its nesting depth.
---
--- @param path string
--- @return integer
local function path_depth(path)
  local depth = 0
  for _ in path:gmatch("/") do
    depth = depth + 1
  end
  return depth
end

--- Resolve whether `path` points to a directory, caching results to avoid
--- repeated `uv.fs_stat` calls during a single sort pase.
---
--- @param path string
--- @param cache table<string, boolean>
--- @return boolean
local function is_directory(path, cache)
  if cache[path] ~= nil then
    return cache[path]
  end

  local stat = vim.uv.fs_stat(path)
  cache[path] = stat ~= nil and stat.type == "directory"
  return cache[path]
end

--- Sort entries son that:
---   1. Deeper paths appear before shallower ones (more specific first).
---   2. Files appear before directories at the same depth.
---   3. Ties are resolved alphanetically.
---
--- @param entries string[]
--- @return string[]
local function sort_entries(entries)
  local cache = {}
  table.sort(entries, function(a, b)
    local da, db = path_depth(a), path_depth(b)
    if da ~= db then
      return da > db
    end

    local a_dir = is_directory(a, cache)
    local b_dir = is_directory(b, cache)
    if a_dir ~= b_dir then
      return not a_dir
    end

    return a < b
  end)

  return entries
end

--- Find the longest basename in `entries` to compute display column padding
---
--- @param entries string[]
--- @return integer
local function max_basename_lenght(entries)
  local max = 0
  for _, path in ipairs(entries) do
    local len = #vim.fs.basename(path)
    if len > max then
      max = len
    end
  end

  return max
end

-- Source interface
M.name = "files"

--- Load file entries from the filesystem using `fd`.
--- Falls back to an empty list with a warning if `fd` is not available.
---
--- @return string[]
function M.load()
  local ok, results = pcall(vim.fn.systemlist, {
    "fd",
    "--type",
    "f",
    "--hidden",
    "--follow",
    "--exclude",
    ".git",
  })

  if not ok or vim.v.shell_error ~= 0 then
    vim.notify("spot: `fd` not found or returned an error. Install fd_find.", vim.log.levels.WARN)
    return {}
  end

  return sort_entries(results)
end

--- Format raw file path into two-columns display lines:
---   `basename    <padding>  parent/dir`
---
--- @param entries string[]
--- @return string[]
function M.display(entries)
  local max_len = max_basename_lenght(entries)
  local lines = {}

  for _, path in ipairs(entries) do
    local name = vim.fs.basename(path)
    local parent = vim.fs.dirname(path)

    parent = parent == "." and "" or parent

    local padding = string.rep(" ", max_len - #name + 4)
    table.insert(lines, name .. padding .. parent)
  end

  return lines
end

--- Open the selected file in the origin window.
---
--- @param entry string: the raw file path
--- @param state spot.State: current picker state (used to restore origin window).
function M.execute(entry, state)
  local origin = state.get_origin_win()
  if origin and vim.api.nvim_buf_is_valid(origin) then
    vim.api.nvim_set_current_win(origin)
  end

  vim.cmd.edit(vim.fn.fnameescape(entry))
end

return M
