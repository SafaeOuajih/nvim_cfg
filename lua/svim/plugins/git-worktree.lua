-- worktrees.nvim: quickly switch between git worktrees through the snacks picker.
---@type LazyPluginSpec
return {
  'Juksuu/worktrees.nvim',
  dependencies = { 'snacks.nvim' },
  config = function()
    -- Required to register the snacks picker source.
    require('worktrees').setup()
    vim.keymap.set(
      'n',
      '<leader>sw',
      Snacks.picker.worktrees,
      { noremap = true, silent = true, desc = '[S]witch Git [W]orktrees' }
    )
  end,
}
