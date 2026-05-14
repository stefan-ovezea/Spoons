--- WindowSwitcher Spoon entry point.
---
--- Public API:
---   spoon.WindowSwitcher:configure({ ... })
---   spoon.WindowSwitcher:bindHotkeys()
---   spoon.WindowSwitcher:start()
---   spoon.WindowSwitcher:stop()
---   spoon.WindowSwitcher:reload()
---   spoon.WindowSwitcher:show()

local obj = {}
obj.__index = obj

obj.name = "WindowSwitcher"
obj.version = "0.1.0"
obj.author = "Stefan Ovezea"
obj.homepage = "https://github.com/stefanovezea/Spoons/tree/main/switcher/WindowSwitcher.spoon"
obj.license = "MIT"

local spoonDir = debug.getinfo(1, "S").source:match("^@(.*/)")
local function loadModule(name)
    return dofile(spoonDir .. name .. ".lua")
end

local defaultConfig = loadModule("config")
local windows = loadModule("windows")
local drawing = loadModule("drawing")
local keys = loadModule("keys")

local function copyTable(source)
    local target = {}
    for key, value in pairs(source) do
        if type(value) == "table" then
            target[key] = copyTable(value)
        else
            target[key] = value
        end
    end
    return target
end

local function mergeTable(target, source)
    for key, value in pairs(source or {}) do
        if type(value) == "table" and type(target[key]) == "table" then
            mergeTable(target[key], value)
        else
            target[key] = value
        end
    end
end

obj.config = copyTable(defaultConfig)

function obj:configure(userConfig)
    mergeTable(self.config, userConfig)
    return self
end

local function cycle(state, direction)
    local count = #state.items
    if count == 0 then return end

    state.selectedIndex = ((state.selectedIndex - 1 + direction) % count) + 1
    drawing.render(state)
end

local function moveSelection(state, delta)
    local count = #state.items
    if count == 0 then return end

    state.selectedIndex = math.max(1, math.min(count, state.selectedIndex + delta))
    drawing.render(state)
end

local function scrollRows(state, deltaRows)
    local count = #state.items
    local layout = state.layout
    if count == 0 or not layout then return end

    local totalRows = math.ceil(count / layout.columns)
    local maxStartRow = math.max(0, totalRows - layout.rows)
    if maxStartRow == 0 then return end

    local currentStartRow = math.floor(((state.visibleStartIndex or 1) - 1) / layout.columns)
    local nextStartRow = math.max(0, math.min(maxStartRow, currentStartRow + deltaRows))
    local firstVisible = (nextStartRow * layout.columns) + 1
    local lastVisible = math.min(count, firstVisible + (layout.columns * layout.rows) - 1)

    state.visibleStartIndex = firstVisible
    if state.selectedIndex < firstVisible or state.selectedIndex > lastVisible then
        state.selectedIndex = firstVisible
    end

    drawing.render(state)
end

local function refreshWindows(state)
    state.itemsCache = windows.current(state.config, state.iconCache)
end

local function scheduleRefresh(state, delay)
    if state.refreshTimer then
        state.refreshTimer:stop()
    end

    state.refreshTimer = hs.timer.doAfter(delay or state.config.refreshDebounce, function()
        state.refreshTimer = nil
        refreshWindows(state)
    end)
end

local accept

local function openSwitcher(state, direction)
    if not state.itemsCache then
        refreshWindows(state)
    end

    state.items = state.itemsCache or {}
    state.screen = windows.currentScreen()
    state.visible = true

    if #state.items > 1 then
        state.selectedIndex = direction > 0 and 2 or #state.items
    else
        state.selectedIndex = 1
    end

    drawing.show(state)

    if state.acceptOnOpen then
        state.acceptOnOpen = false
        accept(state)
    end
end

function accept(state)
    if not state.visible then return end

    local item = state.items[state.selectedIndex]
    state.visible = false
    state.commandTabPending = false
    state.acceptOnOpen = false
    drawing.hide(state)

    if item then
        windows.focus(item)
    end
end

local function cancel(state)
    if not state.visible then return end

    state.visible = false
    state.commandTabPending = false
    state.acceptOnOpen = false
    drawing.hide(state)
end

local function buildState(self)
    local state = {
        config = self.config,
        logger = hs.logger.new("WindowSwitcher", self.config.logLevel),
        items = {},
        itemsCache = nil,
        iconCache = {},
        selectedIndex = 1,
        visible = false,
        commandTabPending = false,
        acceptOnOpen = false,
        canvas = nil,
        regions = {},
        hotkeys = {},
        windows = windows,
        drawing = drawing,
        keys = keys,
    }

    state.switch = function(direction)
        if state.visible then
            cycle(state, direction)
        else
            openSwitcher(state, direction)
        end
    end

    state.move = function(delta)
        moveSelection(state, delta)
    end

    state.moveRows = function(delta)
        local columns = state.layout and state.layout.columns or 1
        moveSelection(state, delta * columns)
    end

    state.scrollRows = function(delta)
        scrollRows(state, delta)
    end

    state.containsPoint = function(point)
        local layout = state.layout
        if not layout or not layout.frame then return false end

        local frame = layout.frame
        return point.x >= frame.x
            and point.x <= frame.x + frame.w
            and point.y >= frame.y
            and point.y <= frame.y + frame.h
    end

    state.accept = function()
        accept(state)
    end

    state.cancel = function()
        cancel(state)
    end

    state.onClick = function(x, y)
        local index = drawing.hitTest(state, x, y)
        if index then
            state.selectedIndex = index
            accept(state)
        end
    end

    state.onMouseMove = function(x, y)
        local index = drawing.hitTest(state, x, y)
        if index and index ~= state.selectedIndex then
            state.selectedIndex = index
            drawing.render(state)
        end
    end

    state.onMouseExit = function()
    end

    return state
end

local function startRefreshers(state)
    refreshWindows(state)

    state.refreshIntervalTimer = hs.timer.doEvery(state.config.refreshInterval, function()
        if not state.visible then
            refreshWindows(state)
        end
    end)

    state.appWatcher = hs.application.watcher.new(function()
        scheduleRefresh(state)
    end)
    state.appWatcher:start()

    local wf = hs.window.filter.new()
    state.windowFilter = wf
    wf:subscribe({
        hs.window.filter.windowCreated,
        hs.window.filter.windowDestroyed,
        hs.window.filter.windowFocused,
        hs.window.filter.windowTitleChanged,
        hs.window.filter.windowMinimized,
        hs.window.filter.windowUnminimized,
        hs.window.filter.windowHidden,
        hs.window.filter.windowUnhidden,
    }, function()
        if not state.visible then
            scheduleRefresh(state)
        end
    end)
end

local function stopRefreshers(state)
    if state.refreshTimer then
        state.refreshTimer:stop()
        state.refreshTimer = nil
    end

    if state.refreshIntervalTimer then
        state.refreshIntervalTimer:stop()
        state.refreshIntervalTimer = nil
    end

    if state.appWatcher then
        state.appWatcher:stop()
        state.appWatcher = nil
    end

    if state.windowFilter then
        state.windowFilter:unsubscribeAll()
        state.windowFilter = nil
    end
end

function obj:bindHotkeys()
    return self:start()
end

function obj:start()
    if self.state then
        self.state.logger.d("start called while already running")
        return self
    end

    self.state = buildState(self)
    self.state.logger.i("starting WindowSwitcher")
    startRefreshers(self.state)
    keys.start(self.state)

    return self
end

function obj:stop()
    if not self.state then return self end

    self.state.logger.i("stopping WindowSwitcher")
    keys.stop(self.state)
    stopRefreshers(self.state)
    drawing.delete(self.state)
    self.state = nil

    return self
end

function obj:reload()
    return self:stop():start()
end

function obj:show()
    if not self.state then self:start() end
    self.state.switch(1)
    return self
end

return obj
