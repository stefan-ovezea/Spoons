--- Screen and bar geometry helpers for Taskbar.
---
--- This module converts the current hs.screen layout into one bar frame per
--- monitor. It deliberately does not create canvases or know about app state.

local M = {}

local function screenID(screen)
    local id = screen:id()
    if id then return tostring(id) end
    return tostring(screen:name())
end

--- Returns a stable list of currently attached screens.
function M.current()
    local screens = {}

    for _, screen in ipairs(hs.screen.allScreens()) do
        table.insert(screens, {
            id = screenID(screen),
            name = screen:name(),
            screen = screen,
            frame = screen:fullFrame(),
        })
    end

    table.sort(screens, function(a, b)
        if a.frame.x == b.frame.x then return a.frame.y < b.frame.y end
        return a.frame.x < b.frame.x
    end)

    return screens
end

--- Calculates the canvas frame for a screen using the configured placement.
function M.barFrame(screenInfo, cfg)
    local frame = screenInfo.frame
    local y = frame.y

    if cfg.placement == "bottom" then
        y = frame.y + frame.h - cfg.barHeight
    end

    return {
        x = frame.x,
        y = y,
        w = frame.w,
        h = cfg.barHeight,
    }
end

return M
