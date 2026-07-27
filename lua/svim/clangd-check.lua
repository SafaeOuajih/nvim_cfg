--- `:CcCheck`, a compile_commands.json sanity check for the current buffer.
---
--- Verified against clangd 21.1.8; the parsing below depends on its `--check`
--- output format.
---
--- clangd resolves a compilation database per file, walking up from the file to
--- the nearest `compile_commands.json` (or `build/` subdirectory). In a tree
--- that holds several of them, the one it picks is not always the one you
--- expect, and when a file has no entry clangd silently *infers* flags from an
--- unrelated neighbour. That inference is the usual cause of a file that reports
--- nonsense errors while its neighbours are fine.
---
--- `clangd --check` reports all of this, so this module runs it on the current
--- buffer, reports which database was used and where the flags came from, and
--- sends the diagnostics to the quickfix list. `--check` only reports errors, so
--- warnings are taken from the live clangd client attached to the buffer.

local M = {}

--- Filetypes `--check` can be run on.
local supported = { c = true, cpp = true, objc = true, objcpp = true, cuda = true }

--- How long to wait for clangd before giving up. Checking a translation unit
--- with a large preamble (a kernel source file, say) is not fast.
local timeout_ms = 180000

--- Where the flags for the checked file came from. Only `cdb` means the file
--- genuinely has its own entry in the database.
---@alias CcOrigin 'cdb'|'inferred'|'fallback'

---@class CcReport
---@field database string|nil path of the compilation database clangd loaded
---@field origin CcOrigin|nil
---@field inferred_from string|nil file the flags were copied from, when inferred
---@field command string|nil the compile command clangd ended up using
---@field errors integer|nil error count reported by `--check`
---@field preamble_failed boolean the translation unit did not parse at all
---@field items table[] quickfix entries

--- Pull the interesting lines out of `clangd --check` output.
---@param out string combined stdout and stderr
---@param file string absolute path of the checked file
---@return CcReport
local function parse(out, file)
  local report = { items = {}, preamble_failed = false }

  for line in vim.gsplit(out, '\n', { plain = true }) do
    -- Strip the `I[12:34:56.789] ` severity and timestamp prefix.
    local severity, body = line:match '^(%a)%[[%d:%.]+%]%s+(.*)$'
    if body then
      local db = body:match '^Loaded compilation database from (.+)$'
      local inferred = body:match '^Compile command inferred from (.+) is:'
      local diag_rule, diag_line, diag_msg = body:match '^%[(.-)%] Line (%d+): (.+)$'

      if db then
        report.database = db
      elseif body:match '^Failed to find compilation database' then
        report.origin = 'fallback'
      elseif inferred then
        report.origin, report.inferred_from = 'inferred', inferred
        report.command = body:match ' is: (.+)$'
      elseif body:match '^Compile command from CDB is:' then
        report.origin = 'cdb'
        report.command = body:match ' is: (.+)$'
      elseif body:match '^Generic fallback command is:' then
        report.origin = 'fallback'
        report.command = body:match ' is: (.+)$'
      elseif body:match '^Failed to build preamble' then
        report.preamble_failed = true
      elseif body:match '^error:' then
        -- A diagnostic raised before the file could be parsed - a bad `-target`
        -- or a missing sysroot, say. These carry no line number.
        table.insert(report.items, {
          filename = file,
          lnum = 0,
          col = 1,
          type = 'E',
          text = body,
        })
      elseif diag_line then
        table.insert(report.items, {
          filename = file,
          lnum = tonumber(diag_line),
          col = 1,
          type = severity == 'E' and 'E' or 'W',
          text = ('%s [%s]'):format(diag_msg, diag_rule),
        })
      else
        local count = body:match '^All checks completed, (%d+) errors?$'
        if count then
          report.errors = tonumber(count)
        end
      end
    end
  end

  return report
end

--- Collect warnings from the clangd client attached to the buffer. `--check`
--- reports errors only, so anything below that severity has to come from the
--- live server.
---@param bufnr integer
---@return table[] quickfix entries
local function live_warnings(bufnr)
  local clangd = vim.lsp.get_clients { bufnr = bufnr, name = 'clangd' }[1]
  if not clangd then
    return {}
  end

  local diags = vim.diagnostic.get(bufnr, {
    severity = { min = vim.diagnostic.severity.HINT, max = vim.diagnostic.severity.WARN },
  })

  local items = {}
  for _, d in ipairs(diags) do
    -- `vim.diagnostic.get` cannot filter on the client, and harper_ls attaches
    -- to C buffers too, so keep only what clangd's own namespace produced.
    local ns = d.namespace and vim.diagnostic.get_namespace(d.namespace)
    if ns and ns.name and ns.name:find('clangd', 1, true) then
      table.insert(items, {
        bufnr = bufnr,
        lnum = d.lnum + 1,
        col = d.col + 1,
        type = 'W',
        text = ('%s [%s]'):format(d.message, d.code or d.source or 'clangd'),
      })
    end
  end
  return items
end

--- Render the report as the message shown once the check finishes.
---@param report CcReport
---@param file string
---@return string message
---@return integer level a `vim.log.levels` value
local function summarise(report, file)
  local lines = { ('file      %s'):format(vim.fn.fnamemodify(file, ':~:.')) }
  local level = vim.log.levels.INFO

  table.insert(lines, ('database  %s'):format(report.database or 'none found'))

  if report.origin == 'cdb' then
    table.insert(lines, 'entry     exact match in the database')
  elseif report.origin == 'inferred' then
    level = vim.log.levels.WARN
    table.insert(lines, 'entry     MISSING - flags inferred from another file:')
    table.insert(lines, ('          %s'):format(vim.fn.fnamemodify(report.inferred_from, ':~:.')))
  elseif report.origin == 'fallback' then
    level = vim.log.levels.WARN
    table.insert(lines, 'entry     MISSING - clangd fell back to a generic command')
  end

  if report.preamble_failed then
    level = vim.log.levels.ERROR
    table.insert(lines, 'preamble  FAILED to build - the file did not parse at all')
  end

  local warnings, counted_errors = 0, 0
  for _, item in ipairs(report.items) do
    if item.type == 'W' then
      warnings = warnings + 1
    else
      counted_errors = counted_errors + 1
    end
  end

  -- clangd only prints its own tally when it gets to the end; if it bailed out
  -- early, fall back to what was collected.
  local errors = report.errors or counted_errors
  if errors > 0 then
    level = vim.log.levels.ERROR
  end
  table.insert(lines, ('result    %d error(s), %d warning(s)'):format(errors, warnings))

  if #report.items > 0 then
    table.insert(lines, '           -> quickfix list (:copen)')
  end

  return table.concat(lines, '\n'), level
end

--- Run `clangd --check` on a buffer and report what it found.
---@param bufnr integer
local function check(bufnr)
  local file = vim.api.nvim_buf_get_name(bufnr)
  if file == '' then
    vim.notify('CcCheck: buffer has no file', vim.log.levels.ERROR)
    return
  end

  if not supported[vim.bo[bufnr].filetype] then
    vim.notify(('CcCheck: %s is not a C/C++ buffer'):format(vim.bo[bufnr].filetype), vim.log.levels.ERROR)
    return
  end

  -- Prefer the binary the clangd config points at, so the check and the editing
  -- session cannot disagree about which clangd is in use.
  local configured = (vim.lsp.config.clangd or {}).cmd
  local exe = (type(configured) == 'table' and configured[1]) or 'clangd'
  if vim.fn.executable(exe) == 0 then
    vim.notify(('CcCheck: %s is not executable'):format(exe), vim.log.levels.ERROR)
    return
  end

  vim.notify(('CcCheck: running %s --check ...'):format(exe), vim.log.levels.INFO)

  vim.system({ exe, '--check=' .. file }, {
    cwd = vim.fs.dirname(file),
    text = true,
    timeout = timeout_ms,
  }, function(res)
    vim.schedule(function()
      if res.code ~= 0 and res.stdout == '' and res.stderr == '' then
        vim.notify(('CcCheck: clangd exited with %d'):format(res.code), vim.log.levels.ERROR)
        return
      end

      local report = parse((res.stdout or '') .. (res.stderr or ''), file)

      -- Warnings are read once the check is done rather than up front: the
      -- buffer cannot have changed meanwhile, and by now the attached server
      -- has had time to publish.
      vim.list_extend(report.items, live_warnings(bufnr))

      if #report.items > 0 then
        vim.fn.setqflist({}, ' ', { title = 'CcCheck ' .. vim.fn.fnamemodify(file, ':t'), items = report.items })
      end

      local msg, level = summarise(report, file)
      vim.notify(msg, level, { title = 'CcCheck' })
    end)
  end)
end

vim.api.nvim_create_user_command('CcCheck', function()
  check(vim.api.nvim_get_current_buf())
end, { desc = 'Check the current file against its compile_commands.json' })

M.check = check

return M
