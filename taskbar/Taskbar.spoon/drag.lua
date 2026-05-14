--- Left-click drag handling for Taskbar.
---
--- Dragging is handled with hs.eventtap instead of hs.canvas callbacks because
--- canvas mouse movement depends on per-element tracking flags. The eventtap
--- path gives us reliable click-hold-drag behavior over the whole bar.

local M = {}

local function clamp(value, minValue, maxValue)
    if value < minValue then return minValue end
    if value > maxValue then return maxValue end
    return value
end

local function appForKey(state, key)
    for _, app in ipairs(state.apps or {}) do
        if app.key == key then return app end
    end

    return nil
end

local function barAtPoint(state, point)
    for screenID, bar in pairs(state.bars or {}) do
        local frame = bar.frame
        local inX = point.x >= frame.x and point.x <= frame.x + frame.w
        local inY = point.y >= frame.y and point.y <= frame.y + frame.h

        if inX and inY then
            return screenID, bar, point.x - frame.x, point.y - frame.y
        end
    end

    return nil
end

local function localPointForBar(bar, point)
    local x = point.x - bar.frame.x
    local y = point.y - bar.frame.y

    x = clamp(x, 0, bar.frame.w)
    y = clamp(y, 0, bar.frame.h)

    return x, y
end

local function activateApp(state, app)
    if not app or app.isDebug then return end

    state.appsModule.activate(state, app.key)
    state.attention.clearForApp(state, app.app)
    state.appsModule.updateFrontmost(state)
    state.drawing.render(state, state.screenList)
end

local function openTrash(state)
    state.trash.open()
end

local function applyLiveOrder(state, bar, x)
    local mode
    local index

    if state.drawing.isPinnedDrop(bar, x) then
        mode = "pinned"
        index = state.drawing.pinnedInsertionIndex(bar, x)
    else
        mode = "unpinned"
        index = state.drawing.unpinnedInsertionIndex(bar, x)
    end

    if state.dragDropMode == mode and state.dragDropIndex == index then
        return false
    end

    state.dragDropMode = mode
    state.dragDropIndex = index

    if mode == "pinned" then
        state.pins.pin(state, state.draggingKey, index)
    else
        state.pins.reorderUnpinned(state, state.draggingKey, index)
    end

    return true
end

local function startDragCandidate(state, point)
    local screenID, bar, x, y = barAtPoint(state, point)
    if not bar then return false end

    local region = state.drawing.regionAt(bar, x, y)
    if not region then return false end

    if region.kind == "trash" then
        state.dragCandidate = {
            kind = "trash",
            screenID = screenID,
            startX = x,
            startY = y,
        }
        return true
    end

    local app = appForKey(state, region.key)
    if not app or app.isDebug then return false end

    state.dragCandidate = {
        key = region.key,
        app = app,
        screenID = screenID,
        startX = x,
        startY = y,
    }

    return true
end

local function updateDrag(state, point)
    local candidate = state.dragCandidate
    if not candidate then return false end
    if candidate.kind == "trash" then return true end

    local bar = state.bars[candidate.screenID]
    if not bar then return false end

    local x, y = localPointForBar(bar, point)
    local dx = math.abs(x - candidate.startX)
    local dy = math.abs(y - candidate.startY)

    if not state.draggingKey then
        if dx < state.config.dragThreshold and dy < state.config.dragThreshold then
            return true
        end

        state.draggingKey = candidate.key
        state.hoveredAppKey = nil
        state.suspendPinSave = true
    end

    local changed = applyLiveOrder(state, bar, x)
    if changed then
        state.drawing.render(state, state.screenList)
    end

    return true
end

local function finishDrag(state, point)
    local candidate = state.dragCandidate
    if not candidate then return false end

    if candidate.kind == "trash" then
        state.dragCandidate = nil
        openTrash(state)
        return true
    end

    local bar = state.bars[candidate.screenID]

    if state.draggingKey and bar then
        local x = localPointForBar(bar, point)
        applyLiveOrder(state, bar, x)
        state.suspendPinSave = false
        state.pins.save(state)
        state.dragCandidate = nil
        state.draggingKey = nil
        state.dragDropMode = nil
        state.dragDropIndex = nil
        state.drawing.render(state, state.screenList)
        return true
    end

    state.dragCandidate = nil
    state.draggingKey = nil
    state.dragDropMode = nil
    state.dragDropIndex = nil
    state.suspendPinSave = false
    activateApp(state, candidate.app)
    return true
end

function M.start(state)
    if state.dragTap then return end

    state.dragTap = hs.eventtap.new({
        hs.eventtap.event.types.leftMouseDown,
        hs.eventtap.event.types.leftMouseDragged,
        hs.eventtap.event.types.leftMouseUp,
    }, function(event)
        local eventType = event:getType()
        local point = event:location()

        if eventType == hs.eventtap.event.types.leftMouseDown then
            return startDragCandidate(state, point)
        end

        if eventType == hs.eventtap.event.types.leftMouseDragged then
            return updateDrag(state, point)
        end

        if eventType == hs.eventtap.event.types.leftMouseUp then
            return finishDrag(state, point)
        end

        return false
    end)

    state.dragTap:start()
end

function M.stop(state)
    if state.dragTap then
        state.dragTap:stop()
        state.dragTap = nil
    end

    state.dragCandidate = nil
    state.draggingKey = nil
    state.dragDropMode = nil
    state.dragDropIndex = nil
    state.suspendPinSave = false
end

return M
