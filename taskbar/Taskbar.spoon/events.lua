--- Event watchers for Taskbar.
---
--- This module wires Hammerspoon app and screen notifications into the central
--- state object. It schedules short deferred updates to coalesce noisy events.

local M = {}

local appWatcher = hs.application.watcher

local function flush(state)
    if state.stopped then return end

    local reasons = state.pendingReasons

    state.pendingRefresh = false
    state.pendingTimer = nil
    state.pendingReasons = {}

    state.logger.df("refreshing after %s", table.concat(reasons, ","))

    if state.needsScreenRefresh then
        state.needsScreenRefresh = false
        state.needsAppRefresh = false
        state.needsFrontmostRefresh = false

        state.appsModule.refresh(state)
        state.pins.reconcile(state)
        state.screenList = state.screens.current()
        state.hoveredAppKey = nil
        state.drawing.rebuildBars(state, state.screenList, state.onMouseEvent)
        state.reservation.apply(state)
        state.attention.refresh(state)
        return
    end

    if state.needsAppRefresh then
        state.needsAppRefresh = false
        state.needsFrontmostRefresh = false

        state.appsModule.refresh(state)
        state.pins.reconcile(state)
        state.hoveredAppKey = nil
        state.drawing.render(state, state.screenList)
        state.reservation.apply(state)
        state.attention.refresh(state)
        return
    end

    if state.needsFrontmostRefresh then
        state.needsFrontmostRefresh = false

        state.appsModule.updateFrontmost(state)
        state.drawing.render(state, state.screenList)
    end
end

local function schedule(state, reason)
    state.pendingReasons = state.pendingReasons or {}
    table.insert(state.pendingReasons, reason)

    if state.pendingRefresh then
        return
    end

    state.pendingRefresh = true

    state.pendingTimer = hs.timer.doAfter(0.05, function()
        flush(state)
    end)
end

local function appEventName(event)
    if event == appWatcher.launched then return "launched" end
    if event == appWatcher.terminated then return "terminated" end
    if event == appWatcher.activated then return "activated" end
    if event == appWatcher.hidden then return "hidden" end
    if event == appWatcher.unhidden then return "unhidden" end
    return tostring(event)
end

--- Starts app and screen watchers.
function M.start(state)
    if state.appWatcher then return end

    state.appWatcher = appWatcher.new(function(appName, event, app)
        local eventName = appEventName(event)
        state.logger.df("application event: %s %s", eventName, tostring(appName))

        if event == appWatcher.launched or event == appWatcher.terminated then
            state.needsAppRefresh = true
            schedule(state, eventName)
        elseif event == appWatcher.activated then
            if app and state.appsModule.isDisplayable(app, state.config) then
                state.attention.clearForApp(state, app)
                state.needsFrontmostRefresh = true
                schedule(state, eventName)
            end
        end
    end)

    state.appWatcher:start()

    state.screenWatcher = hs.screen.watcher.new(function()
        state.needsScreenRefresh = true
        schedule(state, "screens")
    end)

    state.screenWatcher:start()
end

--- Stops all active Hammerspoon watchers.
function M.stop(state)
    state.stopped = true

    if state.pendingTimer then
        state.pendingTimer:stop()
        state.pendingTimer = nil
    end

    if state.appWatcher then
        state.appWatcher:stop()
        state.appWatcher = nil
    end

    if state.screenWatcher then
        state.screenWatcher:stop()
        state.screenWatcher = nil
    end
end

return M
