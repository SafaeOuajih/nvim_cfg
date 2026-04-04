-- todo-comments.nvim: highlight and search TODO/FIXME/NOTE style comments.
---@type LazyPluginSpec
return {
  'folke/todo-comments.nvim',
  opts = {
    highlight = { pattern = [[.*<(KEYWORDS)\s*(\([^)]+\))?:]] },
    search = { pattern = [[\b(KEYWORDS)(\([^)]*\))?:]] },
  },
}
