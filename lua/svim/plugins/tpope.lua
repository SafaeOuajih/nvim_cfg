-- A bundle of tpope's classic editing plugins.
---@type LazyPluginSpec
return {
  -- Surround text objects with pairs (cs, ds, ys).
  'tpope/vim-surround',
  -- Make plugin mappings repeatable with `.`.
  'tpope/vim-repeat',
  -- Smart case-preserving substitution and word coercion.
  'tpope/vim-abolish',
  -- Handy `[` / `]` navigation pairs.
  {
    'tpope/vim-unimpaired',
    event = 'VeryLazy',
    config = function(_, _)
      -- Make the quickfix and location list mappings wrap around.
      vim.keymap.set('n', '[q', '<cmd>try | cprev | catch | clast | endtry<cr>', { noremap = true })
      vim.keymap.set('n', ']q', '<cmd>try | cnext | catch | cfirst| endtry<cr>', { noremap = true })
      vim.keymap.set('n', '[l', '<cmd>try | lprev | catch | llast | endtry<cr>', { noremap = true })
      vim.keymap.set('n', ']l', '<cmd>try | lnext | catch | lfirst| endtry<cr>', { noremap = true })
    end,
  },
  -- Unix shell commands as Vim commands (:Move, :Delete, :Chmod, ...).
  'tpope/vim-eunuch',
  config = function()
    vim.keymap.del('i', '<CR>')
  end,
}
