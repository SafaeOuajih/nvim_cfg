-- vim-fugitive: a Git wrapper built around the `:Git` command.
local augroup = require('svim.utils').augroup
local autocmd = vim.api.nvim_create_autocmd

---@type LazyPluginSpec
return {
  'tpope/vim-fugitive',
  config = function()
    -- Open the fugitive status window, but only inside a Git repository.
    local function open_fugitive_buf()
      local ok, head = pcall(vim.fn.FugitiveHead)
      if ok and head ~= '' then
        vim.cmd.Git()
      end
    end

    local function get_fugitive_buf()
      return vim.fn.bufnr 'fugitive:///*/.git/{worktrees/*}\\\\\\{0,1\\}/$'
    end

    local function close_fugitive_buf()
      local fugitive_buf = get_fugitive_buf()
      if fugitive_buf ~= -1 then
        vim.api.nvim_buf_delete(fugitive_buf, {})
      end
    end

    -- Toggle the fugitive status window open/closed.
    function ToggleFugitiveGit()
      local fugitive_buf = get_fugitive_buf()
      if fugitive_buf ~= -1 then
        close_fugitive_buf()
      else
        open_fugitive_buf()
      end
    end

    local fugitive_grp = augroup 'fugitive_autocmd'
    autocmd('BufReadPost', {
      group = fugitive_grp,
      desc = 'Delete fugitive buffers when they are hidden',
      pattern = 'fugitive://*',
      callback = function()
        vim.b.bufhidden = 'delete'
      end,
    })

    autocmd('DirChanged', {
      group = fugitive_grp,
      desc = 'Refresh the fugitive status when the working directory changes',
      callback = function()
        close_fugitive_buf()
      end,
    })

    autocmd('User', {
      group = fugitive_grp,
      desc = 'Open the commit message editor in a vertical split on the far left',
      pattern = 'FugitiveEditor',
      callback = function()
        vim.cmd.wincmd 'H'
        vim.cmd.resize { 85, mods = { vertical = true } }
        vim.opt_local.winfixwidth = true
        vim.opt_local.textwidth = 80
      end,
    })

    autocmd('User', {
      group = fugitive_grp,
      pattern = 'FugitiveIndex',
      desc = 'Resize the fugitive index window',
      callback = function()
        vim.cmd.resize(10)
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.winfixheight = true
      end,
    })

    vim.keymap.set('n', '<leader>tg', ToggleFugitiveGit, { desc = '[T]oggle [G]it status' })
  end,
}
