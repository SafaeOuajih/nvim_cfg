--- Helper functions exposed as globals so they can be used from anywhere,
--- including the command line, without an explicit `require`.

-- selene: allow(incorrect_standard_library_use)

--- Pretty-print a value and return it unchanged.
--- Useful for quickly inspecting the content of a table while debugging.
---@param v any Any value that can be inspected
---@return any v The same value, returned as-is
P = function(v)
  print(vim.inspect(v))
  return v
end
