--- Builtin treesitter setup.
--- Highlighting is enabled per filetype, installing the parser on demand when
--- nvim-treesitter can provide it, and falling back to regex syntax otherwise.

local augroup = require('svim.utils').augroup
local autocmd = vim.api.nvim_create_autocmd

--- Install the parser for `lang` through nvim-treesitter if it is available
--- and not installed yet.
---@param lang string
---@return boolean handled
local function try_install_parser(lang)
  local ok, nvimts = pcall(require, 'nvim-treesitter')
  if not ok then
    return false
  end

  -- Skip if the parser is already installed.
  local installed = pcall(vim.treesitter.language.inspect, lang)
  if installed then
    return true
  end

  local languages = nvimts.get_available()
  for _, v in pairs(languages) do
    if v == lang then
      nvimts.install(lang)
      return true
    end
  end
  return false
end

autocmd('FileType', {
  group = augroup 'tree-sitter-highlight',
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(args.match)
    -- Install the parser if nvim-treesitter knows about it.
    try_install_parser(lang)
    -- Try to enable treesitter highlighting. If it fails, fall back to the
    -- old-school regex syntax so the buffer is at least highlighted.
    local ok = pcall(vim.treesitter.start, args.buf, lang)
    if not ok then
      vim.bo[args.buf].syntax = 'on'
    end
  end,
})
