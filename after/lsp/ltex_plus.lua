-- ltex_plus: LanguageTool-based grammar checker for prose.
---@type vim.lsp.Config
return {
  -- ltex logs every checked document at java.util.logging FINE level and has no
  -- flag to quiet it. Neovim records server stderr in lsp.log at ERROR level, so
  -- that alone grew the log past a gigabyte; drop stderr instead.
  cmd = { 'sh', '-c', 'exec ltex-ls-plus 2>/dev/null' },
  settings = {
    ltex = { language = 'auto' },
  },
}
