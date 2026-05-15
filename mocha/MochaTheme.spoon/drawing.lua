--- hs.canvas rendering for MochaTheme.

local M = {}

local function color(cfg, token, alpha)
    local source = cfg.palette[token] or cfg.palette.base
    return {
        red = source.red,
        green = source.green,
        blue = source.blue,
        alpha = alpha ~= nil and alpha or source.alpha,
    }
end

local function canvasLevel(cfg)
    local configured = cfg.menuBar.level
    if type(configured) == "number" then return configured end
    return hs.canvas.windowLevels[configured] or hs.canvas.windowLevels.status
end

local function setClickThrough(canvas, enabled)
    canvas:clickActivating(false)
    canvas:canvasMouseEvents(false, false, false, false)

    if type(canvas.ignoresMouseEvents) == "function" then
        canvas:ignoresMouseEvents(enabled)
    end
end

local function elementsForFrame(cfg, frame)
    local elements = {
        {
            id = "menu-bar-background",
            type = "rectangle",
            action = "fill",
            frame = { x = 0, y = 0, w = frame.w, h = frame.h },
            fillColor = color(cfg, cfg.menuBar.background, cfg.menuBar.backgroundAlpha),
        },
    }

    if cfg.menuBar.topHighlight then
        table.insert(elements, {
            id = "menu-bar-top-highlight",
            type = "rectangle",
            action = "fill",
            frame = { x = 0, y = 0, w = frame.w, h = cfg.menuBar.topHighlightHeight },
            fillColor = color(cfg, cfg.menuBar.topHighlightColor, cfg.menuBar.topHighlightAlpha),
        })
    end

    if cfg.menuBar.accentHeight and cfg.menuBar.accentHeight > 0 then
        table.insert(elements, {
            id = "menu-bar-accent",
            type = "rectangle",
            action = "fill",
            frame = {
                x = 0,
                y = frame.h - cfg.menuBar.accentHeight,
                w = frame.w,
                h = cfg.menuBar.accentHeight,
            },
            fillColor = color(cfg, cfg.menuBar.accent, cfg.menuBar.accentAlpha),
        })
    end

    return elements
end

local function createCanvas(state, screenInfo)
    local frame = state.screens.menuBarFrame(screenInfo, state.config)
    local canvas = hs.canvas.new(frame)

    canvas:level(canvasLevel(state.config))
    canvas:behaviorAsLabels({ "canJoinAllSpaces", "stationary", "ignoresCycle" })
    setClickThrough(canvas, state.config.menuBar.clickThrough)
    canvas:replaceElements(elementsForFrame(state.config, frame))
    canvas:show()

    return {
        id = screenInfo.id,
        frame = frame,
        canvas = canvas,
    }
end

function M.rebuild(state)
    M.destroy(state)
    state.bars = {}

    if not state.config.menuBar.enabled then return end

    state.screenList = state.screens.current(state.config)
    for _, screenInfo in ipairs(state.screenList) do
        state.bars[screenInfo.id] = createCanvas(state, screenInfo)
    end
end

function M.destroy(state)
    for _, bar in pairs(state.bars or {}) do
        if bar.canvas then
            bar.canvas:delete()
        end
    end

    state.bars = {}
end

return M
