-- nvim-lint: run standalone linters and report through the diagnostics UI.
---@type LazyPluginSpec
return {
  'mfussenegger/nvim-lint',
  config = function(_, _)
    local lint = require 'lint'

    lint.linters_by_ft = {
      lua = { 'selene' },
      fish = { 'fish' },
      sh = { 'shellcheck' },
    }

    -- Hide the "type" column from checkpatch output.
    table.insert(lint.linters.checkpatch.args, '--no-show-types')

    vim.api.nvim_create_autocmd('BufWritePost', {
      group = vim.api.nvim_create_augroup('auto-lint-on-save', { clear = true }),
      callback = function()
        lint.try_lint()
      end,
    })
  end,
}
