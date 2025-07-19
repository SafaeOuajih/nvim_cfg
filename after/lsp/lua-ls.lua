-- lua_ls: alternative Lua language server configuration, kept aware of the
-- Neovim runtime and every plugin's runtime path.
---@type vim.lsp.Config
return {
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
        path = { 'lua/?.lua', 'lua/?/init.lua', 'lua/vim/?.lua', 'lua/vim/?/init.lua' },
        pathStrict = true,
      },
      workspace = {
        checkThirdParty = false,
        library = {
          -- Load the Neovim runtime files
          vim.env.VIMRUNTIME,
          -- ...and every plugin's runtime path as well
          ---@diagnostic disable-next-line: undefined-field
          unpack(vim.fn.split(vim.opt.rtp._value, ',')),
        },
      },
      format = { enable = true },
      completion = { callSnippet = 'Replace' },
      hint = { enable = true, setType = true },
      IntelliSense = {
        traceLocalSet = true,
        traceReturn = true,
        traceBeSetted = true,
        traceFieldInject = true,
      },
    },
  },
}
