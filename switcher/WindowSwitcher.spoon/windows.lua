local M = {}

local function call(object, method)
    if not object or type(object[method]) ~= "function" then return nil end

    local ok, value = pcall(function()
        return object[method](object)
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

local function isExcluded(win, cfg)
    local app = call(win, "application")
    local name = app and call(app, "name") or nil
    local key = app and appKey(app) or nil

    if key and cfg.excludedApps[key] then return true end
    if name and cfg.excludedApps[name] then return true end

    return false
end

local function isUsableWindow(win, cfg)
    if not win or isExcluded(win, cfg) then return false end

    if call(win, "isStandard") ~= true then return false end
    if call(win, "isMinimized") == true and not cfg.includeMinimized then return false end

    local app = call(win, "application")
    if app and call(app, "isHidden") == true and not cfg.includeHidden then return false end

    local title = call(win, "title") or ""
    if title == "" and not cfg.includeUntitledWindows then return false end

    return true
end

local function iconFor(app, cache)
    local bundleID = app and call(app, "bundleID") or nil
    if bundleID then
        if cache and cache[bundleID] then return cache[bundleID] end
        local icon = hs.image.imageFromAppBundle(bundleID)
        if icon then
            if cache then cache[bundleID] = icon end
            return icon
        end
    end

    local path = app and call(app, "path") or nil
    if path then
        local key = "path:" .. path
        if cache and cache[key] then return cache[key] end
        local icon = hs.image.iconForFile(path)
        if icon and cache then cache[key] = icon end
        return icon
    end

    return nil
end

local function recordFor(win, order, iconCache)
    local app = call(win, "application")
    local appName = app and call(app, "name") or "Unknown"
    local title = call(win, "title") or ""
    local id = call(win, "id") or tostring(win)

    return {
        id = tostring(id),
        window = win,
        app = app,
        appName = appName,
        title = title ~= "" and title or appName,
        icon = iconFor(app, iconCache),
        order = order,
        minimized = call(win, "isMinimized") == true,
    }
end

local function appendWindow(records, seen, win, cfg, order, iconCache)
    if not isUsableWindow(win, cfg) then return end

    local id = tostring(call(win, "id") or win)
    if seen[id] then return end

    seen[id] = true
    table.insert(records, recordFor(win, order, iconCache))
end

function M.currentScreen()
    local screen = hs.mouse.getCurrentScreen()
    if screen then return screen end

    return hs.screen.mainScreen()
end

function M.current(cfg, iconCache)
    local records = {}
    local seen = {}
    local ordered = hs.window.orderedWindows() or {}

    for index, win in ipairs(ordered) do
        appendWindow(records, seen, win, cfg, index, iconCache)
    end

    if cfg.includeMinimized or cfg.includeHidden then
        for _, win in ipairs(hs.window.allWindows() or {}) do
            appendWindow(records, seen, win, cfg, #records + 1000, iconCache)
        end
    end

    return records
end

function M.focus(record)
    if not record or not record.window then return false end

    local app = record.app
    if app and app.unhide then
        pcall(function() app:unhide() end)
    end

    if record.window.unminimize then
        pcall(function() record.window:unminimize() end)
    end

    if app and app.activate then
        pcall(function() app:activate(true) end)
    end

    local ok = pcall(function()
        record.window:focus()
    end)

    return ok
end

return M
