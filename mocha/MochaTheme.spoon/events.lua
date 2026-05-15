--- Event watchers for MochaTheme.

local M = {}

local function rebuild(state)
    if state.stopped then return end

    state.pendingRefresh = false
    state.pendingTimer = nil
    state.logger.d("rebuilding menu bar tint canvases")
    state.drawing.rebuild(state)
end

local function schedule(state)
    if state.pendingRefresh then return end

    state.pendingRefresh = true
    state.pendingTimer = hs.timer.doAfter(0.08, function()
        rebuild(state)
    end)
end

function M.start(state)
    if state.screenWatcher then return end

    state.screenWatcher = hs.screen.watcher.new(function()
        schedule(state)
    end)
    state.screenWatcher:start()

    state.caffeinateWatcher = hs.caffeinate.watcher.new(function(event)
        if event == hs.caffeinate.watcher.screensDidWake
            or event == hs.caffeinate.watcher.systemDidWake then
            schedule(state)
        end
    end)
    state.caffeinateWatcher:start()
end

function M.stop(state)
    state.stopped = true

    if state.pendingTimer then
        state.pendingTimer:stop()
        state.pendingTimer = nil
    end

    if state.screenWatcher then
        state.screenWatcher:stop()
        state.screenWatcher = nil
    end

    if state.caffeinateWatcher then
        state.caffeinateWatcher:stop()
        state.caffeinateWatcher = nil
    end
end

return M
