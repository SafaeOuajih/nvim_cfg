--- Small utility helpers shared across the configuration.

local M = {}

---@alias SystemDependency string
---@alias EitherSystemDep SystemDependency[] at least one of these must be available
---@alias SystemDep SystemDependency[]
---@alias SystemDeps (SystemDependency|EitherSystemDep)

--- Check for system dependencies.
--- When an argument is a table, it is treated as a "one of" requirement: the
--- dependency is satisfied as long as one of the listed executables is found.
---@param ... SystemDeps
---@return SystemDep missing the dependencies that could not be found
local system_deps = function(...)
  local args = { n = select('#', ...), ... }
  local missing = {}
  for i = 1, args.n do
    local dep = args[i]
    if type(dep) == 'table' then
      local found = false
      for _, opt_dep in pairs(dep) do
        if vim.fn.executable(opt_dep) == 1 then
          found = true
          break
        end
      end
      if not found then
        table.insert(missing, dep)
      end
    elseif type(dep) == 'string' then
      if vim.fn.executable(dep) ~= 1 then
        table.insert(missing, dep)
      end
    else
      error 'dependency is either a string or an array of strings'
    end
  end
  return missing
end

---@alias augroup integer

--- Create (and clear) an autocommand group.
---@param name string
---@return augroup
M.augroup = function(name)
  return vim.api.nvim_create_augroup(name, { clear = true })
end

---@alias AuCmdCallback string|function

---@class AuCmdSpec
---@field [1] string event name
---@field [2] augroup
---@field [3] AuCmdCallback
---@field [4] integer|nil buffer
---@field once boolean whether the autocmd should run only once
---@field desc string autocmd description

--- Create an autocommand from a positional spec.
---
--- ```lua
--- autocmd_s { 'BufEnter', augroup 'MyGroup', function() print 'entered' end, 0,
---   desc = 'My autocmd',
--- }
--- ```
---@param args AuCmdSpec
M.autocmd_s = function(args)
  local event = args[1]
  local group = args[2]
  local callback = args[3]

  vim.api.nvim_create_autocmd(event, {
    group = group,
    buffer = args[4],
    callback = function()
      callback()
    end,
    once = args.once,
    desc = args.desc,
  })
end

M.autocmd = vim.api.nvim_create_autocmd

--- Warn once if any of the given dependencies are missing.
---@param deps SystemDeps[]
---@param name string label used in the notification
local function check_system_deps(deps, name)
  local missing = system_deps(deps)
  if #missing == 0 then
    return
  end

  local msg
  if #missing > 1 then
    msg = 'are'
  else
    msg = 'is'
  end

  msg = ('%q %s not installed'):format(missing, msg)
  vim.notify(msg, vim.log.levels.WARN, { title = name })
end

M.check_system_deps = check_system_deps
M.system_deps = system_deps

return M
