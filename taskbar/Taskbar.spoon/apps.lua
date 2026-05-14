--- Running application state for Taskbar.
---
--- This module owns application discovery, filtering, sorting, icon lookup,
--- and app activation. Rendering code consumes the plain app records returned
--- here instead of querying Hammerspoon application APIs directly.

local M = {}

local function call(app, method)
    local ok, value = pcall(function()
        return app[method](app)
    end)
    if ok then return value end
    return nil
end

local function appKey(app)
    local bundleID = call(app, "bundleID")
    if bundleID and bundleID ~= "" then return bundleID end

    local pid = call(app, "pid")
    if pid then return "pid:" .. tostring(pid) end

    return nil
end

local function isExcluded(app, cfg)
    local name = call(app, "name")
    local bundleID = call(app, "bundleID")

    if bundleID and cfg.excludedApps[bundleID] then return true end
    if name and cfg.excludedApps[name] then return true end

    return false
end

--- Returns true when the app should be represented in the bar.
function M.isDisplayable(app, cfg)
    if not app or isExcluded(app, cfg) then return false end

    local kind = call(app, "kind")
    if kind ~= 1 then return false end

    local name = call(app, "name")
    if not name or name == "" then return false end

    return appKey(app) ~= nil
end

local function iconFor(app)
    local bundleID = call(app, "bundleID")
    if bundleID then
        local icon = hs.image.imageFromAppBundle(bundleID)
        if icon then return icon end
    end

    local path = call(app, "path")
    if path then
        return hs.image.iconForFile(path)
    end

    return nil
end

local function callApplication(method, ...)
    local fn = hs.application[method]
    if type(fn) ~= "function" then return nil end

    local ok, value = pcall(fn, ...)
    if ok then return value end
    return nil
end

local function appRecord(app)
    local key = appKey(app)
    if not key then return nil end

    local name = call(app, "name") or key

    return {
        key = key,
        name = name,
        bundleID = call(app, "bundleID"),
        pid = call(app, "pid"),
        path = call(app, "path"),
        app = app,
        icon = iconFor(app),
        isRunning = true,
        isFrontmost = call(app, "isFrontmost") == true,
    }
end

function M.pinnedRecord(key)
    local bundleID = key:match("^pid:") and nil or key
    local name = bundleID and callApplication("nameForBundleID", bundleID) or nil
    local path = bundleID and callApplication("pathForBundleID", bundleID) or nil

    return {
        key = key,
        name = name or key,
        bundleID = bundleID,
        pid = nil,
        path = path,
        app = nil,
        icon = bundleID and hs.image.imageFromAppBundle(bundleID) or nil,
        isRunning = false,
        isFrontmost = false,
        isPinnedPlaceholder = true,
    }
end

local function debugIcon()
    local canvas = hs.canvas.new({ x = 0, y = 0, w = 32, h = 32 })
    canvas:appendElements({
        {
            type = "rectangle",
            action = "fill",
            frame = { x = 3, y = 3, w = 26, h = 26 },
            fillColor = { red = 0.22, green = 0.42, blue = 0.88, alpha = 1.0 },
        },
        {
            type = "rectangle",
            action = "stroke",
            frame = { x = 3.5, y = 3.5, w = 25, h = 25 },
            strokeWidth = 2,
            strokeColor = { red = 0.90, green = 0.95, blue = 1.0, alpha = 1.0 },
        },
    })

    local image = canvas:imageFromCanvas()
    canvas:delete()
    return image
end

local function appendDebugApp(state, records)
    if not state.config.debugNotificationBadge then return end

    local key = "debug:notification-badge"
    table.insert(records, {
        key = key,
        name = state.config.debugNotificationBadgeName,
        bundleID = key,
        pid = nil,
        path = nil,
        app = nil,
        icon = debugIcon(),
        isRunning = true,
        isFrontmost = false,
        isDebug = true,
    })

    state.accessibilityBadges = state.accessibilityBadges or {}
    state.accessibilityBadges[key] = state.config.debugNotificationBadgeCount
end

--- Refreshes state.apps from hs.application.runningApplications().
function M.refresh(state)
    local records = {}
    local seen = {}

    for _, app in ipairs(hs.application.runningApplications()) do
        if M.isDisplayable(app, state.config) then
            local record = appRecord(app)
            if record and not seen[record.key] then
                seen[record.key] = true
                table.insert(records, record)
            end
        end
    end

    table.sort(records, function(a, b)
        return a.name:lower() < b.name:lower()
    end)

    appendDebugApp(state, records)
    state.apps = records
    return records
end

--- Updates frontmost flags without rebuilding the application list.
function M.updateFrontmost(state)
    local frontmost = hs.application.frontmostApplication()
    local frontKey = frontmost and appKey(frontmost) or nil

    for _, record in ipairs(state.apps) do
        record.isFrontmost = record.key == frontKey
    end
end

local function launchOrFocus(record)
    if record.bundleID and hs.application.launchOrFocusByBundleID then
        local ok = callApplication("launchOrFocusByBundleID", record.bundleID)
        if ok then return true end
    end

    if record.name then
        local ok = callApplication("launchOrFocus", record.name)
        if ok then return true end
    end

    if record.path then
        local ok = callApplication("launchOrFocus", record.path)
        if ok then return true end
    end

    return false
end

--- Launches or focuses the app represented by key.
function M.launchOrFocus(state, key)
    for _, record in ipairs(state.apps) do
        if record.key == key then
            if record.isDebug then return false end
            state.logger.df("focusing %s", record.name)
            if record.app then
                if record.app.unhide then
                    pcall(function() record.app:unhide() end)
                end
                pcall(function() record.app:activate(true) end)
            end

            return launchOrFocus(record)
        end
    end

    local record = M.pinnedRecord(key)
    state.logger.df("launching or focusing %s", record.name)
    return launchOrFocus(record)
end

M.activate = M.launchOrFocus

return M
