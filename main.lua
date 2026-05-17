--- @since 26.5.1

-- Requires `key-close` event from https://github.com/sxyazi/yazi/commit/740d8919896542de18db0c5da5fb347a14459890.

local _get_closed_tabs = ya.sync(function(state)
    return state.closed_tabs or {}
end)

local _save_closed_tab = ya.sync(function(state)
    local closed_tabs = _get_closed_tabs()

    -- TODO: add more tab properties
    local tab = {
        idx = tonumber(cx.tabs.idx) - 1,
        cwd = tostring(cx.active.current.cwd),
    }
    closed_tabs[#closed_tabs + 1] = tab
    ya.dbg("Recorded closed tab", tab)

    state.closed_tabs = closed_tabs
end)

local restore = ya.sync(function(state)
    local closed_tabs = _get_closed_tabs()
    if #closed_tabs == 0 then
        ya.notify {
            title = "No tabs!",
            content = "No more tabs to restore",
            timeout = 4,
        }
        return
    end

    local tab = closed_tabs[#closed_tabs]
    ya.dbg("Restoring tab", tab)
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

return {
    setup = function()
        ps.sub("key-close", function(args)
            if #cx.tabs ~= 1 then
                _save_closed_tab()
            end
            return args
        end)
    end,

    entry = function(_, job)
        local action = job.args[1]

        if action == "restore" then
            restore()
            return
        end
    end,
}
