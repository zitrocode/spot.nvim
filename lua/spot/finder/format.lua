local M = {}

local function get_depth(path)
  local depth = 0

  for _ in path:gmatch("/") do
    depth = depth + 1
  end

  return depth
end

function M.sort(entries)
  local stat_cache = {}

  local function is_directory(path)
    if stat_cache[path] ~= nil then
      return stat_cache[path]
    end

    local stat = vim.loop.fs_stat(path)
    local is_dir = stat and stat.type == "directory"

    stat_cache[path] = is_dir
    return is_dir
  end

  table.sort(entries, function(a, b)
    local depth_a = get_depth(a)
    local depth_b = get_depth(b)

    if depth_a ~= depth_b then
      return depth_a > depth_b
    end

    local a_is_dir = is_directory(a)
    local b_is_dir = is_directory(b)

    if a_is_dir ~= b_is_dir then
      return not a_is_dir
    end

    return a < b
  end)

  return entries
end

local function split_path(path)
  local name = vim.fs.basename(path)
  local parent = vim.fs.dirname(path)

  parent = parent == "." and "" or parent

  return name, parent
end

local function max_name_length(entries)
  local max_len = 0

  for _, path in ipairs(entries) do
    local name = vim.fs.basename(path)

    if #name > max_len then
      max_len = #name
    end
  end

  return max_len
end

function M.display(entries)
  local lines = {}
  local max_len = max_name_length(entries)

  for _, path in ipairs(entries) do
    local name, parent = split_path(path)
    local padding = string.rep(" ", max_len - #name + 4)

    table.insert(lines, name .. padding .. parent)
  end

  return lines
end

return M
