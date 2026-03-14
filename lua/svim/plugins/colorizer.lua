-- nvim-colorizer.lua: show a small colored mark next to color codes.
---@type LazyPluginSpec
return {
  'catgoose/nvim-colorizer.lua',
  ---@module "colorizer.config"
  opts = {
    ---@type colorizer.NewOptions
    options = {
      parsers = {
        -- Do not colorize named colors such as "red" or "blue".
        names = {
          enable = false,
          lowercase = false,
          camelcase = false,
          uppercase = false,
          strip_digits = false,
          custom = false,
        },
        sass = { enable = true, parsers = { 'css' } },
      },
      display = {
        mode = 'virtualtext',
        virtualtext = {
          char = '',
          position = 'after',
        },
      },
    },

    filetypes = {
      '*',
      css = { css = true },
      scss = { css = true },
      html = { css = true },
    },
  },
}
