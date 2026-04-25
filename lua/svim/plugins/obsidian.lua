-- obsidian.nvim: work with Obsidian-style markdown vaults.
---@type LazyPluginSpec
return {
  'obsidian-nvim/obsidian.nvim',
  version = '*',
  ---@module "obsidian"
  ---@type obsidian.config
  opts = {
    legacy_commands = false,
    workspaces = {
      {
        name = 'notes',
        path = '~/Nextcloud/notes',
        templates = { folder = '~/Nextcloud/notes/templates' },
      },
      {
        -- Fallback workspace for markdown files that live outside a vault:
        -- treat the file's own directory as the workspace root.
        name = 'no-vault',
        path = function()
          return assert(vim.fs.dirname(vim.api.nvim_buf_get_name(0)))
        end,
        overrides = {
          notes_subdir = vim.NIL, -- must use vim.NIL rather than nil
          new_notes_location = 'current_dir',
          templates = {
            folder = vim.NIL,
          },
          frontmatter = { enabled = false },
        },
      },
    },
  },
}
