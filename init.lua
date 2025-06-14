-------------------------------------------------------------------------------
-- svim - a personal Neovim configuration
--
-- Entry point sourced by Neovim on startup. It configures the core editor and
-- then hands plugin management over to lazy.nvim.
-------------------------------------------------------------------------------

-- Use <space> as the leader key. Unmap its default motion first so the cursor
-- does not move while Neovim waits for a leader mapping to complete.
vim.keymap.set('', '<space>', '', { noremap = true, silent = true })
vim.g.mapleader = ' '
vim.g.log_level = vim.log.levels.WARN -- Global log level, handy while debugging

-- Load helper functions first so they are available to everything below.
require 'svim.globals'

-- Core editor configuration.
require 'svim.options'

-- Bootstrap the plugin manager and load every spec under `lua/svim/plugins/`.
local lazy_opts = require 'svim.lazy-bootstrap'
require('lazy').setup('svim.plugins', lazy_opts)
