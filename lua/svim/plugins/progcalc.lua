-- progcalc.nvim: a programmer's calculator in a floating buffer.
--
-- Replaces reaching for the GNOME calculator: one expression in, decimal, hex,
-- octal and a 64-bit bit grid out, all updating as you type. Arithmetic runs
-- on `uint64_t`, so register masks stay exact instead of drifting once they
-- pass the 53 bits a Lua number can hold.
--
---@type LazyPluginSpec
return {
  'SafaeOuajih/progcalc.nvim',
  cmd = 'ProgCalc',
  keys = {
    { '<leader>cc', '<cmd>ProgCalc<cr>', desc = 'Programmer [C]al[C]ulator' },
    { '<leader>cc', ":'<,'>ProgCalc<cr>", mode = 'v', desc = 'Programmer [C]al[C]ulator on selection' },
  },
}
