-- flatten.nvim: running `nvim <file>` inside a terminal buffer opens the file
-- in the surrounding instance instead of starting a nested editor. Without it,
-- `:q` is ambiguous: it targets whichever instance owns the keystrokes, and
-- once the nested one exits the next `:q` closes the host's terminal window.

-- Height left to the terminal when a file has to be split off it, matching the
-- size toggleterm gives a horizontal terminal.
local TERM_HEIGHT = 15

--- Which terminal window a file window belongs to. Without this, a second
--- terminal reuses the window the first one opened and the two fight over it:
--- every file, whichever terminal it came from, lands in the same place.
---@type table<Flatten.WindowId, Flatten.WindowId>
local owner_of = {}

--- A window is a target for `term_win` if it is an ordinary file window that no
--- other live terminal has claimed.
---@param win Flatten.WindowId?
---@param term_win Flatten.WindowId
local function usable(win, term_win)
  if not (win and vim.api.nvim_win_is_valid(win)) then
    return false
  end
  if vim.api.nvim_win_get_config(win).relative ~= '' then
    return false -- a float
  end
  if vim.bo[vim.api.nvim_win_get_buf(win)].buftype ~= '' then
    return false
  end
  local owner = owner_of[win]
  return owner == nil or owner == term_win or not vim.api.nvim_win_is_valid(owner)
end

--- The window `term_win` should put its file in, or nil if it needs a new one.
---@param term_win Flatten.WindowId
---@return Flatten.WindowId?
local function target_window(term_win)
  -- The window this terminal opened earlier, if it is still around. Closing the
  -- file with `:q` drops the claim, so the next open splits a fresh one.
  for win, owner in pairs(owner_of) do
    if not vim.api.nvim_win_is_valid(win) then
      owner_of[win] = nil
    elseif owner == term_win and usable(win, term_win) then
      return win
    end
  end

  -- Otherwise any unclaimed file window: this is the toggleterm layout, one
  -- terminal beside the file window it should be editing in.
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if usable(win, term_win) then
      return win
    end
  end
end

--- Put the file in a real file window, splitting one off the terminal when that
--- terminal has none of its own. Flatten's builtin `smart_open` reuses any file
--- window in the tab, and the window it falls back to creating is an even split.
---@param ctx Flatten.OpenContext
---@return Flatten.BufferId?, Flatten.WindowId?
local function open_file_window(ctx)
  -- `files` holds BufInfo tables by the time a handler sees them, not names.
  local focus = ctx.stdin_buf or ctx.files[1]
  if not focus then
    return
  end

  local cur = vim.api.nvim_get_current_win()
  local from_terminal = vim.bo[vim.api.nvim_win_get_buf(cur)].buftype == 'terminal'
  if not from_terminal then
    -- Not launched from a terminal, so there is no layout to protect.
    local win = require('flatten.core').smart_open() or cur
    vim.api.nvim_win_set_buf(win, focus.bufnr)
    vim.api.nvim_set_current_win(win)
    return focus.bufnr, win
  end

  local win = target_window(cur)
  if not win then
    local available = vim.api.nvim_win_get_height(cur)
    vim.cmd 'aboveleft split'
    win = vim.api.nvim_get_current_win()
    -- Cap the strip at a third of the space, so the file still gets the bigger
    -- share on a screen too short for `TERM_HEIGHT` to leave one.
    local height = math.max(3, math.min(TERM_HEIGHT, math.floor(available / 3)))
    vim.api.nvim_win_set_height(cur, height)
  end
  owner_of[win] = cur

  vim.api.nvim_win_set_buf(win, focus.bufnr)
  vim.api.nvim_set_current_win(win)
  -- Buffer first: the `Flatten.OpenHandler` alias has the pair the wrong way
  -- round, `core.lua` destructures `bufnr, winnr`. Both are needed for
  -- `block_for` to work.
  return focus.bufnr, win
end

---@type LazyPluginSpec
return {
  'willothy/flatten.nvim',
  -- Must be loaded before anything can open a terminal, so no lazy loading.
  lazy = false,
  priority = 1001,
  ---@module "flatten"
  ---@type Flatten.PartialConfig
  opts = {
    window = {
      -- Neither builtin mode fits: 'alternate' drops the file into the terminal
      -- window when that is the only one open (`winnr('#')` is 0), and 'smart'
      -- gets the window right but splits it evenly.
      open = open_file_window,
    },
    hooks = {
      -- `nvim --headless` from an embedded terminal is a script, not a request
      -- to edit something: run it in place rather than forwarding its arguments
      -- to the host. Flatten has no notion of headless on its own, so without
      -- this every scripted nvim invocation gets hijacked.
      should_nest = function()
        return #vim.api.nvim_list_uis() == 0
      end,
    },
    -- Blocking for `gitcommit` and `gitrebase` is already the default, so
    -- `git commit` from this terminal waits for the buffer to be closed.
  },
}
