--- Window reservation for Taskbar.
---
--- macOS does not expose a public Hammerspoon API for changing the system's
--- actual work area. This module approximates reservation by keeping standard
--- visible windows inside a per-screen work area reduced by Taskbar's height.

local M = {}

local windowEvents = hs.window.filter

local function call(object, method)
    local ok, value = pcall(function()
        return object[method](object)
    end)
    if ok then return value end
    return nil
end

local function screenID(screen)
    local id = screen and call(screen, "id")
    if id then return tostring(id) end

    local name = screen and call(screen, "name")
    if name then return tostring(name) end

    return nil
end

local function sameFrame(a, b)
    return math.abs(a.x - b.x) < 1
        and math.abs(a.y - b.y) < 1
        and math.abs(a.w - b.w) < 1
        and math.abs(a.h - b.h) < 1
end

local function workAreaForScreen(screen, cfg)
    local frame = screen:frame()
    local area = {
        x = frame.x,
        y = frame.y,
        w = frame.w,
        h = frame.h,
    }

    if cfg.placement == "top" then
        area.y = area.y + cfg.barHeight
        area.h = math.max(1, area.h - cfg.barHeight)
    else
        area.h = math.max(1, area.h - cfg.barHeight)
    end

    return area
end

local function isExcludedWindow(state, window)
    local app = call(window, "application")
    if not app then return true end

    local bundleID = call(app, "bundleID")
    local name = call(app, "name")

    if bundleID and state.config.excludedApps[bundleID] then return true end
    if name and state.config.excludedApps[name] then return true end

    return false
end

local function isReservable(state, window)
    if not state.config.reserveScreenSpace then return false end
    if not window or isExcludedWindow(state, window) then return false end
    if call(window, "isStandard") ~= true then return false end
    if call(window, "isVisible") ~= true then return false end
    if call(window, "isMinimized") == true then return false end
    if call(window, "isFullScreen") == true then return false end

    return true
end

local function constrainedFrame(frame, area)
    local nextFrame = {
        x = frame.x,
        y = frame.y,
        w = math.min(frame.w, area.w),
        h = math.min(frame.h, area.h),
    }

    if nextFrame.x < area.x then nextFrame.x = area.x end
    if nextFrame.y < area.y then nextFrame.y = area.y end

    local maxX = area.x + area.w - nextFrame.w
    local maxY = area.y + area.h - nextFrame.h

    if nextFrame.x > maxX then nextFrame.x = maxX end
    if nextFrame.y > maxY then nextFrame.y = maxY end

    return nextFrame
end

--- Moves a single window inside Taskbar's reserved work area if needed.
function M.applyToWindow(state, window)
    if state.reservationApplying or not isReservable(state, window) then return end

    local screen = call(window, "screen")
    local id = screenID(screen)
    local area = id and state.reservedAreas and state.reservedAreas[id]
    if not area then return end

    local frame = call(window, "frame")
    if not frame then return end

    local nextFrame = constrainedFrame(frame, area)
    if sameFrame(frame, nextFrame) then return end

    state.logger.df("reserving space for window %s", tostring(call(window, "title")))
    state.reservationApplying = true
    pcall(function()
        window:setFrame(nextFrame, 0)
    end)
    state.reservationApplying = false
end

--- Recomputes per-screen work areas and applies them to visible windows.
function M.apply(state)
    if not state.config.reserveScreenSpace then return end

    state.reservedAreas = {}

    for _, screenInfo in ipairs(state.screenList or {}) do
        state.reservedAreas[screenInfo.id] = workAreaForScreen(screenInfo.screen, state.config)
    end

    local windows = state.windowFilter and state.windowFilter:getWindows() or hs.window.visibleWindows()
    for _, window in ipairs(windows) do
        M.applyToWindow(state, window)
    end
end

local function schedule(state)
    if state.reservationTimer then
        state.reservationTimer:stop()
    end

    state.reservationTimer = hs.timer.doAfter(state.config.reservationDebounce, function()
        state.reservationTimer = nil
        M.apply(state)
    end)
end

--- Starts window subscriptions used to preserve the reserved area.
function M.start(state)
    if not state.config.reserveScreenSpace or state.windowFilter then return end

    state.windowFilter = hs.window.filter.new()
        :setOverrideFilter({
            visible = true,
            fullscreen = false,
        })

    state.windowFilter:subscribe({
        windowEvents.windowCreated,
        windowEvents.windowMoved,
        windowEvents.windowVisible,
        windowEvents.windowUnminimized,
        windowEvents.windowFocused,
    }, function(window)
        if not state.reservationApplying then
            schedule(state)
            M.applyToWindow(state, window)
        end
    end)

    M.apply(state)
end

--- Stops reservation subscriptions and pending timers.
function M.stop(state)
    if state.reservationTimer then
        state.reservationTimer:stop()
        state.reservationTimer = nil
    end

    if state.windowFilter then
        state.windowFilter:unsubscribeAll()
        state.windowFilter = nil
    end

    state.reservedAreas = nil
end

return M
