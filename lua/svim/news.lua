--- `:News`, a feed reader in a terminal split.
---
--- Newsboat has no way to preselect a topic from its command line, so the
--- filtering is done by the `news` script on $PATH: it cuts the master urls
--- file down to the feeds carrying one tag and starts newsboat on that. This
--- module only owns the window, and takes its list of topics from the script
--- so the two never disagree about which tags exist.
---
--- ```
--- :News            every feed
--- :News embedded   embedded and Linux
--- :News politics
--- :News ai
--- ```
---
--- `<Tab>` completes the tags. Inside newsboat, `q` steps back out and quits,
--- which closes the split.

local M = {}

--- Topics the `news` script knows about. Asking it costs a process, and the
--- answer only changes when the urls file is edited, so it is cached for the
--- session; `:News!` drops the cache.
---@type string[]|nil
local tags

--- @return string[]
local function known_tags()
  if not tags then
    local out = vim.system({ 'news', '--tags' }, { text = true }):wait()
    tags = out.code == 0 and vim.split(vim.trim(out.stdout), '\n', { trimempty = true }) or {}
  end
  return tags
end

--- Open newsboat in a vertical split.
---@param tag string|nil a topic tag, or nil/empty for every feed
function M.open(tag)
  if vim.fn.executable 'news' ~= 1 then
    vim.notify('News: `news` is not on $PATH', vim.log.levels.ERROR, { title = 'News' })
    return
  end

  local cmd = { 'news' }
  if tag and tag ~= '' then
    cmd[#cmd + 1] = tag
  end

  -- `vnew` rather than `vsplit`: a terminal needs a buffer of its own, and
  -- splitting would hand it the one already on screen. Insert mode is entered
  -- by the TermOpen autocommand in `options.lua`.
  vim.cmd 'vnew'
  local win = vim.api.nvim_get_current_win()

  vim.bo.bufhidden = 'wipe'
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = 'no'
  vim.wo[win].winfixwidth = true

  vim.fn.jobstart(cmd, {
    term = true,
    on_exit = function(_, code)
      vim.schedule(function()
        -- Quitting newsboat should take the split with it instead of leaving a
        -- dead terminal behind, but a failed start has an error worth reading.
        if code == 0 and vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, true)
        end
      end)
    end,
  })
end

vim.api.nvim_create_user_command('News', function(opts)
  if opts.bang then
    tags = nil
  end
  M.open(opts.args)
end, {
  nargs = '?',
  bang = true,
  complete = function(lead)
    return vim.tbl_filter(function(tag)
      return vim.startswith(tag, lead)
    end, known_tags())
  end,
  desc = 'Read news feeds in a split, optionally filtered to one topic',
})

-- Lowercase command names are reserved for builtins, so the command has to be
-- `:News`. Expand `news` into it, but only as a whole command line, so the word
-- still means itself in `:s/news/olds/`.
vim.cmd [[cnoreabbrev <expr> news (getcmdtype() == ':' && getcmdline() ==# 'news') ? 'News' : 'news']]

return M
