--- Accessibility-backed attention discovery for Hammerbar.
---
--- This module is intentionally best-effort. It scans the Dock accessibility
--- tree for app items whose accessible text appears to mention unread
--- notifications. macOS and individual apps may expose different text, so this
--- remains configurable and falls back cleanly when no signal is available.

local M = {}

local notificationSubroles = {
    AXNotificationCenterAlert = true,
    AXNotificationCenterBanner = true,
}

local function call(object, method, ...)
    if not object or not object[method] then return nil end

    local args = { ... }
    local ok, value = pcall(function()
        return object[method](object, table.unpack(args))
    end)
    if ok then return value end
    return nil
end

local function lower(value)
    if type(value) ~= "string" then return nil end
    return value:lower()
end

local function appNeedles(app)
    local names = {}

    if app.name and app.name ~= "" then
        table.insert(names, app.name:lower())
    end

    if app.bundleID and app.bundleID ~= "" then
        table.insert(names, app.bundleID:lower())
    end

    return names
end

local function appendString(target, value)
    if type(value) == "string" and value ~= "" then
        table.insert(target, value)
    elseif type(value) == "number" and value > 0 then
        table.insert(target, tostring(value))
    end
end

local function appendAttributeStrings(target, element)
    local attrs = call(element, "allAttributeValues")
    if type(attrs) ~= "table" then return end

    appendString(target, attrs.AXTitle)
    appendString(target, attrs.AXDescription)
    appendString(target, attrs.AXHelp)
    appendString(target, attrs.AXValue)
    appendString(target, attrs.AXLabel)
end

local function joinedStrings(strings)
    if #strings == 0 then return nil end
    return table.concat(strings, " ")
end

local function collectDockTexts(state)
    local dock = hs.application.get("com.apple.dock") or hs.application.get("Dock")
    if not dock then return {} end

    local root = hs.axuielement.applicationElement(dock)
    if not root then return {} end

    local texts = {}
    local visited = 0

    local function visit(element, depth, inheritedText)
        if not element then return end
        if depth > state.config.accessibilityScanMaxDepth then return end
        if visited >= state.config.accessibilityScanMaxNodes then return end

        visited = visited + 1

        local ownStrings = {}
        appendAttributeStrings(ownStrings, element)

        local ownText = joinedStrings(ownStrings)
        local combinedText = inheritedText
        if ownText then
            combinedText = combinedText and (combinedText .. " " .. ownText) or ownText
            table.insert(texts, ownText)
            table.insert(texts, combinedText)
        end

        local children = call(element, "attributeValue", "AXChildren")
        if type(children) ~= "table" then return end

        for _, child in ipairs(children) do
            visit(child, depth + 1, combinedText)
        end
    end

    visit(root, 0, nil)
    return texts
end

local function logDockTexts(state, texts)
    if not state.config.accessibilityDebug then return end

    local maxLines = state.config.accessibilityDebugMaxLines or 80
    state.logger.df("accessibility scan: %d Dock text samples", #texts)

    for index, text in ipairs(texts) do
        if index > maxLines then
            state.logger.df("accessibility scan: truncated %d additional samples", #texts - maxLines)
            break
        end

        state.logger.df("accessibility Dock text[%d]: %s", index, tostring(text))
    end
end

local function hasAttentionText(state, text)
    local normalized = lower(text)
    if not normalized then return false end

    for _, keyword in ipairs(state.config.accessibilityBadgeKeywords or {}) do
        if normalized:find(keyword, 1, true) then return true end
    end

    if normalized:match("%f[%d]%d+%f[%D]") then return true end

    return false
end

local function textMatchesApp(text, needles)
    local normalized = lower(text)
    if not normalized then return false end

    for _, needle in ipairs(needles) do
        if normalized:find(needle, 1, true) then return true end
    end

    return false
end

local function notificationCenterElement()
    return hs.axuielement.applicationElement("com.apple.notificationcenterui")
end

local function elementAttribute(element, name)
    return call(element, "attributeValue", name)
end

local function notificationIdentifier(element)
    return elementAttribute(element, "AXIdentifier")
        or elementAttribute(element, "AXTitle")
        or tostring(element)
end

local function notificationStackingID(element)
    return elementAttribute(element, "AXStackingIdentifier") or ""
end

local function bundleIDFromStackingID(stackingID)
    if stackingID == "" then return nil end

    local bundleID = stackingID:match("bundleIdentifier=([^,]+)")
    if bundleID then return bundleID end

    return stackingID:match("^([%w%.%-]+)")
end

local function appMatchesStackingID(app, stackingID)
    if stackingID == "" then return false end

    local stackingBundleID = bundleIDFromStackingID(stackingID)

    if app.bundleID and stackingBundleID == app.bundleID then
        return true
    end

    if app.bundleID and stackingID:find(app.bundleID, 1, true) then
        return true
    end

    if app.name and stackingID:lower():find(app.name:lower(), 1, true) then
        return true
    end

    return false
end

local function markNotificationAttention(state, stackingID)
    for _, app in ipairs(state.apps or {}) do
        if appMatchesStackingID(app, stackingID) then
            local current = tonumber(state.accessibilityBadges[app.key]) or 0
            state.accessibilityBadges[app.key] = current + 1

            if state.config.notificationCenterDebug or state.config.accessibilityDebug then
                state.logger.df(
                    "notification attention match: %s count=%d via stacking ID %s",
                    app.name,
                    state.accessibilityBadges[app.key],
                    stackingID
                )
            end

            return true
        end
    end

    if state.config.notificationCenterDebug or state.config.accessibilityDebug then
        state.logger.df(
            "notification attention unmatched stacking ID: %s parsedBundleID=%s",
            stackingID,
            tostring(bundleIDFromStackingID(stackingID))
        )
    end

    return false
end

local function staticTexts(element)
    local values = {}

    local function visit(current)
        local role = elementAttribute(current, "AXRole")
        local value = elementAttribute(current, "AXValue")

        if role == "AXStaticText" and value then
            table.insert(values, value)
        end

        local children = elementAttribute(current, "AXChildren")
        if type(children) ~= "table" then return end

        for _, child in ipairs(children) do
            visit(child)
        end
    end

    visit(element)
    return values
end

local function elementSummary(element)
    return string.format(
        "role=%s subrole=%s identifier=%s title=%s value=%s description=%s stackingID=%s",
        tostring(elementAttribute(element, "AXRole")),
        tostring(elementAttribute(element, "AXSubrole")),
        tostring(elementAttribute(element, "AXIdentifier")),
        tostring(elementAttribute(element, "AXTitle")),
        tostring(elementAttribute(element, "AXValue")),
        tostring(elementAttribute(element, "AXDescription")),
        tostring(notificationStackingID(element))
    )
end

local function logNotification(state, element, stackingID)
    if not (state.config.notificationCenterDebug or state.config.accessibilityDebug) then return end

    local texts = staticTexts(element)
    state.logger.df(
        "notification observed: subrole=%s stackingID=%s id=%s text=%s",
        tostring(elementAttribute(element, "AXSubrole")),
        tostring(stackingID),
        tostring(notificationIdentifier(element)),
        table.concat(texts, " | ")
    )
end

local function handleNotificationElement(state, element, depth)
    if not element then return end
    if depth and depth > 4 then return end

    local subrole = elementAttribute(element, "AXSubrole")
    if not notificationSubroles[subrole] then
        if depth == 0 and (state.config.notificationCenterDebug or state.config.accessibilityDebug) then
            state.logger.df("notification observer callback root: %s", elementSummary(element))
        end

        local children = elementAttribute(element, "AXChildren")
        if type(children) ~= "table" then return end

        for _, child in ipairs(children) do
            handleNotificationElement(state, child, (depth or 0) + 1)
        end

        return
    end

    local identifier = notificationIdentifier(element)
    if state.processedNotificationIDs[identifier] then return end
    state.processedNotificationIDs[identifier] = true

    local stackingID = notificationStackingID(element)
    logNotification(state, element, stackingID)

    if stackingID == "" then return end
    if markNotificationAttention(state, stackingID) then
        state.drawing.render(state, state.screenList)
    end
end

local function addObserverWatcher(observer, element, eventName)
    local notificationName = hs.axuielement.observer.notifications[eventName]
    if not notificationName then return observer end

    return observer:addWatcher(element, notificationName)
end

local function collectNotificationCenterTexts(state)
    local notificationCenter = notificationCenterElement()
    if not notificationCenter then return {} end

    local texts = {}
    local visited = 0

    local function visit(element, depth)
        if not element then return end
        if depth > state.config.accessibilityScanMaxDepth then return end
        if visited >= state.config.accessibilityScanMaxNodes then return end

        visited = visited + 1
        table.insert(texts, elementSummary(element))

        local children = elementAttribute(element, "AXChildren")
        if type(children) ~= "table" then return end

        for _, child in ipairs(children) do
            visit(child, depth + 1)
        end
    end

    visit(notificationCenter, 0)
    return texts
end

local function startNotificationObserver(state)
    if not state.config.notificationCenterObserver or state.notificationObserver then return end

    local notificationCenter = notificationCenterElement()
    if not notificationCenter then
        state.logger.w("notification center AX element unavailable")
        return
    end

    local app = call(notificationCenter, "asHSApplication")
    local pid = app and call(app, "pid")
    if not pid then
        state.logger.w("notification center pid unavailable")
        return
    end

    state.processedNotificationIDs = state.processedNotificationIDs or {}
    local observer = hs.axuielement.observer
        .new(pid)
        :callback(function(_, element, notification)
            if state.config.notificationCenterDebug or state.config.accessibilityDebug then
                state.logger.df("notification observer event: %s", tostring(notification))
            end
            handleNotificationElement(state, element, 0)
        end)

    for _, eventName in ipairs(state.config.notificationCenterEvents or { "layoutChanged" }) do
        observer = addObserverWatcher(observer, notificationCenter, eventName)
    end

    state.notificationObserver = observer:start()

    if state.config.notificationCenterDebug or state.config.accessibilityDebug then
        state.logger.d("notification center observer started")
    end
end

local function stopNotificationObserver(state)
    if state.notificationObserver then
        state.notificationObserver:stop()
        state.notificationObserver = nil
    end
end

--- Scans the Dock accessibility tree and stores red-dot attention flags.
function M.refresh(state)
    if not state.config.accessibilityBadges then return end

    local texts = collectDockTexts(state)
    local found = state.accessibilityBadges or {}
    logDockTexts(state, texts)

    for _, app in ipairs(state.apps or {}) do
        local needles = appNeedles(app)

        for _, text in ipairs(texts) do
            if textMatchesApp(text, needles) and hasAttentionText(state, text) then
                if not found[app.key] then found[app.key] = 1 end
                if state.config.accessibilityDebug then
                    state.logger.df("accessibility attention match: %s via %s", app.name, tostring(text))
                end
                break
            end
        end
    end

    if state.config.accessibilityDebug then
        local count = 0
        for _ in pairs(found) do count = count + 1 end
        state.logger.df("accessibility scan: %d attention matches", count)
    end

    state.accessibilityBadges = found
    state.drawing.render(state, state.screenList)
end

--- Returns raw Dock accessibility text samples for troubleshooting.
function M.debugTexts(state)
    return collectDockTexts(state)
end

--- Returns raw Notification Center accessibility summaries for troubleshooting.
function M.debugNotificationCenterTexts(state)
    return collectNotificationCenterTexts(state)
end

function M.start(state)
    startNotificationObserver(state)
    if not state.config.accessibilityBadges or state.attentionTimer then return end

    M.refresh(state)
    state.attentionTimer = hs.timer.doEvery(state.config.accessibilityBadgeInterval, function()
        M.refresh(state)
    end)
end

function M.stop(state)
    stopNotificationObserver(state)

    if state.attentionTimer then
        state.attentionTimer:stop()
        state.attentionTimer = nil
    end

    state.accessibilityBadges = nil
end

--- Clears any attention dot for a focused/handled app.
function M.clearForApp(state, app)
    if not app or not state.accessibilityBadges then return end

    for _, record in ipairs(state.apps or {}) do
        if record.app == app then
            state.accessibilityBadges[record.key] = nil
            return
        end
    end

    local bundleID = call(app, "bundleID")
    if not bundleID then return end

    for _, record in ipairs(state.apps or {}) do
        if record.bundleID == bundleID then
            state.accessibilityBadges[record.key] = nil
            return
        end
    end
end

return M
