-- toggleterm.nvim: a togglable, resizable terminal split.
---@type LazyPluginSpec
return {
  'akinsho/toggleterm.nvim',
  version = '*',
  ---@module "toggleterm.config"
  ---@type ToggleTermConfig
  opts = { ---@diagnostic disable-line:missing-fields
    -- Size depends on the direction the terminal opens in.
    size = function(term)
      if term.direction == 'horizontal' then
        return 15
      elseif term.direction == 'vertical' then
        return vim.o.columns * 0.4
      end
      return vim.o.columns * 0.7
    end,
    open_mapping = { '<M-i>' },
    insert_mappings = false,
    shading_factor = -20,
    direction = 'vertical',
    shell = 'fish',
  },
  keys = {
    {
      '<leader>tt',
      function()
        require('toggleterm').toggle()
      end,
      desc = '[T]oggle [T]erminal',
    },
    {
      '<M-i>',
      function()
        require('toggleterm').toggle()
      end,
      desc = '[T]oggle [T]erminal',
    },
  },
}
