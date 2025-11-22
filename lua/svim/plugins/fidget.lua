-- fidget.nvim: a small UI for LSP progress and notifications.
---@type LazyPluginSpec
return {
  'j-hui/fidget.nvim',
  event = 'VeryLazy',
  opts = {
    progress = { display = { render_limit = 2, done_ttl = 1 } },
    notification = { window = { max_width = 80 } },
  },
  config = function(_, opts)
    require('fidget').setup(opts)
    -- Route notifications through fidget.
    vim.notify = require('fidget').notify
    vim.notify_once = require('fidget').notify
  end,
}
