--- Trash state and actions for Taskbar.

local M = {}

local ignoredEntries = {
    ["."] = true,
    [".."] = true,
    [".DS_Store"] = true,
}

local function trashPath()
    return os.getenv("HOME") .. "/.Trash"
end

local function call(object, method, ...)
    if not object or not object[method] then return nil end

    local args = { ... }
    local ok, value = pcall(function()
        return object[method](object, table.unpack(args))
    end)

    if ok then return value end
    return nil
end

local function pathJoin(...)
    local parts = { ... }
    return table.concat(parts, "/")
end

local function hasVisibleEntry(path)
    local iterator = hs.fs.dir(path)
    if not iterator then return false end

    for entry in iterator do
        if not ignoredEntries[entry] then
            return true
        end
    end

    return false
end

local function trashesFolderHasItems(path)
    local iterator = hs.fs.dir(path)
    if not iterator then return false end

    for entry in iterator do
        if not ignoredEntries[entry] and hasVisibleEntry(pathJoin(path, entry)) then
            return true
        end
    end

    return false
end

local function anyFilesystemTrashFull()
    if hasVisibleEntry(trashPath()) then return true end
    if trashesFolderHasItems("/.Trashes") then return true end
    if trashesFolderHasItems("/System/Volumes/Data/.Trashes") then return true end

    local volumes = hs.fs.dir("/Volumes")
    if not volumes then return false end

    for volume in volumes do
        if not ignoredEntries[volume] then
            if trashesFolderHasItems(pathJoin("/Volumes", volume, ".Trashes")) then
                return true
            end
        end
    end

    return false
end

local function appendString(target, value)
    if type(value) == "string" and value ~= "" then
        table.insert(target, value)
    elseif type(value) == "number" then
        table.insert(target, tostring(value))
    end
end

local function elementText(element)
    local attrs = call(element, "allAttributeValues")
    if type(attrs) ~= "table" then return "" end

    local strings = {}
    appendString(strings, attrs.AXTitle)
    appendString(strings, attrs.AXDescription)
    appendString(strings, attrs.AXHelp)
    appendString(strings, attrs.AXValue)
    appendString(strings, attrs.AXLabel)

    return table.concat(strings, " "):lower()
end

local function dockTrashFull(state)
    local dock = hs.application.get("com.apple.dock") or hs.application.get("Dock")
    if not dock then return nil end

    local root = hs.axuielement.applicationElement(dock)
    if not root then return nil end

    local maxDepth = state.config.accessibilityScanMaxDepth or 12
    local maxNodes = state.config.accessibilityScanMaxNodes or 700
    local visited = 0
    local foundEmpty = false

    local function visit(element, depth)
        if not element then return nil end
        if depth > maxDepth then return nil end
        if visited >= maxNodes then return nil end

        visited = visited + 1

        local text = elementText(element)
        local mentionsTrash = text:find("trash", 1, true) or text:find("bin", 1, true)
        if mentionsTrash then
            if text:find("full", 1, true) then return true end
            if text:find("empty", 1, true) then foundEmpty = true end
        end

        local children = call(element, "attributeValue", "AXChildren")
        if type(children) ~= "table" then return nil end

        for _, child in ipairs(children) do
            local result = visit(child, depth + 1)
            if result ~= nil then return result end
        end

        return nil
    end

    local result = visit(root, 0)
    if result ~= nil then return result end
    if foundEmpty then return false end
    return nil
end

function M.refresh(state)
    local fsOk, fsFull = pcall(anyFilesystemTrashFull)
    local axOk, axFull = pcall(function()
        return dockTrashFull(state)
    end)

    state.trashFull = (axOk and axFull == true) or (fsOk and fsFull == true)

    if state.config.trashDebug then
        state.logger.df(
            "trash refresh: filesystemOk=%s filesystemFull=%s dockOk=%s dockFull=%s final=%s",
            tostring(fsOk),
            tostring(fsFull),
            tostring(axOk),
            tostring(axFull),
            tostring(state.trashFull)
        )
    end
end

function M.debug(state)
    local fsOk, fsFull = pcall(anyFilesystemTrashFull)
    local axOk, axFull = pcall(function()
        return dockTrashFull(state)
    end)

    return {
        filesystemOk = fsOk,
        filesystemFull = fsFull,
        dockOk = axOk,
        dockFull = axFull,
        trashFull = state.trashFull,
    }
end

function M.open()
    hs.urlevent.openURL("file://" .. trashPath())
end

function M.empty(state)
    hs.osascript.applescript('tell application "Finder" to empty trash')

    hs.timer.doAfter(1, function()
        M.refresh(state)
        state.drawing.render(state, state.screenList)
    end)
end

return M
