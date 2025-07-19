-- nil_ls: Nix language server.
---@type vim.lsp.Config
return {
  settings = {
    ['nil'] = {
      nix = {
        flake = { autoArchive = true, autoEvalInputs = true },
      },
    },
  },
}
