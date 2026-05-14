--- App pinning state for Hammerbar.
---
--- This module owns the ordered pinned-app list. Pins are keyed by the same
--- app key used by apps.lua, usually the bundle ID.

local M = {}

local pinnedSettingsKey = "Hammerbar.pinnedApps"
local orderSettingsKey = "Hammerbar.appOrder"

local function copyList(source)
    local target = {}
    for _, value in ipairs(source or {}) do
        table.insert(target, value)
    end
    return target
end

local function save(state)
    if state.suspendPinSave then return end
    if not state.config.persistPinnedApps then return end
    hs.settings.set(pinnedSettingsKey, state.pinnedAppKeys)
    hs.settings.set(orderSettingsKey, state.appOrderKeys)
end

function M.save(state)
    local suspended = state.suspendPinSave
    state.suspendPinSave = false
    save(state)
    state.suspendPinSave = suspended
end

local function removeValue(list, value)
    for index = #list, 1, -1 do
        if list[index] == value then
            table.remove(list, index)
        end
    end
end

local function appMatches(app, key)
    return app.key == key or app.bundleID == key or app.name == key
end

local function resolveKey(state, key)
    for _, app in ipairs(state.apps or {}) do
        if appMatches(app, key) then return app.key end
    end

    return key
end

function M.init(state)
    local savedPins = state.config.persistPinnedApps and hs.settings.get(pinnedSettingsKey) or nil
    local savedOrder = state.config.persistPinnedApps and hs.settings.get(orderSettingsKey) or nil

    if type(savedPins) == "table" then
        state.pinnedAppKeys = copyList(savedPins)
    else
        state.pinnedAppKeys = copyList(state.config.pinnedApps)
    end

    if type(savedOrder) == "table" then
        state.appOrderKeys = copyList(savedOrder)
    else
        state.appOrderKeys = {}
    end
end

function M.isPinned(state, app)
    for _, key in ipairs(state.pinnedAppKeys or {}) do
        if appMatches(app, key) then return true end
    end

    return false
end

function M.reconcile(state)
    local nextKeys = {}
    local seen = {}
    local running = {}

    for _, key in ipairs(state.pinnedAppKeys or {}) do
        local resolved = resolveKey(state, key)
        if not seen[resolved] then
            seen[resolved] = true
            table.insert(nextKeys, resolved)
        end
    end

    state.pinnedAppKeys = nextKeys

    local nextOrder = {}
    seen = {}

    for _, app in ipairs(state.apps or {}) do
        if not app.isDebug then
            running[app.key] = true
        end
    end

    for _, key in ipairs(state.appOrderKeys or {}) do
        local resolved = resolveKey(state, key)
        if running[resolved] and not seen[resolved] then
            seen[resolved] = true
            table.insert(nextOrder, resolved)
        end
    end

    for _, app in ipairs(state.apps or {}) do
        if not app.isDebug and not seen[app.key] then
            seen[app.key] = true
            table.insert(nextOrder, app.key)
        end
    end

    state.appOrderKeys = nextOrder
    save(state)
end

function M.orderedApps(state)
    local pinned = {}
    local unpinned = {}
    local used = {}

    for _, key in ipairs(state.pinnedAppKeys or {}) do
        for _, app in ipairs(state.apps or {}) do
            if not app.isDebug and not used[app.key] and appMatches(app, key) then
                table.insert(pinned, app)
                used[app.key] = true
                break
            end
        end
    end

    for _, key in ipairs(state.appOrderKeys or {}) do
        for _, app in ipairs(state.apps or {}) do
            if not app.isDebug and not used[app.key] and appMatches(app, key) then
                table.insert(unpinned, app)
                used[app.key] = true
                break
            end
        end
    end

    for _, app in ipairs(state.apps or {}) do
        if app.isDebug then
            table.insert(unpinned, app)
        elseif not used[app.key] then
            table.insert(unpinned, app)
        end
    end

    return pinned, unpinned
end

function M.pin(state, key, index)
    local resolved = resolveKey(state, key)
    if resolved == "debug:notification-badge" then return end
    local oldIndex = nil

    for currentIndex, value in ipairs(state.pinnedAppKeys) do
        if value == resolved then
            oldIndex = currentIndex
            break
        end
    end

    removeValue(state.pinnedAppKeys, resolved)
    removeValue(state.appOrderKeys, resolved)

    local targetIndex = index or (#state.pinnedAppKeys + 1)
    if oldIndex and oldIndex < targetIndex then
        targetIndex = targetIndex - 1
    end

    if targetIndex < 1 then targetIndex = 1 end
    if targetIndex > #state.pinnedAppKeys + 1 then
        targetIndex = #state.pinnedAppKeys + 1
    end

    table.insert(state.pinnedAppKeys, targetIndex, resolved)
    save(state)
end

function M.unpin(state, key)
    removeValue(state.pinnedAppKeys, resolveKey(state, key))
    save(state)
end

function M.reorderUnpinned(state, key, index)
    local resolved = resolveKey(state, key)
    if resolved == "debug:notification-badge" then return end

    local oldIndex = nil
    for currentIndex, value in ipairs(state.appOrderKeys) do
        if value == resolved then
            oldIndex = currentIndex
            break
        end
    end

    removeValue(state.pinnedAppKeys, resolved)
    removeValue(state.appOrderKeys, resolved)

    local targetIndex = index or (#state.appOrderKeys + 1)
    if oldIndex and oldIndex < targetIndex then
        targetIndex = targetIndex - 1
    end

    if targetIndex < 1 then targetIndex = 1 end
    if targetIndex > #state.appOrderKeys + 1 then
        targetIndex = #state.appOrderKeys + 1
    end

    table.insert(state.appOrderKeys, targetIndex, resolved)
    save(state)
end

return M
