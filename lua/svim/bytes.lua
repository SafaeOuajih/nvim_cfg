--- `:Bytes`, a size converter.
---
--- Sizes get quoted in four incompatible ways, and two of them look alike:
--- `MB` is 10^6 bytes, `MiB` is 2^20 bytes, and `Mb` is 10^6 *bits*. Flash
--- parts and link budgets are spec'd in bits, filesystems in bytes, so a
--- datasheet's "16Mb" chip holds 2MB. This prints all four at once so the
--- reading is never in doubt.
---
--- ```
--- :Bytes            the current file
--- :Bytes 3955504    a byte count
--- :Bytes 16Mb       a megabit part, to find out how many bytes it holds
--- :Bytes 1.5MiB
--- ```
---
--- In a unit, a trailing `B` means bytes and `b` means bits, an `i` selects the
--- 1024-based prefix, and a bare prefix (`16M`) is read as bytes. Only the
--- trailing `B`/`b` is case-sensitive; `mib`, `MiB` and `MIB` are one unit.

local M = {}

--- Prefix letters, in ascending order of magnitude.
local prefixes = { '', 'k', 'm', 'g', 't', 'p' }

--- Units to report, as (base, counts-bits) pairs with their prefix spellings.
---@class Scale
---@field base integer 1000 or 1024
---@field bits boolean whether the unit counts bits rather than bytes
---@field units string[] ascending, starting at the unscaled unit

---@type Scale[]
local scales = {
  { base = 1000, bits = false, units = { 'B', 'kB', 'MB', 'GB', 'TB', 'PB' } },
  { base = 1024, bits = false, units = { 'B', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB' } },
  { base = 1000, bits = true, units = { 'b', 'kb', 'Mb', 'Gb', 'Tb', 'Pb' } },
  { base = 1024, bits = true, units = { 'b', 'Kib', 'Mib', 'Gib', 'Tib', 'Pib' } },
}

--- Position of a prefix letter in `prefixes`, or nil if it is not one.
---@param letter string
---@return integer|nil
local function magnitude(letter)
  for i, p in ipairs(prefixes) do
    if p == letter:lower() then
      return i - 1
    end
  end
end

--- Read a size into a number of bits.
---@param input string
---@return number|nil bits
---@return string|nil err
local function parse(input)
  local number, unit = input:match '^%s*([%d%.]+)%s*(%a*)%s*$'
  local value = tonumber(number)
  if not value then
    return nil, ('not a size: %s'):format(input)
  end
  if unit == '' then
    return value * 8 -- a bare number is a byte count
  end

  -- `B`/`b` is the only case-sensitive part, and it comes last: split it off,
  -- then read the prefix and the optional `i` ahead of it.
  local prefix, binary, kind = unit:match '^(%a?)([iI]?)([Bb])$'
  if not kind then
    -- No trailing B/b, so this is a bare prefix such as `16M` or `16Mi`.
    prefix, binary, kind = unit:match '^(%a?)([iI]?)$'
    if not prefix or prefix == '' then
      return nil, ('unknown unit: %s'):format(unit)
    end
    kind = 'B'
  end

  local exponent = magnitude(prefix)
  if not exponent then
    return nil, ('unknown unit: %s'):format(unit)
  end

  local base = binary:lower() == 'i' and 1024 or 1000
  local per_unit = base ^ exponent * (kind == 'b' and 1 or 8)
  return value * per_unit
end

--- Render a bit count in the largest unit of `scale` that leaves it above 1.
---@param bits number
---@param scale Scale
---@return string
local function render(bits, scale)
  local value = scale.bits and bits or bits / 8
  local i = 1
  while value >= scale.base and i < #scale.units do
    value = value / scale.base
    i = i + 1
  end

  -- The unscaled unit is a whole count; anything scaled needs enough digits to
  -- tell 3.772 MiB from 3.956 MB.
  local text = ('%d'):format(value)
  if i > 1 then
    text = (('%.3f'):format(value):gsub('0+$', ''):gsub('%.$', ''))
  end
  return ('%s %s'):format(text, scale.units[i])
end

--- Group digits in threes so a long byte count stays readable.
---@param n number
---@return string
local function group(n)
  local out = ('%d'):format(n):reverse():gsub('(%d%d%d)', '%1 '):reverse()
  return (out:gsub('^%s+', ''))
end

--- Convert a size and return the lines describing it.
---@param input string|nil a size, or nil/empty for the current file
---@return string[]|nil lines
---@return string|nil err
function M.convert(input)
  local bits, source

  if input and input ~= '' then
    local err
    bits, err = parse(input)
    if not bits then
      return nil, err
    end
    source = input
  else
    local file = vim.api.nvim_buf_get_name(0)
    if file == '' then
      return nil, 'buffer has no file; pass a size instead'
    end
    local stat = vim.uv.fs_stat(file)
    if not stat then
      return nil, ('cannot stat %s'):format(file)
    end
    bits, source = stat.size * 8, vim.fn.fnamemodify(file, ':~:.')
  end

  local lines = { ('%s  =  %s bytes'):format(source, group(bits / 8)) }
  for _, scale in ipairs(scales) do
    lines[#lines + 1] = ('  %-6s %s'):format(scale.bits and 'bits' or 'bytes', render(bits, scale))
  end
  return lines
end

vim.api.nvim_create_user_command('Bytes', function(opts)
  local lines, err = M.convert(opts.args)
  if not lines then
    vim.notify(('Bytes: %s'):format(err), vim.log.levels.ERROR)
    return
  end
  vim.notify(table.concat(lines, '\n'), vim.log.levels.INFO, { title = 'Bytes' })
end, { nargs = '?', desc = 'Convert a size between byte and bit units' })

return M
