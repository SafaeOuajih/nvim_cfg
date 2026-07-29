-- hex.nvim: view and edit a buffer as a hex dump, through `xxd`.
--
-- Loaded on `BufReadPre` rather than on the command, because the point is that
-- opening a firmware image drops straight into a hex view; a command-lazy
-- plugin is not loaded yet when that read happens.
---@type LazyPluginSpec
return {
  'RaafatTurki/hex.nvim',
  event = 'BufReadPre',
  keys = {
    { '<leader>tx', '<cmd>HexToggle<cr>', desc = '[T]oggle he[X] view' },
  },
  cmd = { 'HexDump', 'HexAssemble', 'HexToggle' },
  opts = {
    -- Dump on open only for extensions that are unambiguously binary. The
    -- upstream list carries png/jpg/jpeg, which would hex-dump the images
    -- image.nvim exists to render.
    is_file_binary_pre_read = function()
      local binary_ext = { 'bin', 'out', 'elf', 'o', 'a', 'so', 'img', 'rom', 'fw' }

      -- Only touch buffers nothing else has claimed.
      if vim.bo.filetype ~= '' then
        return false
      end
      -- `nvim -b` is an explicit request for a binary buffer.
      if vim.bo.binary then
        return true
      end
      return vim.tbl_contains(binary_ext, vim.fn.expand '%:e')
    end,

    -- Upstream also dumps anything whose encoding is not utf-8, which fires on
    -- latin-1 text and turns an ordinary edit into an xxd round trip. The
    -- extension list above is the only trigger; use `:HexToggle` otherwise.
    is_file_binary_post_read = function()
      return false
    end,
  },
}
