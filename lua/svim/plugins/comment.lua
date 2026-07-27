---@type LazyPluginSpec
return {
  'numToStr/Comment.nvim',
  opts = {
    ignore = '^$', -- Skip empty lines when commenting a range
    toggler = {
      line = 'cc', -- replaces gcc
      block = 'cbc', -- replaces gbc
    },
    opleader = {
      line = 'cc', -- replaces gc (for motions/visual)
      block = 'cb', -- replaces gb
    },
  },
}
