-- ltex-utils.nvim: helpers for managing ltex dictionaries and hidden rules.
-- Disabled for now; enable it if the ltex_plus server is in active use.
---@type LazyPluginSpec
return {
  'jhofscheier/ltex-utils.nvim',
  enabled = false,
  dependencies = {
    'neovim/nvim-lspconfig',
  },
  opts = {},
}
