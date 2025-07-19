-- mason.nvim: install and manage external tools (LSP servers, linters, ...).
---@type LazyPluginSpec
return {
  'williamboman/mason.nvim',
  opts = {
    ui = {
      icons = {
        package_installed = '✓',
        package_pending = '➜',
        package_uninstalled = '✗',
      },
    },
  },
}
