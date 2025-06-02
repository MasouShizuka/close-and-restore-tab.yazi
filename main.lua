local function fail(s, ...) ya.notify { title = "restore-session.yazi", content = string.format(s, ...), timeout = 4, level = "error" } end
local function info(s, ...) ya.notify { title = "restore-session.yazi", content = string.format(s, ...), timeout = 2, level = "info" } end

local _get_closed_tabs = ya.sync(function(state)
    return not state.closed_tabs and {} or state.closed_tabs
end)

local _save_closed_tab = ya.sync(function(state)
    local closed_tabs = _get_closed_tabs()

    -- TODO: add more tab properties
    closed_tabs[#closed_tabs + 1] = {
        idx = tonumber(cx.tabs.idx) - 1,
        cwd = tostring(cx.active.current.cwd),
    }

    state.closed_tabs = closed_tabs
end)

local _close_and_switch = ya.sync(function(state, idx)
    ya.emit("close", {})
    ya.emit("tab_switch", { idx })
end)

local close_to_left = ya.sync(function(state)
    local active_idx = tonumber(cx.tabs.idx) - 1
    local target_idx = active_idx - 1
    if active_idx == 0 then
        target_idx = 0
    end

    _save_closed_tab()
    _close_and_switch(target_idx)
end)

local close_to_right = ya.sync(function(state)
    local total_tabs = #cx.tabs
    local active_idx = tonumber(cx.tabs.idx) - 1
    local target_idx = active_idx
    if active_idx == total_tabs - 1 then
        target_idx = total_tabs - 2
    end

    _save_closed_tab()
    _close_and_switch(target_idx)
end)

local restore = ya.sync(function(state)
    local closed_tabs = _get_closed_tabs()
    if #closed_tabs == 0 then
        return
    end

    local tab = closed_tabs[#closed_tabs]
    table.remove(closed_tabs, #closed_tabs)
    state.closed_tabs = closed_tabs

    local idx = tab.idx
    if idx == 0 then
        ya.emit("tab_switch", { 0 })
    else
        ya.emit("tab_switch", { idx - 1 })
    end

    -- TODO: add more tab properties to restore
    ya.emit("tab_create", { tab.cwd })

    if idx == 0 then
        ya.emit("tab_swap", { -1 })
    end
end)

-- dumps all the tabs into a file
-- it should be used as a replacement of
-- regular "quit"
local quit_and_save = ya.sync(function(state)
    -- maybe the path could be improved
    local home = os.getenv("HOME")
    local file_name = home .. "/.config/yazi/plugins/close-and-restore-tab.yazi/session.txt"

    -- iterate each tab
    local output = io.open(file_name, "w")
    if output ~= nil then
        for i=1, #cx.tabs do
            local parent = cx.tabs[i].parent.cwd
            local name = cx.tabs[i].name
            output:write(parent .. "/" .. name .. "\n")
        end
        output:close()
    else
        fail("Couldn't store session into '%s'", file_name)
    end
    ya.emit("quit", {}) -- exit
end)

-- Restores and updates the active tabs
local  restore_session = ya.sync(function(state)
    local home = os.getenv("HOME")
    local file_name = home .. "/.config/yazi/plugins/close-and-restore-tab.yazi/session.txt"

    local input = io.open(file_name, "r")
    if input ~= nil then
        -- add all the tabs
        for line in input:lines() do
            ya.emit("tab_create", {line})
        end

        -- delete the first one that its always put by yazi
        ya.emit("tab_close", {0})
        ya.emit("tab_switch", {0})

        input:close()
        info("Session restored successfully")
    end
end)

return {
    entry = function(_, job)
        local action = job.args[1]
        if not action then
            return
        end

        if action == "close_to_left" then
            close_to_left()
            return
        end

        if action == "close_to_right" then
            close_to_right()
            return
        end

        if action == "restore" then
            restore()
            return
        end

        if action == "store_session" then
            quit_and_save()
            return
        end

        if action == "restore_session" then
            restore_session()
            return
        end
    end,
}
