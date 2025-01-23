local open_picker = require('./picker')
local state = require('./state')

local function update(trace)
  state.trace = vim.json.decode(trace)
end

-- This function is going to be called from outside
-- through neovim api
stacky_global = function(trace)
  update(trace)
  print('Stacky updated')
end

return {
  open = open_picker
}
