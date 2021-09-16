COQsources = COQsources or {}

local function expanduser(path)
    if path:sub(1, 1) == '~' then
        return vim.api.nvim_call_function('fnamemodify', {fname, ':p'}) .. path:sub(2)
    else
        return path
    end
end

read_JSON_file = function(type)
    local file = io.open(expanduser("~/.vim/plugged/coq_wordpress/wp-hooks/" .. type .. ".json"), "r")
    if file then
        local content = file:read("*a")
        io.close(file)
        return vim.fn.json_decode(content)
    else
        print("File doesn't exists, you need to run ./install.sh on the coq_wordpress folder.")
    end
    return vim.fn.json_decode({})
end

local wp_filters = read_JSON_file("actions")
local wp_actions = read_JSON_file("filters")

COQsources["wordpress"] = {
  name = "WP Hooks",
  fn = function (args, callback)
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
