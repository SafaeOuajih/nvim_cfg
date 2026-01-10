-- Comment.nvim: toggle comments with gc / gcc across languages.
---@type LazyPluginSpec
return {
  'numToStr/Comment.nvim',
  -- Skip empty lines when commenting a range.
  opts = { ignore = '^$' },
}
