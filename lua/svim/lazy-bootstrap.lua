--- Bootstrap lazy.nvim (the plugin manager) and return its setup options.

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'

-- Clone lazy.nvim on the first launch if it is not installed yet.
if not vim.uv.fs_stat(lazypath) then
  print '=================================='
  print '    lazy.nvim is being installed'
  print '   Please wait until it finishes'
  print '=================================='

  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- always use the latest stable release
    lazypath,
  }
end

-- Make lazy.nvim available on the runtime path.
vim.opt.rtp:prepend(lazypath)

return {
  -- Local directory used when developing plugins with `dev = true`.
  dev = { path = '~/Documents/dev/' },
  install = { colorscheme = { 'catppuccin' } },
  change_detection = { enabled = true, notify = false },
}
