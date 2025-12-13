-- nvim-autopairs: automatically insert matching brackets and quotes.
---@type LazyPluginSpec
return {
  'windwp/nvim-autopairs',
  opts = {
    disable_in_macro = false,
    check_ts = true, -- Use treesitter to decide when to pair
    map_cr = false, -- Let the completion engine handle <CR>
  },
}
