--- MochaTheme Spoon entry point.
---
--- Public API:
---   spoon.MochaTheme:configure({ ... })
---   spoon.MochaTheme:start()
---   spoon.MochaTheme:stop()
---   spoon.MochaTheme:reload()

local obj = {}
obj.__index = obj

obj.name = "MochaTheme"
obj.version = "0.1.0"
obj.author = "Stefan Ovezea"
obj.homepage = "https://github.com/stefanovezea/Spoons/tree/main/mocha/MochaTheme.spoon"
obj.license = "MIT"

local spoonDir = debug.getinfo(1, "S").source:match("^@(.*/)")
local function loadModule(name)
    return dofile(spoonDir .. name .. ".lua")
end

local defaultConfig = loadModule("config")
local screens = loadModule("screens")
local drawing = loadModule("drawing")
local events = loadModule("events")

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

local function buildState(self)
    return {
        config = self.config,
        logger = hs.logger.new("MochaTheme", self.config.logLevel),
        bars = {},
        screenList = {},
        screens = screens,
        drawing = drawing,
        events = events,
    }
end

function obj:start()
    if self.state then
        self.state.logger.d("start called while already running")
        return self
    end

    self.state = buildState(self)
    self.state.logger.i("starting MochaTheme")
    drawing.rebuild(self.state)
    events.start(self.state)

    return self
end

function obj:stop()
    if not self.state then return self end

    self.state.logger.i("stopping MochaTheme")
    events.stop(self.state)
    drawing.destroy(self.state)
    self.state = nil

    return self
end

function obj:reload()
    return self:stop():start()
end

return obj
