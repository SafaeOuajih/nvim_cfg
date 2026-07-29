# svim

A personal Neovim configuration.

- **Plugin manager:** [lazy.nvim](https://github.com/folke/lazy.nvim)
- **Colorscheme:** [catppuccin](https://github.com/catppuccin/nvim) (mocha flavour)

## Layout

```
init.lua                 entry point
lua/svim/
  globals.lua            global helper functions
  options.lua            builtin option preferences + autocommands
  keymaps.lua            keymaps not tied to a plugin
  diagnostics.lua        builtin diagnostics configuration
  lsp.lua                builtin LSP client setup
  treesitter.lua         builtin treesitter setup
  clangd-check.lua       :CcCheck, a clangd compilation database check
  bytes.lua              :Bytes, a byte/bit size converter
  utils.lua              shared utilities
  lazy-bootstrap.lua     installs lazy.nvim
  plugins/               one file per plugin (loaded automatically)
after/
  lsp/<server>.lua       per-server LSP settings
  syntax/                extra syntax rules
snippets/lua/            LuaSnip snippets
spell/                   spell dictionaries
```

## Core configuration

- Builtin options: [lua/svim/options.lua](./lua/svim/options.lua)
- Custom keymaps: [lua/svim/keymaps.lua](./lua/svim/keymaps.lua)
- Diagnostics: [lua/svim/diagnostics.lua](./lua/svim/diagnostics.lua)
- LSP: [client](./lua/svim/lsp.lua) and [per-server settings](./after/lsp)
- Treesitter: [lua/svim/treesitter.lua](./lua/svim/treesitter.lua)
- Commands: [`:CcCheck`](./lua/svim/clangd-check.lua), [`:Bytes`](./lua/svim/bytes.lua)

## Plugins

- **Completion:** [blink.cmp](https://github.com/saghen/blink.cmp)
- **Snippets:** [LuaSnip](https://github.com/L3MON4D3/LuaSnip) + [friendly-snippets](https://github.com/rafamadriz/friendly-snippets)
- **File explorer:** [oil.nvim](https://github.com/stevearc/oil.nvim) (edit the filesystem as a buffer)
- **Fuzzy finder / picker:** [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) and [snacks.nvim](https://github.com/folke/snacks.nvim)
- **Status line:** [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) with [lsp-progress.nvim](https://github.com/linrongbin16/lsp-progress.nvim)
- **Git:** [vim-fugitive](https://github.com/tpope/vim-fugitive), [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim), [worktrees.nvim](https://github.com/Juksuu/worktrees.nvim)
- **LSP tooling:** [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig), [mason.nvim](https://github.com/williamboman/mason.nvim), [SchemaStore.nvim](https://github.com/b0o/SchemaStore.nvim)
- **Syntax:** [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) + [nvim-treesitter-context](https://github.com/nvim-treesitter/nvim-treesitter-context)
- **Editing:**
  - [mini.ai](https://github.com/echasnovski/mini.ai) (extra text objects)
  - [mini.align](https://github.com/echasnovski/mini.align) (align text)
  - [mini.jump](https://github.com/echasnovski/mini.jump) (multi-line f/t jumps)
  - [mini.move](https://github.com/echasnovski/mini.move) (move lines/selections)
  - [nvim-autopairs](https://github.com/windwp/nvim-autopairs) (auto-pair brackets)
  - [Comment.nvim](https://github.com/numToStr/Comment.nvim) (toggle comments)
  - [vim-exchange](https://github.com/tommcdo/vim-exchange) (swap regions with `cx`)
  - tpope classics: [vim-surround](https://github.com/tpope/vim-surround), [vim-repeat](https://github.com/tpope/vim-repeat), [vim-abolish](https://github.com/tpope/vim-abolish), [vim-unimpaired](https://github.com/tpope/vim-unimpaired), [vim-eunuch](https://github.com/tpope/vim-eunuch)
- **Formatting & linting:** [conform.nvim](https://github.com/stevearc/conform.nvim), [nvim-lint](https://github.com/mfussenegger/nvim-lint)
- **UI:**
  - [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) (togglable terminal)
  - [fidget.nvim](https://github.com/j-hui/fidget.nvim) (notifications / LSP progress)
  - [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) (filetype icons)
  - [nvim-colorizer.lua](https://github.com/catgoose/nvim-colorizer.lua) (inline color previews)
  - [quicker.nvim](https://github.com/stevearc/quicker.nvim) (better quickfix)
  - [undotree](https://github.com/mbbill/undotree) (undo history browser)
  - [hex.nvim](https://github.com/RaafatTurki/hex.nvim) (view and edit binaries as a hex dump)
  - [todo-comments.nvim](https://github.com/folke/todo-comments.nvim) (highlight TODO/FIXME/NOTE)
- **Markdown / notes:** [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim), [obsidian.nvim](https://github.com/obsidian-nvim/obsidian.nvim), [image.nvim](https://github.com/3rd/image.nvim)
- **AI:** [claudecode.nvim](https://github.com/coder/claudecode.nvim)
