-- clangd: C/C++ language server.
---@type vim.lsp.Config
return {
  -- Build a background index and run clang-tidy checks.
  -- Neovim records server stderr in lsp.log at ERROR level, so clangd's default
  -- info logging (every LSP message) would bloat the log; keep it to errors.
  cmd = { 'clangd', '--background-index', '--clang-tidy', '--log=error' },
}
