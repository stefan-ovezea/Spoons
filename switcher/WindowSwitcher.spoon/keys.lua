local M = {}

local modifierKeys = {
    cmd = true,
    command = true,
    shift = true,
    alt = true,
    option = true,
    ctrl = true,
    control = true,
}

local modifierAliases = {
    command = "cmd",
    option = "alt",
    control = "ctrl",
}

local function isCommandDown(flags)
    return flags.cmd == true or flags.command == true
end

local function tabDirection(event)
    local flags = event:getFlags()
    if not isCommandDown(flags) then return nil end
    if event:getKeyCode() ~= hs.keycodes.map.tab then return nil end

    return flags.shift and -1 or 1
end

local function scrollDelta(event)
    local properties = hs.eventtap.event.properties
    local ok, value = pcall(function()
        return event:getProperty(properties.scrollWheelEventDeltaAxis1)
    end)

    if ok and value and value ~= 0 then return value end

    ok, value = pcall(function()
        return event:getProperty(properties.scrollWheelEventPointDeltaAxis1)
    end)

    if ok and value and value ~= 0 then return value end

    return 0
end

local function isMouseWheel(event)
    local properties = hs.eventtap.event.properties
    local ok, value = pcall(function()
        return event:getProperty(properties.scrollWheelEventInstantMouser)
    end)

    if ok and value then return true end

    ok, value = pcall(function()
        return event:getProperty(properties.scrollWheelEventIsContinuous)
    end)

    return ok and value == false
end

local function normalizedModifier(modifier)
    return modifierAliases[modifier] or modifier
end

local function modifierSet(mods)
    local set = {}
    for _, modifier in ipairs(mods or {}) do
        set[normalizedModifier(modifier)] = true
    end
    return set
end

local function specMatches(event, spec)
    if not spec then return false end

    local mods = modifierSet(spec[1])
    local key = spec[2]
    local expectedKeyCode = hs.keycodes.map[key]
    if not expectedKeyCode or event:getKeyCode() ~= expectedKeyCode then return false end

    local flags = event:getFlags()
    for modifier in pairs(modifierKeys) do
        local normalized = normalizedModifier(modifier)
        local expected = mods[normalized] == true
        local actual = flags[modifier] == true or flags[normalized] == true
        if expected ~= actual then return false end
    end

    return true
end

function M.start(state)
    if state.keysStarted then return end

    state.keyTap = hs.eventtap.new({
        hs.eventtap.event.types.flagsChanged,
        hs.eventtap.event.types.keyDown,
        hs.eventtap.event.types.keyUp,
        hs.eventtap.event.types.scrollWheel,
    }, function(event)
        local eventType = event:getType()
        if eventType == hs.eventtap.event.types.flagsChanged then
            if not isCommandDown(event:getFlags()) then
                if state.commandTabPending then
                    state.acceptOnOpen = true
                    return true
                end
                if not state.visible then return false end
                state.accept()
                return true
            end
            return false
        end

        if eventType == hs.eventtap.event.types.scrollWheel then
            if not state.visible or not state.containsPoint(event:location()) then return false end

            local delta = scrollDelta(event)
            local rows = 0
            if delta < 0 then
                rows = 1
            elseif delta > 0 then
                rows = -1
            end

            if rows ~= 0 then
                if state.config.reverseMouseWheelScroll and isMouseWheel(event) then
                    rows = -rows
                end
                state.scrollRows(rows)
            end

            return true
        end

        if state.config.overrideCommandTab then
            local direction = tabDirection(event)
            if direction then
                if eventType == hs.eventtap.event.types.keyDown then
                    state.commandTabPending = true
                    hs.timer.doAfter(0, function()
                        state.commandTabPending = false
                        state.switch(direction)
                    end)
                end
                return true
            end
        end

        if eventType == hs.eventtap.event.types.keyUp then
            return state.visible
        end

        if specMatches(event, state.config.hotkeys.previous) then
            state.switch(-1)
            return true
        end

        if specMatches(event, state.config.hotkeys.next) then
            state.switch(1)
            return true
        end

        if not state.visible then return false end

        local code = event:getKeyCode()
        if code == hs.keycodes.map.escape then
            state.cancel()
            return true
        end

        if code == hs.keycodes.map["return"] or code == hs.keycodes.map.space then
            state.accept()
            return true
        end

        if code == hs.keycodes.map.right then
            state.move(1)
            return true
        end

        if code == hs.keycodes.map.left then
            state.move(-1)
            return true
        end

        if code == hs.keycodes.map.down then
            state.moveRows(1)
            return true
        end

        if code == hs.keycodes.map.up then
            state.moveRows(-1)
            return true
        end

        return false
    end)
    state.keyTap:start()
    state.keyTapWatchdog = hs.timer.doEvery(state.config.keyTapWatchdogInterval, function()
        local enabled = true
        if state.keyTap and state.keyTap.isEnabled then
            local ok, value = pcall(function()
                return state.keyTap:isEnabled()
            end)
            enabled = ok and value == true
        end

        if state.keyTap and not enabled then
            state.logger.w("key event tap was disabled; restarting")
            state.keyTap:start()
        end
    end)
    state.keysStarted = true
end

function M.stop(state)
    if state.keyTapWatchdog then
        state.keyTapWatchdog:stop()
        state.keyTapWatchdog = nil
    end

    if state.keyTap then
        state.keyTap:stop()
        state.keyTap = nil
    end

    state.keysStarted = false
end

return M
