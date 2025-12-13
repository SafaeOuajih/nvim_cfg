-- mini.ai: richer text objects (functions, arguments, brackets, ...).
---@type LazyPluginSpec
return {
  'nvim-mini/mini.ai',
  version = '*',
  opts = {
    -- Free up the "last" variants; the defaults conflict with other mappings.
    mappings = {
      around_last = '',
      inside_last = '',
    },
  },
}
