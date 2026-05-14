--- Context menu handling for Taskbar.
---
--- hs.canvas mouse callbacks do not expose a clean mouse-button value, so this
--- module uses hs.eventtap for right-clicks and only handles clicks that land
--- inside a Taskbar app region.

local M = {}

local function appForKey(state, key)
    for _, app in ipairs(state.apps or {}) do
        if app.key == key then return app end
    end

    return nil
end

local function trashMenuItems(state)
    return {
        { title = "Trash", disabled = true },
        { title = "-" },
        {
            title = "Open Trash",
            fn = function() state.trash.open() end,
        },
        {
            title = "Empty Trash",
            fn = function() state.trash.empty(state) end,
        },
    }
end

local function regionAtPoint(state, point)
    for _, bar in pairs(state.bars or {}) do
        local frame = bar.frame
        local inX = point.x >= frame.x and point.x <= frame.x + frame.w
        local inY = point.y >= frame.y and point.y <= frame.y + frame.h

        if inX and inY then
            local region = state.drawing.regionAt(bar, point.x - frame.x, point.y - frame.y)
            if region then return region end
        end
    end

    return nil
end

local function quitApp(app)
    if app and app.app then
        pcall(function() app.app:kill() end)
    end
end

local function forceQuitApp(app)
    if app and app.app then
        pcall(function() app.app:kill9() end)
    end
end

local function menuItems(state, app)
    if app.isDebug then
        return {
            { title = app.name, disabled = true },
            { title = "-" },
            { title = "Debug item", disabled = true },
        }
    end

    local pinned = state.pins.isPinned(state, app)
    local pinTitle = pinned and "Unpin from Taskbar" or "Pin to Taskbar"

    return {
        { title = app.name, disabled = true },
        { title = "-" },
        {
            title = pinTitle,
            fn = function()
                if pinned then
                    state.pins.unpin(state, app.key)
                else
                    state.pins.pin(state, app.key)
                end
                state.drawing.render(state, state.screenList)
            end,
        },
        { title = "-" },
        {
            title = "Quit",
            fn = function() quitApp(app) end,
        },
        {
            title = "Force Quit",
            fn = function() forceQuitApp(app) end,
        },
    }
end

function M.showApp(state, app, point)
    if state.contextMenu then
        state.contextMenu:delete()
        state.contextMenu = nil
    end

    state.contextMenu = hs.menubar.new(false)
    if not state.contextMenu then return end

    state.contextMenu:setMenu(menuItems(state, app))
    state.contextMenu:popupMenu(point, true)
end

function M.showTrash(state, point)
    if state.contextMenu then
        state.contextMenu:delete()
        state.contextMenu = nil
    end

    state.trash.refresh(state)

    state.contextMenu = hs.menubar.new(false)
    if not state.contextMenu then return end

    state.contextMenu:setMenu(trashMenuItems(state))
    state.contextMenu:popupMenu(point, true)
end

function M.start(state)
    if state.contextMenuTap then return end

    state.contextMenuTap = hs.eventtap.new({
        hs.eventtap.event.types.rightMouseDown,
    }, function(event)
        local point = event:location()
        local region = regionAtPoint(state, point)
        if not region then return false end

        if region.kind == "trash" then
            hs.timer.doAfter(0, function()
                M.showTrash(state, point)
            end)
            return true
        end

        local app = appForKey(state, region.key)
        if not app then return false end

        hs.timer.doAfter(0, function()
            M.showApp(state, app, point)
        end)

        return true
    end)

    state.contextMenuTap:start()
end

function M.stop(state)
    if state.contextMenuTap then
        state.contextMenuTap:stop()
        state.contextMenuTap = nil
    end

    if state.contextMenu then
        state.contextMenu:delete()
        state.contextMenu = nil
    end
end

return M
