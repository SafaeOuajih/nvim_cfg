-- nvim-treesitter (main branch): manage the installed parsers.
-- Highlighting itself is enabled in `lua/svim/treesitter.lua`.

-- Parsers that ship with Neovim, kept managed here so they receive updates too.
local builtin_parsers = {
  'c',
  'lua',
  'vim',
  'vimdoc',
  'markdown',
  'markdown_inline',
  'query',
}

---@type LazyPluginSpec
return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = function()
    require('nvim-treesitter').install(builtin_parsers)
    require('nvim-treesitter').update()
  end,
  version = false,
}
