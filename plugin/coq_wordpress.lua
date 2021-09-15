COQsources = COQsources or {}
local wp_filters = vim.fn.json_decode(io.open("../hooks/actions.json", "r"):read("*a"))
local wp_actions = vim.fn.json_decode(io.open("../hooks/filters.json", "r"):read("*a"))

COQsources["wordpress"] = {
  name = "WP Hooks",
  fn = function (args, callback)
    local items = {}
    -- To get the actual code written
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line():sub(0,col)
    -- To check the code right now written and pass specific parameters
    local hook_type = ''
    if string.find(line, 'add_action') or string.find(line, 'remove_action') then
        hook_type = 'action'
    end
    if string.find(line, 'add_filter') or string.find(line, 'remove_filter') then
        hook_type = 'filter'
    end
    -- To get only the text insiert inside the function declaration
    text_input = line:gsub('remove_action',''):gsub('remove_filter','')
    text_input = text_input:gsub('add_action',''):gsub('remove_action','')
    text_input = text_input:gsub('"',''):gsub('\'','')
    text_input = text_input:gsub('%(',''):gsub('%)','')

    if hook_type ~= '' then
        for _,hook in pairs(wp_actions.hooks) do
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
