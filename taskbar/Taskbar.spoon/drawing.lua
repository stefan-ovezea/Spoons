--- hs.canvas rendering for Taskbar.
---
--- This module creates and updates one canvas per screen. It is intentionally
--- stateless apart from state.bars, which stores canvases and click regions.

local M = {}

local spoonDir = debug.getinfo(1, "S").source:match("^@(.*/)")

local function itemWidth(cfg)
    return cfg.iconSize + (cfg.padding * 2)
end

local function assetImage(name)
    return hs.image.imageFromPath(spoonDir .. "assets/" .. name)
end

local function attentionText(state, value)
    if not state.config.attentionCounter then return "" end

    local count = tonumber(value)
    if not count or count <= 0 then return "" end
    if count > state.config.attentionCounterMax then
        return tostring(state.config.attentionCounterMax) .. "+"
    end

    return tostring(math.floor(count))
end

local function appendAttentionDot(elements, state, app, cfg, iconX, iconY, iconSize, index)
    local value = (state.accessibilityBadges or {})[app.key]
    if not value then return end

    local text = attentionText(state, value)
    local diameter = cfg.attentionDotSize
    local width = text ~= "" and math.max(diameter, (#text * 6) + 8) or diameter
    local dotFrame = {
        x = iconX + iconSize - math.floor(width * 0.45),
        y = math.max(2, iconY - math.floor(diameter * 0.45)),
        w = width,
        h = diameter,
    }

    table.insert(elements, {
        id = "app-attention-left-" .. tostring(index),
        type = "oval",
        action = "fill",
        frame = { x = dotFrame.x, y = dotFrame.y, w = diameter, h = diameter },
        fillColor = cfg.colors.attention,
    })

    if width > diameter then
        table.insert(elements, {
            id = "app-attention-center-" .. tostring(index),
            type = "rectangle",
            action = "fill",
            frame = {
                x = dotFrame.x + math.floor(diameter / 2),
                y = dotFrame.y,
                w = width - diameter,
                h = diameter,
            },
            fillColor = cfg.colors.attention,
        })
    end

    table.insert(elements, {
        id = "app-attention-right-" .. tostring(index),
        type = "oval",
        action = "fill",
        frame = {
            x = dotFrame.x + width - diameter,
            y = dotFrame.y,
            w = diameter,
            h = diameter,
        },
        fillColor = cfg.colors.attention,
    })

    if text ~= "" then
        table.insert(elements, {
            id = "app-attention-text-" .. tostring(index),
            type = "text",
            text = text,
            frame = {
                x = dotFrame.x,
                y = dotFrame.y + 2,
                w = dotFrame.w,
                h = dotFrame.h + 2,
            },
            textAlignment = "center",
            textSize = 9,
            textColor = cfg.colors.attentionText,
        })
    end
end

local function appendRunningIndicator(elements, app, cfg, x, width, index)
    if not app.isRunning then return end

    if not app.isFrontmost then
        local size = cfg.runningIndicatorDotSize
        table.insert(elements, {
            id = "app-running-" .. tostring(index),
            type = "oval",
            action = "fill",
            frame = {
                x = x + math.floor((width - size) / 2),
                y = cfg.barHeight - cfg.runningIndicatorBottom - size,
                w = size,
                h = size,
            },
            fillColor = cfg.colors.runningIndicator,
        })
        return
    end

    local indicatorWidth = cfg.runningIndicatorWidth
    local indicatorHeight = cfg.runningIndicatorHeight
    table.insert(elements, {
        id = "app-running-" .. tostring(index),
        type = "rectangle",
        action = "fill",
        frame = {
            x = x + math.floor((width - indicatorWidth) / 2),
            y = cfg.barHeight - cfg.runningIndicatorBottom - indicatorHeight,
            w = indicatorWidth,
            h = indicatorHeight,
        },
        roundedRectRadii = {
            xRadius = cfg.runningIndicatorRadius,
            yRadius = cfg.runningIndicatorRadius,
        },
        fillColor = cfg.colors.runningIndicator,
    })
end

local function appElements(state, app, cfg, x, index)
    local height = cfg.barHeight
    local width = itemWidth(cfg)
    local hovered = state.hoveredAppKey == app.key
    local iconSize = hovered and cfg.iconSize + cfg.hoverIconGrowth or cfg.iconSize
    local iconX = x + math.floor((width - iconSize) / 2)
    local iconY = math.floor((height - iconSize) / 2) - (hovered and cfg.hoverIconLift or 0)
    local elements = {}

    if app.icon then
        table.insert(elements, {
            id = "app-icon-" .. tostring(index),
            type = "image",
            image = app.icon,
            frame = {
                x = iconX,
                y = iconY,
                w = iconSize,
                h = iconSize,
            },
        })
    end

    appendRunningIndicator(elements, app, cfg, x, width, index)
    appendAttentionDot(elements, state, app, cfg, iconX, iconY, iconSize, index)

    return elements, width
end

local function appendApp(elements, state, screenBar, app, targetX, index, pinned)
    local cfg = state.config
    local width = itemWidth(cfg)
    local x = targetX

    local appDrawings = appElements(state, app, cfg, x, index)
    for _, element in ipairs(appDrawings) do
        table.insert(elements, element)
    end

    table.insert(screenBar.regions, {
        key = app.key,
        app = app,
        pinned = pinned,
        index = index,
        x = x,
        targetX = targetX,
        y = 0,
        w = width,
        h = cfg.barHeight,
    })

    return targetX + width + cfg.itemSpacing
end

local function appendSeparator(elements, state, screenBar, x)
    local cfg = state.config
    local separatorX = x + cfg.separatorSpacing

    screenBar.separator = {
        x = separatorX,
        y = 7,
        w = cfg.separatorWidth,
        h = cfg.barHeight - 14,
    }

    table.insert(elements, {
        id = "separator",
        type = "rectangle",
        action = "fill",
        frame = screenBar.separator,
        fillColor = cfg.colors.separator,
    })

    return separatorX + cfg.separatorWidth + cfg.separatorSpacing
end

local function appendClock(elements, cfg, frame, rightX)
    if not cfg.showClock then return rightX end

    local clockX = rightX - cfg.clockWidth
    table.insert(elements, {
        id = "clock-text",
        type = "text",
        text = os.date(cfg.clockFormat),
        frame = {
            x = clockX,
            y = math.floor((frame.h - 14) / 2) - 1,
            w = cfg.clockWidth,
            h = frame.h,
        },
        textAlignment = "right",
        textSize = 12,
        textColor = cfg.colors.clockText,
    })

    return clockX - cfg.widgetSpacing
end

local function appendTrash(elements, state, screenBar, cfg, rightX)
    if not cfg.showTrash then return rightX end

    local buttonW = cfg.widgetButtonWidth
    local x = rightX - buttonW
    local size = cfg.trashIconSize
    local iconX = x + math.floor((buttonW - size) / 2)
    local iconY = math.floor((cfg.barHeight - size) / 2) + cfg.trashIconYOffset
    local image = state.trashFull and assetImage("trash-full.png") or assetImage("trash-empty.png")

    if image then
        table.insert(elements, {
            id = "trash-icon",
            type = "image",
            image = image,
            frame = {
                x = iconX,
                y = iconY,
                w = size,
                h = size,
            },
        })
    else
        local color = state.trashFull and cfg.colors.trashFull or cfg.colors.trash
        local fullColor = cfg.colors.attention
        local stroke = 1.4

        local function appendRect(id, frame, fillColor)
            table.insert(elements, {
                id = id,
                type = "rectangle",
                action = "fill",
                frame = frame,
                fillColor = fillColor,
            })
        end

        local function appendOval(id, frame, fillColor)
            table.insert(elements, {
                id = id,
                type = "oval",
                action = "fill",
                frame = frame,
                fillColor = fillColor,
            })
        end

        if state.trashFull then
            appendRect("trash-full-body", {
                x = iconX + 5,
                y = iconY + 8,
                w = size - 10,
                h = size - 10,
            }, cfg.colors.trashFill)
            appendOval("trash-full-badge", {
                x = iconX + size - 6,
                y = iconY - 1,
                w = 8,
                h = 8,
            }, fullColor)
            appendOval("trash-full-paper-left", {
                x = iconX + 4,
                y = iconY + 7,
                w = 5,
                h = 5,
            }, fullColor)
            appendRect("trash-full-paper-center", {
                x = iconX + 8,
                y = iconY + 6,
                w = 5,
                h = 6,
            }, fullColor)
            appendOval("trash-full-paper-right", {
                x = iconX + size - 9,
                y = iconY + 8,
                w = 5,
                h = 5,
            }, fullColor)
        end

        appendRect("trash-handle", {
            x = iconX + math.floor(size * 0.38),
            y = iconY + 2,
            w = math.floor(size * 0.24),
            h = stroke,
        }, color)
        appendRect("trash-lid", {
            x = iconX + 2,
            y = iconY + 5,
            w = size - 4,
            h = stroke,
        }, color)
        appendRect("trash-left-wall", {
            x = iconX + 4,
            y = iconY + 7,
            w = stroke,
            h = size - 9,
        }, color)
        appendRect("trash-right-wall", {
            x = iconX + size - 5,
            y = iconY + 7,
            w = stroke,
            h = size - 9,
        }, color)
        appendRect("trash-bottom", {
            x = iconX + 5,
            y = iconY + size - 3,
            w = size - 10,
            h = stroke,
        }, color)
        appendRect("trash-rib-left", {
            x = iconX + math.floor(size * 0.42),
            y = iconY + 9,
            w = 1,
            h = size - 13,
        }, color)
        appendRect("trash-rib-right", {
            x = iconX + math.floor(size * 0.58),
            y = iconY + 9,
            w = 1,
            h = size - 13,
        }, color)
    end

    table.insert(screenBar.regions, {
        kind = "trash",
        x = x,
        y = 0,
        w = buttonW,
        h = cfg.barHeight,
    })

    return x - cfg.widgetSpacing
end

local function appendWidgets(elements, state, screenBar, cfg, frame)
    local rightX = frame.w - cfg.padding

    rightX = appendClock(elements, cfg, frame, rightX)
    rightX = appendTrash(elements, state, screenBar, cfg, rightX)

    screenBar.appMaxX = rightX - cfg.widgetSpacing
end

local function elementsForBar(state, screenInfo)
    local cfg = state.config
    local screenBar = state.bars[screenInfo.id]
    local frame = screenBar.frame
    local elements = {
        {
            id = "background",
            type = "rectangle",
            action = "fill",
            frame = { x = 0, y = 0, w = frame.w, h = frame.h },
            fillColor = cfg.colors.background,
        },
    }

    screenBar.regions = {}
    screenBar.separator = nil
    screenBar.pinnedDropMaxX = cfg.padding
    screenBar.appMaxX = frame.w - cfg.padding

    appendWidgets(elements, state, screenBar, cfg, frame)

    local x = cfg.padding
    local pinnedApps, unpinnedApps = state.pins.orderedApps(state)

    for index, app in ipairs(pinnedApps) do
        local width = itemWidth(cfg)
        if x + width > screenBar.appMaxX then break end
        x = appendApp(elements, state, screenBar, app, x, "p-" .. tostring(index), true)
        screenBar.regions[#screenBar.regions].index = index
    end

    screenBar.pinnedDropMaxX = x
    if #pinnedApps == 0 then
        screenBar.pinnedDropMaxX = cfg.padding + itemWidth(cfg) + cfg.separatorSpacing
    end

    if #pinnedApps > 0 and #unpinnedApps > 0 then
        x = appendSeparator(elements, state, screenBar, x - cfg.itemSpacing)
        screenBar.pinnedDropMaxX = x
    end

    for index, app in ipairs(unpinnedApps) do
        local width = itemWidth(cfg)
        if x + width > screenBar.appMaxX then break end
        x = appendApp(elements, state, screenBar, app, x, "u-" .. tostring(index), false)
        screenBar.regions[#screenBar.regions].index = index
    end

    return elements
end

--- Returns the app region under a point in local canvas coordinates.
function M.regionAt(bar, x, y)
    if not bar or not bar.regions then return nil end

    for _, region in ipairs(bar.regions) do
        local inX = x >= region.x and x <= region.x + region.w
        local inY = y >= region.y and y <= region.y + region.h
        if inX and inY then return region end
    end

    return nil
end

--- Returns the app key under a point in local canvas coordinates.
function M.hitTest(bar, x, y)
    local region = M.regionAt(bar, x, y)
    return region and region.key or nil
end

--- Returns true when a drop point belongs to the pinned side.
function M.isPinnedDrop(bar, x)
    if not bar then return false end
    return x <= (bar.pinnedDropMaxX or 0)
end

--- Computes the insertion index for a pinned app drop.
function M.pinnedInsertionIndex(bar, x)
    local index = 1

    for _, region in ipairs(bar.regions or {}) do
        if region.pinned then
            if x < region.x + (region.w / 2) then
                return region.index
            end
            index = region.index + 1
        end
    end

    return index
end

--- Computes the insertion index for an unpinned app drop.
function M.unpinnedInsertionIndex(bar, x)
    local index = 1

    for _, region in ipairs(bar.regions or {}) do
        if not region.pinned then
            if x < region.x + (region.w / 2) then
                return region.index
            end
            index = region.index + 1
        end
    end

    return index
end

local function createCanvas(state, screenInfo, onMouseEvent)
    local canvas = hs.canvas.new(screenInfo.barFrame)
    canvas:level(hs.canvas.windowLevels.floating)
    canvas:behaviorAsLabels({ "canJoinAllSpaces", "stationary", "ignoresCycle" })
    canvas:clickActivating(false)
    canvas:canvasMouseEvents(true, true, true, true)
    canvas:mouseCallback(function(_, message, _, x, y)
        onMouseEvent(screenInfo.id, message, x, y)
    end)
    canvas:show()

    return canvas
end

--- Recreates all screen canvases from the current screen list.
function M.rebuildBars(state, screens, onMouseEvent)
    M.destroyBars(state)
    state.bars = {}

    for _, screenInfo in ipairs(screens) do
        screenInfo.barFrame = state.screens.barFrame(screenInfo, state.config)
        state.bars[screenInfo.id] = {
            id = screenInfo.id,
            canvas = createCanvas(state, screenInfo, onMouseEvent),
            frame = screenInfo.barFrame,
            regions = {},
            separator = nil,
            pinnedDropMaxX = state.config.padding,
            appMaxX = screenInfo.barFrame.w - state.config.padding,
        }
    end

    M.render(state, screens)
end

--- Replaces canvas elements for each bar using current app state.
function M.render(state, screens)
    for _, screenInfo in ipairs(screens) do
        local bar = state.bars[screenInfo.id]
        if bar and bar.canvas then
            bar.frame = screenInfo.barFrame or state.screens.barFrame(screenInfo, state.config)
            bar.canvas:frame(bar.frame)
            bar.canvas:replaceElements(elementsForBar(state, screenInfo))
        end
    end
end

--- Deletes all canvases and clears hit-test regions.
function M.destroyBars(state)
    if not state.bars then return end

    for _, bar in pairs(state.bars) do
        if bar.canvas then
            bar.canvas:delete()
        end
    end

    state.bars = {}
end

return M
