-- nixd: Nix language server with completion for NixOS and home-manager options.
-- The expressions below assume a flake in the current directory. Adjust the
-- host name ("nixos") and the home-manager key ("user@nixos") to match yours.
---@type vim.lsp.Config
return {
  cmd = { 'nixd', '--inlay-hints=true' },
  settings = {
    nixd = {
      nixpkgs = { expr = '(builtins.getFlake ("git+file://" + toString ./.)).inputs.nixpkgs' },
      options = {
        nixos = {
          expr = '(builtins.getFlake ("git+file://" + toString ./.)).nixosConfigurations.nixos.options',
        },
        home_manager = {
          expr = '(builtins.getFlake ("git+file://" + toString ./.)).homeConfigurations."user@nixos".options',
        },
      },
    },
  },
}
