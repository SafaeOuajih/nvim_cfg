-- claudecode.nvim: integrate the Claude Code CLI with Neovim.
---@type LazyPluginSpec
return {
  'coder/claudecode.nvim',
  lazy = false,
  config = function()
    require('claudecode').setup()
  end,
}
