local M = {}

local function clampText(value, maxChars)
    value = value or ""
    if #value <= maxChars then return value end
    if maxChars <= 1 then return value:sub(1, maxChars) end
    return value:sub(1, maxChars - 1) .. "..."
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

local function layout(state)
    local cfg = state.config
    local count = math.max(#state.items, 1)
    local screenFrame = state.screen:frame()
    local maxColumns = math.max(1, math.floor((cfg.maxPanelWidth - (cfg.panelPadding * 2) + cfg.tileGap) / (cfg.tileWidth + cfg.tileGap)))
    local columns = math.min(count, maxColumns)
    local rows = math.ceil(count / columns)
    rows = math.min(rows, cfg.maxVisibleRows)

    local width = (cfg.panelPadding * 2) + (columns * cfg.tileWidth) + ((columns - 1) * cfg.tileGap)
    local height = (cfg.panelPadding * 2) + (rows * cfg.tileHeight) + ((rows - 1) * cfg.tileGap)

    return {
        columns = columns,
        rows = rows,
        frame = {
            x = math.floor(screenFrame.x + ((screenFrame.w - width) / 2)),
            y = math.floor(screenFrame.y + ((screenFrame.h - height) / 2)),
            w = width,
            h = height,
        },
    }
end

local function addPanel(elements, cfg, frame)
    table.insert(elements, {
        id = "panel-bg",
        type = "rectangle",
        action = "fill",
        frame = { x = 0, y = 0, w = frame.w, h = frame.h },
        roundedRectRadii = { xRadius = cfg.cornerRadius, yRadius = cfg.cornerRadius },
        fillColor = cfg.colors.panel,
    })

    table.insert(elements, {
        id = "panel-border",
        type = "rectangle",
        action = "stroke",
        strokeWidth = 1,
        frame = { x = 0.5, y = 0.5, w = frame.w - 1, h = frame.h - 1 },
        roundedRectRadii = { xRadius = cfg.cornerRadius, yRadius = cfg.cornerRadius },
        strokeColor = cfg.colors.border,
    })
end

local function addEmpty(elements, cfg, frame)
    table.insert(elements, {
        id = "empty",
        type = "text",
        text = "No switchable windows",
        frame = { x = 0, y = math.floor((frame.h - 18) / 2), w = frame.w, h = 24 },
        textAlignment = "center",
        textSize = cfg.emptyFontSize,
        textColor = cfg.colors.emptyText,
    })
end

local function clamp(value, minValue, maxValue)
    if value < minValue then return minValue end
    if value > maxValue then return maxValue end
    return value
end

local function updateVisibleStart(state, spec)
    local count = #state.items
    local cfg = state.config
    local totalRows = math.ceil(count / spec.columns)
    local maxStartRow = math.max(0, totalRows - spec.rows)
    local selectedRow = math.floor((state.selectedIndex - 1) / spec.columns)
    local startRow = math.floor(((state.visibleStartIndex or 1) - 1) / spec.columns)

    if selectedRow < startRow then
        startRow = selectedRow
    elseif selectedRow >= startRow + spec.rows then
        startRow = selectedRow - spec.rows + 1
    end

    startRow = clamp(startRow, 0, maxStartRow)
    state.visibleStartIndex = (startRow * spec.columns) + 1
    state.visibleCount = spec.columns * spec.rows

    return {
        startRow = startRow,
        totalRows = totalRows,
        track = {
            x = spec.frame.w - math.floor(cfg.panelPadding / 2) - cfg.scrollbarWidth,
            y = cfg.panelPadding,
            w = cfg.scrollbarWidth,
            h = spec.frame.h - (cfg.panelPadding * 2),
        },
    }
end

local function addScrollbar(elements, state, spec, scroll)
    if scroll.totalRows <= spec.rows then return end

    local cfg = state.config
    local track = scroll.track
    local thumbHeight = math.max(cfg.scrollbarMinHeight, math.floor(track.h * (spec.rows / scroll.totalRows)))
    local travel = track.h - thumbHeight
    local thumbY = track.y

    if travel > 0 then
        thumbY = track.y + math.floor(travel * (scroll.startRow / (scroll.totalRows - spec.rows)))
    end

    table.insert(elements, {
        id = "scrollbar-track",
        type = "rectangle",
        action = "fill",
        frame = track,
        roundedRectRadii = { xRadius = cfg.scrollbarWidth / 2, yRadius = cfg.scrollbarWidth / 2 },
        fillColor = cfg.colors.scrollbarTrack,
    })

    table.insert(elements, {
        id = "scrollbar-thumb",
        type = "rectangle",
        action = "fill",
        frame = { x = track.x, y = thumbY, w = track.w, h = thumbHeight },
        roundedRectRadii = { xRadius = cfg.scrollbarWidth / 2, yRadius = cfg.scrollbarWidth / 2 },
        fillColor = cfg.colors.scrollbarThumb,
    })
end

local function addAttentionBadge(elements, state, item, iconX, iconY, iconSize, index)
    local value = (state.accessibilityBadges or {})[item.key]
    if not value then return end

    local cfg = state.config
    local text = attentionText(state, value)
    local diameter = cfg.attentionDotSize
    local width = text ~= "" and math.max(diameter, (#text * 6) + 8) or diameter
    local x = iconX + iconSize - math.floor(width * 0.42)
    local y = math.max(6, iconY - math.floor(diameter * 0.35))

    table.insert(elements, {
        id = "attention-left-" .. tostring(index),
        type = "oval",
        action = "fill",
        frame = { x = x, y = y, w = diameter, h = diameter },
        fillColor = cfg.colors.attention,
    })

    if width > diameter then
        table.insert(elements, {
            id = "attention-center-" .. tostring(index),
            type = "rectangle",
            action = "fill",
            frame = { x = x + math.floor(diameter / 2), y = y, w = width - diameter, h = diameter },
            fillColor = cfg.colors.attention,
        })
    end

    table.insert(elements, {
        id = "attention-right-" .. tostring(index),
        type = "oval",
        action = "fill",
        frame = { x = x + width - diameter, y = y, w = diameter, h = diameter },
        fillColor = cfg.colors.attention,
    })

    if text ~= "" then
        table.insert(elements, {
            id = "attention-text-" .. tostring(index),
            type = "text",
            text = text,
            frame = { x = x, y = y + 1, w = width, h = diameter + 2 },
            textAlignment = "center",
            textSize = 9,
            textColor = cfg.colors.attentionText,
        })
    end
end

local function addTile(elements, state, item, x, y, index)
    local cfg = state.config
    local selected = index == state.selectedIndex
    local tileFrame = { x = x, y = y, w = cfg.tileWidth, h = cfg.tileHeight }

    if selected then
        table.insert(elements, {
            id = "selected-fill-" .. tostring(index),
            type = "rectangle",
            action = "fill",
            frame = tileFrame,
            roundedRectRadii = { xRadius = cfg.selectedRadius, yRadius = cfg.selectedRadius },
            fillColor = cfg.colors.selectedFill,
        })
        table.insert(elements, {
            id = "selected-border-" .. tostring(index),
            type = "rectangle",
            action = "stroke",
            strokeWidth = 1.2,
            frame = { x = x + 0.6, y = y + 0.6, w = cfg.tileWidth - 1.2, h = cfg.tileHeight - 1.2 },
            roundedRectRadii = { xRadius = cfg.selectedRadius, yRadius = cfg.selectedRadius },
            strokeColor = cfg.colors.selected,
        })
    end

    local iconX = x + math.floor((cfg.tileWidth - cfg.iconSize) / 2)
    local iconY = y + 13

    if item.icon then
        table.insert(elements, {
            id = "icon-" .. tostring(index),
            type = "image",
            image = item.icon,
            frame = {
                x = iconX,
                y = iconY,
                w = cfg.iconSize,
                h = cfg.iconSize,
            },
        })
    end

    addAttentionBadge(elements, state, item, iconX, iconY, cfg.iconSize, index)

    table.insert(elements, {
        id = "title-" .. tostring(index),
        type = "text",
        text = clampText(item.title, 24),
        frame = { x = x + 8, y = y + 66, w = cfg.tileWidth - 16, h = 18 },
        textAlignment = "center",
        textSize = cfg.titleFontSize,
        textColor = cfg.colors.titleText,
    })

    table.insert(elements, {
        id = "app-" .. tostring(index),
        type = "text",
        text = clampText(item.appName, 25),
        frame = { x = x + 8, y = y + 86, w = cfg.tileWidth - 16, h = 16 },
        textAlignment = "center",
        textSize = cfg.appFontSize,
        textColor = cfg.colors.appText,
    })

    table.insert(state.regions, {
        index = index,
        x = x,
        y = y,
        w = cfg.tileWidth,
        h = cfg.tileHeight,
    })
end

local function elementsFor(state, spec)
    local cfg = state.config
    local elements = {}
    state.regions = {}

    addPanel(elements, cfg, spec.frame)

    if #state.items == 0 then
        addEmpty(elements, cfg, spec.frame)
        return elements
    end

    local scroll = updateVisibleStart(state, spec)
    local startIndex = state.visibleStartIndex or 1
    local visibleCount = spec.columns * spec.rows

    for visibleIndex = 1, visibleCount do
        local itemIndex = startIndex + visibleIndex - 1
        local item = state.items[itemIndex]
        if not item then break end

        local column = (visibleIndex - 1) % spec.columns
        local row = math.floor((visibleIndex - 1) / spec.columns)
        local x = cfg.panelPadding + (column * (cfg.tileWidth + cfg.tileGap))
        local y = cfg.panelPadding + (row * (cfg.tileHeight + cfg.tileGap))
        addTile(elements, state, item, x, y, itemIndex)
    end

    addScrollbar(elements, state, spec, scroll)

    return elements
end

function M.show(state)
    local spec = layout(state)
    state.layout = spec

    if not state.canvas then
        state.canvas = hs.canvas.new(spec.frame)
        state.canvas:level(hs.canvas.windowLevels.modalPanel)
        state.canvas:behaviorAsLabels({ "canJoinAllSpaces", "stationary", "ignoresCycle" })
        state.canvas:clickActivating(false)
        state.canvas:canvasMouseEvents(true, true, true, true)
        state.canvas:mouseCallback(function(_, message, _, x, y)
            if message == "mouseDown" then
                state.onClick(x, y)
            elseif message == "mouseMove" or message == "mouseEnter" then
                state.onMouseMove(x, y)
            elseif message == "mouseExit" then
                state.onMouseExit()
            end
        end)
    else
        state.canvas:frame(spec.frame)
    end

    state.canvas:replaceElements(elementsFor(state, spec))
    state.canvas:show()
end

function M.render(state)
    if state.visible and state.canvas then M.show(state) end
end

function M.hide(state)
    if state.canvas then
        state.canvas:hide()
    end
end

function M.delete(state)
    if state.canvas then
        state.canvas:delete()
        state.canvas = nil
    end
    state.regions = {}
end

function M.hitTest(state, x, y)
    for _, region in ipairs(state.regions or {}) do
        if x >= region.x and x <= region.x + region.w and y >= region.y and y <= region.y + region.h then
            return region.index
        end
    end

    return nil
end

return M
