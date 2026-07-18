--- Keymaps that are not tied to any particular plugin.
--- Plugin-specific keymaps live next to the plugin declaration in
--- `lua/svim/plugins/<file>`.

--- Wrapper around `vim.keymap.set` that always sets `noremap` and `silent`.
---@param mode string|string[]
---@param lhs string
---@param rhs string|function
---@param desc string?
local keymap = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, desc = desc })
end

-- Quick save
keymap('n', '<leader>w', '<cmd>write!<cr>', '[W]rite buffer')

-- Add an undo break before typing punctuation, so a long insert can be undone
-- in meaningful chunks instead of all at once.
keymap('i', ',', ',<C-g>u')
keymap('i', '.', '.<C-g>u')
keymap('i', '!', '!<C-g>u')
keymap('i', '?', '?<C-g>u')
keymap('i', ':', ':<C-g>u')

-- Tabs
keymap('n', ']t', '<cmd>tabnext<cr>', '[T]ab [N]ext')
keymap('n', '[t', '<cmd>tabprev<cr>', '[T]ab [P]rev')
keymap('n', '<leader>te', '<cmd>tabedit<cr>', '[T]ab [E]dit')
keymap('n', '<leader>ts', '<cmd>tab split<cr>', '[T]ab [S]plit')

-- Keep the cursor in place when joining lines
keymap('n', 'J', 'mzJ`z')
-- Join the line above onto the end of the current line
keymap('n', '<leader>j', [[<cmd>m-2|j<cr>]], '[J]oin line above after this line')

-- Clear search highlighting
keymap('n', '<leader><leader>', '<cmd>noh<cr>', 'Clear search highlighting')

-- Paste from the system clipboard
keymap('n', '<leader>cp', '"+p', '[P]aste from [C]lipboard after cursor')
keymap('n', '<leader>cP', '"+P', '[P]aste from [C]lipboard before cursor')

-- Linewise text object
keymap('x', 'il', 'g_o^')
keymap('o', 'il', '<cmd>normal vil<cr>')
keymap('x', 'al', '$o0')
keymap('o', 'al', '<cmd>normal val<cr>')
-- Whole-buffer text object
keymap('x', 'i%', 'GoggV')
keymap('o', 'i%', '<cmd>normal vi%<cr>')

-- Diagnostics and code actions
keymap('n', '<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
keymap('v', '<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
keymap('n', '<leader>do', vim.diagnostic.open_float, '[D]iagnostic [O]pen')
keymap('n', '<leader>dr', vim.diagnostic.reset, '[D]iagnostic [R]eset')
keymap('n', '[d', function()
  vim.diagnostic.jump { count = -1, float = true }
end, 'Prev [D]iagnostic')
keymap('n', ']d', function()
  vim.diagnostic.jump { count = 1, float = true }
end, 'Next [D]iagnostic')
keymap('n', '<leader>dq', vim.diagnostic.setloclist, '[D]iagnostic [Q]uickfix')

-- Open the directory of the current file
keymap('n', '<leader>o', function()
  vim.cmd.edit(vim.fn.expand '%:p:h')
end, "[O]pen file's directory")
keymap('n', '<leader>f', 'gq%', '[F]ormat')

-- Yank the name or path of the current file to both the unnamed and system
-- clipboards.
keymap('n', '<leader>yf', function()
  vim.fn.setreg('@', vim.fn.expand '%:t')
  vim.fn.setreg('+', vim.fn.expand '%:t')
end, '[Y]ank [F]ilename of current file')
keymap('n', '<leader>yp', function()
  vim.fn.setreg('@', vim.fn.expand '%:p')
  vim.fn.setreg('+', vim.fn.expand '%:t')
end, '[Y]ank [P]ath to current file')

-- Terminal mode escapes
keymap('t', '<Esc><Esc>', '<C-\\><C-n>', 'Terminal normal mode')
keymap('t', '<C-space>', '<C-\\><C-n>', 'Terminal normal mode')
keymap('t', '<C-w>', '<C-\\><C-n><C-w>')

-- Yank / paste using the system clipboard explicitly
keymap('n', '<leader>y', '"+y', 'Yank to clipboard')
keymap('v', '<leader>y', '"+y', 'Yank to clipboard')
keymap('n', '<leader>Y', '"+Y', 'Yank line to clipboard')
keymap('n', '<leader>p', '"+p', '[P]aste from clipboard after cursor')
keymap('n', '<leader>P', '"+P', '[P]aste from clipboard before cursor')
keymap('v', '<leader>p', '"+p', '[P]aste from clipboard (visual)')

-- Telescope shortcuts
keymap('n', 'ff', '<cmd>Telescope find_files<cr>', '[F]ind [F]iles')
keymap('n', 'fg', '<cmd>Telescope live_grep<cr>', '[G]rep')

-- Execute Lua straight from the current buffer, useful while editing config.
---@param mode 'n'|'v'
local function executor(mode)
  if vim.bo.filetype ~= 'lua' then
    return
  end
  if mode == 'n' then
    assert(loadstring(vim.api.nvim_get_current_line()))()
  else
    local region = vim.fn.getregion(vim.fn.getpos '.', vim.fn.getpos 'v', { type = vim.fn.mode() })
    local exe = table.concat(region, '\n')
    loadstring(exe)()
  end
end
keymap('n', '<leader>x', function()
  executor 'n'
end, 'E[x]ecute current line as Lua')
keymap('v', '<leader>x', function()
  executor 'v'
end, 'E[x]ecute current selection as Lua')

local function save_and_exec_file()
  if vim.bo.filetype ~= 'lua' then
    return
  end
  vim.cmd [[silent! write]]
  vim.cmd.luafile(vim.fn.expand '%')
end
keymap('n', '<leader><leader>x', save_and_exec_file, 'E[x]ecute the current Lua file')

--- `gf` only searches `&path`, which knows nothing about the include
--- directories of a compile database. On an `#include` line, ask the language
--- server instead: it resolves the header using the real compile flags.
local function goto_file()
  local line = vim.api.nvim_get_current_line()
  if line:match '^%s*#%s*include' then
    for _, client in ipairs(vim.lsp.get_clients { bufnr = 0 }) do
      if client:supports_method 'textDocument/definition' then
        vim.lsp.buf.definition()
        return
      end
    end
  end
  -- Not an include, or no server attached: keep the default behaviour.
  local ok, err = pcall(vim.cmd, 'normal! gf')
  if not ok then
    vim.notify(err, vim.log.levels.WARN)
  end
end
keymap('n', 'gf', goto_file, '[G]oto [F]ile under cursor')

-- `gd`/`gD` are not mapped to the language server by default: the builtin ones
-- only look in the current file. Cross-file jumps also need the background
-- index (e.g. clangd) to be built.
keymap('n', 'gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
keymap('n', 'gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
