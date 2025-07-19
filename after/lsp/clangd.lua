-- clangd: C/C++ language server.
---@type vim.lsp.Config
return {
  -- Build a background index and run clang-tidy checks.
  cmd = { 'clangd', '--background-index', '--clang-tidy' },
}
