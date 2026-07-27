-- yamlls: YAML language server, using SchemaStore for schema validation.
local ok, schemastore = pcall(require, 'schemastore')
local schemas = ok and schemastore.yaml.schemas() or {}

---@type vim.lsp.Config
return {
  settings = {
    yaml = {
      -- SchemaStore is provided by the plugin above, so disable the builtin one.
      schemaStore = { enable = false, url = '' },
      schemas = schemas,
      customTags = { '!reference sequence' },
    },
  },
}
