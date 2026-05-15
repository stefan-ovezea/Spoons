--- Screen geometry helpers for MochaTheme.

local M = {}

local function screenID(screen)
    local id = screen:id()
    if id then return tostring(id) end
    return tostring(screen:name())
end

local function includeScreen(screenInfo, cfg)
    local selected = cfg.menuBar.screens

    if selected == "all" then return true end
    if selected == "main" then return screenInfo.screen == hs.screen.mainScreen() end
    if type(selected) == "table" then
        return selected[screenInfo.id] == true or selected[screenInfo.name] == true
    end

    return true
end

function M.current(cfg)
    local screens = {}

    for _, screen in ipairs(hs.screen.allScreens()) do
        local info = {
            id = screenID(screen),
            name = screen:name(),
            screen = screen,
            frame = screen:frame(),
            fullFrame = screen:fullFrame(),
        }

        if includeScreen(info, cfg) then
            table.insert(screens, info)
        end
    end

    table.sort(screens, function(a, b)
        if a.fullFrame.x == b.fullFrame.x then return a.fullFrame.y < b.fullFrame.y end
        return a.fullFrame.x < b.fullFrame.x
    end)

    return screens
end

function M.menuBarFrame(screenInfo, cfg)
    local fullFrame = screenInfo.fullFrame
    local visibleFrame = screenInfo.frame
    local detectedHeight = math.max(0, visibleFrame.y - fullFrame.y)
    local height = cfg.menuBar.height or detectedHeight

    if not height or height <= 0 then
        height = cfg.menuBar.fallbackHeight
    end

    return {
        x = fullFrame.x,
        y = fullFrame.y,
        w = fullFrame.w,
        h = height,
    }
end

return M
