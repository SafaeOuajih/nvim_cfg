-- Print every installed plugin as a markdown list of links.
-- Run with: `:luafile scripts/list-plugins.lua`
local plugins = require('lazy').plugins()

for _, plugin in ipairs(plugins) do
  print(string.format('- [%s](%s)', plugin.name, plugin.url))
end
