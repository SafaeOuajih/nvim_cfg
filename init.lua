-------------------------------------------------------------------------------
-- svim - a personal Neovim configuration
--
-- This is the entry point Neovim sources on startup. It configures the core
-- editor and then hands plugin management over to lazy.nvim.
--
-- The rest of the configuration lives under `lua/svim/`:
--   - globals.lua      helper functions made available everywhere
--   - options.lua      builtin option preferences and autocommands
--   - keymaps.lua      keymaps that are not tied to a specific plugin
--   - diagnostics.lua  builtin diagnostics configuration
--   - lsp.lua          builtin LSP client setup
--   - treesitter.lua   builtin treesitter setup
--   - clangd-check.lua `:CcCheck`, a clangd compilation database check
--   - bytes.lua        `:Bytes`, a byte/bit size converter
--   - news.lua         `:News`, a feed reader in a terminal split
--   - plugins/         one file per plugin, loaded automatically by lazy.nvim
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
require 'svim.keymaps'
require 'svim.diagnostics'

-- Builtin LSP and treesitter configuration.
require 'svim.lsp'
require 'svim.treesitter'
require 'svim.clangd-check'
require 'svim.bytes'
require 'svim.news'

-- Bootstrap the plugin manager and load every spec under `lua/svim/plugins/`.
local lazy_opts = require 'svim.lazy-bootstrap'
require('lazy').setup('svim.plugins', lazy_opts)
