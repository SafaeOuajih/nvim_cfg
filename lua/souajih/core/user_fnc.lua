function CopyFromDevTools(filename)
  local file_path = '~/dev/tools/rdy_code/' .. filename
  vim.cmd('normal! o')
  vim.cmd('r ' .. file_path)
end

vim.api.nvim_create_user_command('CP', function(opts)
  CopyFromDevTools(opts.args)
end, { nargs = 1 })
