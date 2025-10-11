-- telescope.nvim: fuzzy finder over files, buffers, git, LSP and more.
---@type LazyPluginSpec
return {
  'nvim-telescope/telescope.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  },
  config = function()
    local telescope = require 'telescope'
    local builtin = require 'telescope.builtin'

    telescope.setup {
      extensions = {
        fzf = {},
      },
    }
    telescope.load_extension 'fzf'

    -- Files
    vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
    vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep' })
    vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = 'Grep word under cursor' })
    vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = 'Recent files' })
    vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Open buffers' })

    -- Git
    vim.keymap.set('n', '<leader>gf', builtin.git_files, { desc = 'Git files' })
    vim.keymap.set('n', '<leader>gc', builtin.git_commits, { desc = 'Git commits' })
    vim.keymap.set('n', '<leader>gb', builtin.git_branches, { desc = 'Git branches' })
    vim.keymap.set('n', '<leader>gs', builtin.git_status, { desc = 'Git status' })

    -- LSP
    vim.keymap.set('n', '<leader>fd', builtin.lsp_definitions, { desc = 'LSP definitions' })
    vim.keymap.set('n', '<leader>fi', builtin.lsp_implementations, { desc = 'LSP implementations' })
    vim.keymap.set('n', '<leader>fR', builtin.lsp_references, { desc = 'LSP references' })
    vim.keymap.set('n', '<leader>fs', builtin.lsp_document_symbols, { desc = 'Document symbols' })
    vim.keymap.set('n', '<leader>fS', builtin.lsp_workspace_symbols, { desc = 'Workspace symbols' })

    -- Vim
    vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Help tags' })
    vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = 'Keymaps' })
    vim.keymap.set('n', '<leader>fc', builtin.commands, { desc = 'Commands' })
    vim.keymap.set('n', '<leader>fj', builtin.jumplist, { desc = 'Jump list' })
    vim.keymap.set('n', '<leader>fm', builtin.marks, { desc = 'Marks' })
    vim.keymap.set('n', '<leader>ft', builtin.colorscheme, { desc = 'Colorschemes' })
  end,
}
