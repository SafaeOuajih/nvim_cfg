-- lualine.nvim: the status line, with LSP progress shown on the right.
---@type LazyPluginSpec
return {
  'nvim-lualine/lualine.nvim',
  event = 'VeryLazy',
  dependencies = {
    'linrongbin16/lsp-progress.nvim',
    opts = {
      spinner = { '🌑 ', '🌒 ', '🌓 ', '🌔 ', '🌕 ', '🌖 ', '🌗 ', '🌘 ' },
      client_format = function(client, spinner, _)
        return ('[' .. client .. '] ' .. spinner)
      end,
      format = function(msgs)
        if #msgs > 0 then
          return table.concat(msgs, ' ')
        end
        return ''
      end,
    },
  },
  opts = {
    options = {
      section_separators = '',
      component_separators = { left = '∣', right = '∣' },
      globalstatus = true,
    },
    sections = {
      lualine_b = {
        {
          function()
            return vim.fn.FugitiveHead()
          end,
          icon = '',
        },
        'diff',
        {
          'diagnostics',
          sources = { 'nvim_diagnostic', 'nvim_lsp' },
          symbols = { error = ' ', warn = ' ', hint = ' ', info = ' ' },
        },
      },
      lualine_c = { '%=%f', 'filetype' },
      lualine_x = {
        function()
          return require('lsp-progress').progress()
        end,
        'encoding',
        'fileformat',
      },
    },
  },
}
