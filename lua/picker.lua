local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values

local function get_entries()
  return require('./state').trace
end

local function open_picker()
  local opts = {}
  pickers.new({}, {
    prompt_title = "Grep",
    previewer = conf.grep_previewer({}),
    finder = finders.new_table({
      results = get_entries(),
      entry_maker = function(entry)
        local cwd = vim.fn.getcwd()
        local loc = entry.location
        -- remove the root of the project from file name to shorten
        local path = string.gsub(loc.path, cwd, ".")
        -- funny stacky parses this from exact same format..
        local file = path .. ':' .. loc.line .. ':' .. loc.column
        local line = entry["function"] .. ' - ' .. file
        return {
          path = loc.path,
          lnum = loc.line,
          cnum = loc.column,
          value = entry,
          display = line,
          ordinal = line,
        }
      end,
    }),
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      local exec = function(strategy)
        actions.close(prompt_bufnr)

        local entry = action_state.get_selected_entry().value
        local location = entry.location
        -- open the file
        local cmd = strategy .. ' ' .. location.path
        vim.api.nvim_command(cmd)
        -- move cursor
        local win = vim.api.nvim_get_current_win()

        local column = location.column
        if (column ~= 0) then
          column = column - 1
        end
        vim.api.nvim_win_set_cursor(win, { location.line, column })
      end

      map('i', '<C-v>', function()
        exec('vert')
      end)

      map('i', '<C-t>', function()
        exec('tabedit')
      end)

      map('i', '<CR>', function()
        exec('edit')
      end)

      return true
    end,
  }):find()
end

return open_picker
