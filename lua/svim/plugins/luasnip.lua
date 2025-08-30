-- LuaSnip: the snippet engine used by blink.cmp.
-- Loads both the friendly-snippets collection and the custom snippets kept
-- under `snippets/lua`.
---@type LazyPluginSpec
return {
  'L3MON4D3/LuaSnip',
  version = 'v2.*',
  build = 'make install_jsregexp',
  dependencies = { 'rafamadriz/friendly-snippets' },
  config = function()
    local ls = require 'luasnip'
    ls.setup {
      history = true,
      update_events = 'TextChanged,TextChangedI',
      delete_check_events = 'InsertLeave',
      enable_autosnippets = true,
    }

    -- Community snippets, then the ones defined in this configuration.
    require('luasnip.loaders.from_vscode').lazy_load()
    require('luasnip.loaders.from_lua').lazy_load {
      paths = { vim.fn.stdpath 'config' .. '/snippets/lua' },
    }
  end,
}
