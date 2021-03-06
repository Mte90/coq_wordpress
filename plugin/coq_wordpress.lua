COQsources = COQsources or {}

local plugin_path = function()
  local str = debug.getinfo(2, "S").source:sub(2)
  str = str:gsub("/plugin/coq_wordpress.lua",'/wp-hooks/')

  return str
end

read_JSON_file = function(type)
    local path = plugin_path()  .. type .. ".json"
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        io.close(file)
        return vim.fn.json_decode(content)
    else
        print("File " .. path .. " doesn't exists, you need to run ./install.sh on the coq_wordpress folder.")
        return vim.fn.json_decode('{"hooks": []}')
    end
end

local wp_filters = read_JSON_file("actions")
local wp_actions = read_JSON_file("filters")

COQsources["wordpress"] = {
  name = "WP Hooks",
  fn = function (args, callback)
    if (vim.bo.filetype ~= "php") then
        callback(nil)
    end

    local items = {}
    local hooks = {}
    -- To get the actual code written
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line():sub(0,col)
    -- To check the code right now written and pass specific parameters
    local hook_type = ''
    if string.find(line, 'add_action%(') or string.find(line, 'remove_action%(') then
        hook_type = 'action'
        hooks = wp_actions.hooks
    end
    if string.find(line, 'add_filter%(') or string.find(line, 'remove_filter%(') then
        hook_type = 'filter'
        hooks = wp_filters.hooks
    end
    -- To get only the text insert inside the function declaration
    text_input = line:gsub('remove_action',''):gsub('remove_filter','')
    text_input = text_input:gsub('add_action',''):gsub('remove_action','')
    text_input = text_input:gsub('"',''):gsub('\'','')
    text_input = text_input:gsub('%(',''):gsub('%)','')

    if hook_type ~= '' then
        for _,hook in pairs(hooks) do
            if string.sub(hook.name,1,string.len(text_input))==text_input then
                local item = {
                    label = hook.name,
                    insertText = hook.name,
                    -- Text type
                    kind = 1,
                    detail = hook_type
                }
                table.insert(items, item)
            end
        end
    end

    callback {
        isIncomplete = true,
        items = items
    }
  end
}
