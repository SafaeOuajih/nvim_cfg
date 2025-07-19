--- Builtin LSP client setup.
--- Per-server configuration lives under `after/lsp/<server>.lua`; this file
--- only wires up the shared behaviour and enables the servers.

local augroup = require('svim.utils').augroup
local autocmd = vim.api.nvim_create_autocmd
local autocmd_clr = vim.api.nvim_clear_autocmds
local pm = vim.lsp.protocol.Methods

--- Runs whenever a language server attaches to a buffer.
---@param client vim.lsp.Client
---@param bufnr integer
local function on_attach(client, bufnr)
  -- Turn on inlay hints when the server can provide them.
  if client:supports_method(pm.textDocument_inlayHint, bufnr) then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end

  -- Enable semantic token highlighting when available.
  if client:supports_method(pm.textDocument_semanticTokens_full, bufnr) then
    vim.lsp.semantic_tokens.start(bufnr, client.id)
  end

  -- Highlight the symbol under the cursor while it rests there.
  if client:supports_method(pm.textDocument_documentHighlight, bufnr) then
    local gid = augroup('document-highlight-' .. client.name)
    autocmd({ 'CursorHold', 'CursorHoldI' }, { group = gid, callback = vim.lsp.buf.document_highlight, buffer = bufnr })
    autocmd('CursorMoved', { group = gid, callback = vim.lsp.buf.clear_references, buffer = bufnr })
  end
end

--- Runs when a language server detaches from a buffer.
--- Cleans up references and avoids an error when force-closing a client.
---@param client vim.lsp.Client
local function on_exit(client)
  local function clear()
    vim.lsp.buf.clear_references()
    autocmd_clr { group = augroup('document-highlight-' .. client.name) }
  end

  if vim.in_fast_event() then
    vim.schedule(clear)
  else
    clear()
  end
end

autocmd('LspAttach', {
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    on_attach(client, args.buf)
  end,
})

autocmd('LspDetach', {
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    on_exit(client)
  end,
})

-- Enable the servers. Their settings are read from `after/lsp/<name>.lua`.
vim.lsp.enable {
  'harper-ls',
  'emmylua_ls',
  'taplo',
  'yaml-ls',
  'jsonls',
  'nil_ls',
  'nixd',
  'gopls',
  'clangd',
  'ruff',
  'pylsp',
  'neocmakelsp',
  'bashls',
  'ltex_plus',
  'zls',
}
