local M = {}

M.entries = function(entries, query)
  if query == "" then
    return entries
  end

  query = query:lower()
  local results = {}

  for _, entry in ipairs(entries) do
    if entry:lower():find(query, 1, true) then
      table.insert(results, entry)
    end
  end

  return results
end

return M
