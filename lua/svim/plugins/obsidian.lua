-- obsidian.nvim: work with Obsidian-style markdown vaults.
--
-- The `notes` vault at `~/notes` is a git repository: a `notes-sync.timer`
-- systemd user unit commits and pushes it every 15 minutes, so nothing here
-- has to care about saving or syncing. See `~/notes/README.md`.

--- Run a vault-scoped `:Obsidian` subcommand against the `notes` vault.
---
--- obsidian.nvim picks a workspace by matching the current directory, and the
--- `no-vault` workspace below resolves to whatever directory the current
--- buffer sits in - so it matches *everywhere*. Vault commands derive their
--- paths from the active workspace root, which means that without switching
--- first, `:Obsidian today` creates a `daily/` folder next to whatever file
--- happens to be open instead of in `~/notes`.
---@param subcommand string
---@return fun()
local function in_vault(subcommand)
  return function()
    -- The `Obsidian` global is created by the plugin's setup, and `:Note`
    -- below can be typed before anything has loaded it. Loading through lazy
    -- is a no-op once the plugin is already on the runtimepath.
    require('lazy').load { plugins = { 'obsidian.nvim' } }

    if Obsidian.workspace.name ~= 'notes' then
      require('obsidian.workspace').set 'notes'
    end
    vim.cmd('Obsidian ' .. vim.trim(subcommand))
  end
end

---@type LazyPluginSpec
return {
  'obsidian-nvim/obsidian.nvim',
  version = '*',

  -- Lazy on the note commands and keymaps, plus any markdown file, so that
  -- opening a note directly (`nvim ~/notes/foo.md`) still loads the plugin.
  ft = 'markdown',
  cmd = 'Obsidian',

  -- `:Note` opens today's daily note, and takes the same optional argument as
  -- `:Obsidian today`: `:Note -1` for yesterday, `:Note 2026-07-15` for a
  -- specific day.
  --
  -- Defined in `init` rather than `config` because it has to exist before the
  -- plugin is loaded - it is one of the things that triggers the load.
  init = function()
    vim.api.nvim_create_user_command('Note', function(opts)
      in_vault('today ' .. opts.args)()
    end, { nargs = '?', desc = "Open today's daily note" })

    -- Neovim reserves lowercase names for builtin commands, so `:note` cannot
    -- be a user command. Abbreviate it to `:Note` instead, guarded so that it
    -- only fires as a command name: without the guard, `:%s/note/x/` and
    -- `:e notes.md` would be rewritten too.
    vim.cmd [[cnoreabbrev <expr> note (getcmdtype() == ':' && getcmdline() ==# 'note') ? 'Note' : 'note']]
  end,
  keys = {
    -- Vault-scoped: these always act on `~/notes`, from anywhere.
    { '<leader>nn', in_vault 'new', desc = '[N]ote [N]ew' },
    { '<leader>nd', in_vault 'today', desc = '[N]ote [D]aily' },
    { '<leader>ny', in_vault 'yesterday', desc = '[N]ote [Y]esterday' },
    { '<leader>no', in_vault 'quick_switch', desc = '[N]ote [O]pen' },
    { '<leader>ns', in_vault 'search', desc = '[N]ote [S]earch' },
    { '<leader>nt', in_vault 'tags', desc = '[N]ote [T]ags' },

    -- Note-scoped: these act on the note under the cursor, so they must not
    -- switch workspace. obsidian.nvim only exposes them in a markdown buffer.
    { '<leader>nb', '<cmd>Obsidian backlinks<cr>', ft = 'markdown', desc = '[N]ote [B]acklinks' },
    { '<leader>nr', '<cmd>Obsidian rename<cr>', ft = 'markdown', desc = '[N]ote [R]ename' },
    { '<leader>nl', '<cmd>Obsidian link<cr>', mode = 'v', ft = 'markdown', desc = '[N]ote [L]ink' },
  },

  ---@module "obsidian"
  ---@type obsidian.config
  opts = {
    legacy_commands = false,
    workspaces = {
      {
        name = 'notes',
        path = '~/notes',
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
          -- Selecting a workspace creates its daily folder on disk. Since
          -- this workspace matches any directory, leaving daily notes on
          -- scatters an empty `daily/` through every project opened.
          daily_notes = { enabled = false },
        },
      },
    },

    -- Filenames are the note titles, slugified. The default is a random
    -- zettelkasten id, which makes `ls ~/notes` and `grep -r` useless.
    --
    -- Required lazily: this spec is read at startup, long before the plugin
    -- itself is on the runtimepath, so a top-level require would fail.
    note_id_func = function(title, dir)
      return require('obsidian.builtin').title_id(title, dir)
    end,

    -- Must live here rather than on the workspace spec: a workspace only
    -- reads `path`, `name`, `strict` and `overrides`, so a `templates` key
    -- nested in one is silently ignored and templates never resolve.
    --
    -- Relative, so it resolves against whichever workspace root is active
    -- (`~/notes/templates` for the vault). `no-vault` nils it out below.
    templates = { folder = 'templates' },

    daily_notes = {
      folder = 'daily',
      template = 'daily.md',
      default_tags = { 'daily' },
      -- A personal notebook does not stop on Saturday; the default skips
      -- weekends, which would make `Obsidian yesterday` jump over them.
      workdays_only = false,
    },

    -- render-markdown.nvim already draws headings, bullets and checkboxes.
    -- Leaving obsidian's own UI on means both decorate the same buffer.
    ui = { enable = false },

    picker = { name = 'snacks.picker' },

    -- Keep links pointing at the right note when a file is renamed.
    link = { auto_update = true },
  },
}
