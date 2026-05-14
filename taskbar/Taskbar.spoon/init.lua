--- Hammerbar Spoon entry point.
---
--- Public API:
---   spoon.Taskbar:start()
---   spoon.Taskbar:stop()
---   spoon.Taskbar:reload()
---   spoon.Taskbar:pinApp(appKey, index)
---   spoon.Taskbar:unpinApp(appKey)

local obj = {}
obj.__index = obj

obj.name = "Taskbar"
obj.version = "0.1.0"
obj.author = "Stefan Ovezea"
obj.homepage = "https://github.com/stefanovezea/Spoons/tree/main/Taskbar.spoon"
obj.license = "MIT"

local spoonDir = debug.getinfo(1, "S").source:match("^@(.*/)")
local function loadModule(name)
    return dofile(spoonDir .. name .. ".lua")
end

local defaultConfig = loadModule("config")
local apps = loadModule("apps")
local screens = loadModule("screens")
local drawing = loadModule("drawing")
local events = loadModule("events")
local reservation = loadModule("reservation")
local attention = loadModule("attention")
local pins = loadModule("pins")
local menu = loadModule("menu")
local drag = loadModule("drag")
local trash = loadModule("trash")

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

--- Applies user configuration before the Spoon is started.
function obj:configure(userConfig)
    mergeTable(self.config, userConfig)
    return self
end

function obj:pinApp(appKey, index)
    if self.state then
        pins.pin(self.state, appKey, index)
        drawing.render(self.state, self.state.screenList)
    else
        table.insert(self.config.pinnedApps, appKey)
    end

    return self
end

function obj:unpinApp(appKey)
    if self.state then
        pins.unpin(self.state, appKey)
        drawing.render(self.state, self.state.screenList)
    else
        for index = #self.config.pinnedApps, 1, -1 do
            if self.config.pinnedApps[index] == appKey then
                table.remove(self.config.pinnedApps, index)
            end
        end
    end

    return self
end

--- Re-runs the accessibility attention scanner immediately.
function obj:refreshAttention()
    if self.state then
        attention.refresh(self.state)
    end

    return self
end

--- Returns raw Dock accessibility text seen by the attention scanner.
function obj:debugAttentionTexts()
    if not self.state then return {} end
    return attention.debugTexts(self.state)
end

--- Returns raw Notification Center accessibility text seen by the scanner.
function obj:debugNotificationCenterTexts()
    if not self.state then return {} end
    return attention.debugNotificationCenterTexts(self.state)
end

--- Returns the current Trash detection state for troubleshooting.
function obj:debugTrashState()
    if not self.state then return {} end
    return trash.debug(self.state)
end

local function buildState(self)
    local logger = hs.logger.new("Hammerbar", self.config.logLevel)
    local state = {
        config = self.config,
        logger = logger,
        apps = {},
        bars = {},
        screenList = {},
        hoveredAppKey = nil,
        accessibilityBadges = {},
        appsModule = apps,
        screens = screens,
        drawing = drawing,
        events = events,
        reservation = reservation,
        attention = attention,
        pins = pins,
        menu = menu,
        drag = drag,
        trash = trash,
    }

    state.onMouseEvent = function(screenID, message, x, y)
        local bar = state.bars[screenID]
        local key = drawing.hitTest(bar, x, y)

        if message == "mouseMove" or message == "mouseEnter" or message == "mouseExit" then
            if message == "mouseExit" then key = nil end

            if state.hoveredAppKey ~= key then
                state.hoveredAppKey = key
                drawing.render(state, state.screenList)
            end
        end
    end

    return state
end

local function startWidgetTimer(state)
    trash.refresh(state)
    state.widgetTimer = hs.timer.doEvery(state.config.widgetRefreshInterval, function()
        trash.refresh(state)
        drawing.render(state, state.screenList)
    end)
end

local function stopWidgetTimer(state)
    if state.widgetTimer then
        state.widgetTimer:stop()
        state.widgetTimer = nil
    end
end

--- Starts Hammerbar and creates one bar per connected monitor.
function obj:start()
    if self.state then
        self.state.logger.d("start called while already running")
        return self
    end

    self.state = buildState(self)
    self.state.logger.i("starting Hammerbar")

    apps.refresh(self.state)
    pins.init(self.state)
    pins.reconcile(self.state)
    trash.refresh(self.state)
    self.state.screenList = screens.current()
    drawing.rebuildBars(self.state, self.state.screenList, self.state.onMouseEvent)
    events.start(self.state)
    reservation.start(self.state)
    attention.start(self.state)
    if self.state.config.dragReorder then
        drag.start(self.state)
    end
    if self.state.config.contextMenu then
        menu.start(self.state)
    end
    startWidgetTimer(self.state)

    return self
end

--- Stops watchers and removes all visible bars.
function obj:stop()
    if not self.state then return self end

    self.state.logger.i("stopping Hammerbar")
    stopWidgetTimer(self.state)
    drag.stop(self.state)
    menu.stop(self.state)
    attention.stop(self.state)
    events.stop(self.state)
    reservation.stop(self.state)
    drawing.destroyBars(self.state)
    self.state = nil

    return self
end

--- Restarts Hammerbar with the current configuration.
function obj:reload()
    return self:stop():start()
end

return obj
