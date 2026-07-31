--- Preferences for builtin Neovim options, plus a handful of small autocommands.

local opt = vim.opt

opt.mouse = 'nv' -- Enable the mouse in normal and visual mode only
opt.autoread = true -- Reload files that changed outside of Neovim
opt.history = 500 -- Number of commands to remember
opt.scrolloff = 4 -- Keep 4 lines visible above/below the cursor
opt.scrollback = 100000 -- Maximum scrollback in terminal buffers
opt.number = true -- Show line numbers
opt.relativenumber = true -- Show relative line numbers
opt.cmdheight = 1 -- Command window height
opt.wildignore = { '*.o', '*~', '*.pyc', '*/.git/*', '*/.hg/*', '*/.svn/*', '*/.DS_Store' }
opt.backspace = { 'eol', 'start', 'indent' } -- Make backspace behave as expected
opt.swapfile = false -- Do not use swap files
opt.magic = true -- Enable "magic" characters in regular expressions
opt.showmatch = true -- Briefly jump to the matching bracket
opt.mat = 2 -- Tenths of a second to show the matching bracket
opt.fileformats = { 'unix', 'dos', 'mac' }
opt.timeoutlen = 500 -- Time (ms) allowed to complete a mapping
opt.updatetime = 500 -- Time (ms) before the `CursorHold` event fires
opt.hidden = true -- Keep background buffers loaded

-- Splits
opt.splitright = true -- Open vertical splits on the right

-- Show a subset of otherwise invisible characters
opt.listchars = { tab = '▸ ', trail = '·' }
opt.list = true

-- Disable every kind of bell
opt.errorbells = false
opt.visualbell = false
vim.cmd [[set t_vb=]] -- Also disable the terminal visual bell
opt.belloff = 'all'
opt.termguicolors = true -- Enable 24-bit RGB colors

-- Line wrapping
opt.linebreak = true
opt.textwidth = 120

-- Tabs / spaces
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.expandtab = false

-- Indentation
opt.autoindent = true
opt.smartindent = true
opt.wrap = true
opt.signcolumn = 'yes'

-- Search
opt.ignorecase = true -- Ignore case when searching
opt.smartcase = true -- ...unless the query contains an uppercase letter
opt.hlsearch = true -- Highlight all matches of the last search
opt.incsearch = true -- Highlight matches while typing

-- Persistent undo history
opt.undodir = vim.fn.stdpath 'data' .. '/undodir'
opt.undofile = true

-- Spell checking (off by default, enabled per filetype)
opt.spell = false
opt.spelllang = { 'en_us' }

-- Completion
opt.completeopt = { 'menu', 'menuone', 'preview' }
opt.shortmess:append 'c'

-- Status line
opt.laststatus = 3 -- Use a single global status line
opt.showmode = false -- Mode is already shown in the status line

-- Folds: keep everything unfolded and hide the fold column
opt.foldlevelstart = 99
opt.foldcolumn = '0'

opt.conceallevel = 2 -- Conceal markup such as markdown syntax
opt.concealcursor = 'nc' -- Keep text concealed in normal and command mode

-- Open diffs in vertical splits
opt.diffopt:append 'vertical'

-- Automatic formatting options (see `:h fo-table`)
opt.formatoptions = opt.formatoptions
  + 't' -- Auto-wrap text at textwidth
  + 'c' -- Auto-wrap comments at textwidth
  + 'r' -- Continue the comment leader after <Enter>
  - 'o' -- ...but not after o/O in normal mode
  + 'q' -- Allow formatting comments with gq
  - 'a' -- Do not auto-format paragraphs
  + 'n' -- Recognise numbered lists while formatting
  + '1' -- Do not break a line right after a one-letter word
  + 'j' -- Remove comment leaders when joining lines

-- Make the jump list behave like a stack and restore the view when jumping
-- back, so <C-o>/<C-i> return to where the cursor actually was.
opt.jumpoptions = opt.jumpoptions + 'stack' + 'view'

vim.g.python3_host_prog = 'python3'
vim.g.loaded_python_provider = 0

-- Always use the system clipboard for yanks and pastes
vim.opt.clipboard = 'unnamedplus'

-- Extra filetype detection
vim.filetype.add {
  filename = {
    Scratch = 'markdown', -- Treat a file literally named "Scratch" as markdown
  },
}

local autocmd = require('svim.utils').autocmd
local augroup = require('svim.utils').augroup

autocmd('BufReadPost', {
  group = augroup 'AutoReturnToLastPos',
  desc = 'Return to the last edit position when opening a file',
  pattern = '*',
  callback = function()
    if vim.fn.line '\'"' > 1 and vim.fn.line '\'"' <= vim.fn.line '$' then
      vim.cmd [[normal! g'"]]
    end
  end,
})

autocmd('FileType', {
  pattern = 'help',
  group = augroup 'AutoHelpVerticalSplit',
  desc = 'Open help pages in a vertical split',
  callback = function()
    vim.cmd.wincmd 'L'
  end,
})

autocmd('TermOpen', {
  group = augroup 'AutoTermInsertMode',
  desc = 'Enter insert mode when opening a terminal',
  pattern = '*',
  command = 'startinsert',
})

-- Keep Neovim's working directory in sync with the shell running in a terminal
-- buffer. The shell has to advertise its cwd with an OSC 7 escape sequence:
-- fish does this out of the box, bash/zsh need a hook (see :help terminal-osc7).
local term_cwd_group = augroup 'TermFollowCwd'

--- `:cd` to `dir`, unless we are already there.
---@param dir string
local function chdir(dir)
  if vim.fn.getcwd() ~= dir and vim.fn.isdirectory(dir) == 1 then
    vim.cmd.cd(vim.fn.fnameescape(dir))
  end
end

--- Extract the (percent-decoded) path from an OSC 7 sequence, if it is one.
---@param sequence string
---@return string?
local function osc7_dir(sequence)
  local path = sequence:match '^\027]7;file://[^/]*(/[^\027\a]*)'
  if not path then
    return nil
  end
  return (path:gsub('%%(%x%x)', function(hex)
    return string.char(tonumber(hex, 16))
  end))
end

autocmd('TermRequest', {
  group = term_cwd_group,
  desc = 'Follow the shell working directory announced via OSC 7',
  callback = function(ev)
    local dir = osc7_dir(ev.data.sequence)
    if not dir then
      return
    end
    vim.b[ev.buf].osc7_dir = dir
    if vim.api.nvim_get_current_buf() == ev.buf then
      chdir(dir)
    end
  end,
})

autocmd({ 'BufEnter', 'WinEnter' }, {
  group = term_cwd_group,
  desc = 'Restore the shell working directory when returning to a terminal',
  callback = function()
    if vim.b.osc7_dir then
      chdir(vim.b.osc7_dir)
    end
  end,
})

autocmd('TextYankPost', {
  group = augroup 'Highlight_Yank',
  desc = 'Briefly highlight the yanked text',
  pattern = '*',
  callback = function()
    vim.highlight.on_yank { higroup = 'IncSearch', timeout = 500 }
  end,
})

autocmd('VimLeavePre', {
  group = augroup 'TerminalForceClose',
  desc = 'Force close every terminal buffer on quit',
  pattern = '*',
  callback = function()
    local term_bufs = vim.fn.filter(vim.fn.range(1, vim.fn.bufnr '$'), function(idx, val)
      return vim.fn.getbufvar(val, '&buftype') == 'terminal'
    end)

    for _, t in ipairs(term_bufs) do
      vim.api.nvim_buf_delete(t, { force = true })
    end
  end,
})

-- Disable entering Ex mode by accident
vim.keymap.set('n', 'Q', '', { noremap = true })
