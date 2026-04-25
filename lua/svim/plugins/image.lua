-- image.nvim: render images inline using the kitty graphics protocol.
---@type LazyPluginSpec
return {
  '3rd/image.nvim',
  -- Do not build the luarocks dependency, see:
  -- https://github.com/3rd/image.nvim/issues/91#issuecomment-2453430239
  build = false,
  opts = {
    backend = 'kitty',
    processor = 'magick_cli',
  },
}
