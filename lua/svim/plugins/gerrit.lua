-- gerrit.nvim: review Gerrit changes over ssh, without the web UI.
---@type LazyPluginSpec
return {
  'SafaeOuajih/gerrit.nvim',
  cmd = 'Gerrit',
  dependencies = { 'nvim-telescope/telescope.nvim' },

  ---@type gerrit.Config
  opts = {
    -- The server and the project are read from the git remote of whichever
    -- repository the current buffer sits in, so nothing is pinned here.
  },

  keys = {
    { '<leader>gr', '<cmd>Gerrit<cr>', desc = '[G]errit [R]eviews' },
    { '<leader>gR', '<cmd>Gerrit mine<cr>', desc = '[G]errit: my changes' },
  },
}
