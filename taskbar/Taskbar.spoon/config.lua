--- Default configuration for Taskbar.
---
--- Values in this module are copied into the Spoon instance and may be
--- overridden from the user's Hammerspoon init.lua before calling :start().

local config = {
    barHeight = 34,
    iconSize = 20,
    hoverIconGrowth = 3,
    hoverIconLift = 1,
    padding = 8,
    itemSpacing = 6,
    placement = "bottom",
    logLevel = "info",
    reserveScreenSpace = true,
    reservationDebounce = 0.12,
    pinnedApps = {},
    persistPinnedApps = true,
    contextMenu = true,
    dragReorder = true,
    dragThreshold = 5,
    separatorWidth = 1,
    separatorSpacing = 8,
    showClock = true,
    clockFormat = "%a %d %b  %H:%M",
    clockWidth = 122,
    widgetSpacing = 8,
    widgetButtonWidth = 34,
    showTrash = true,
    trashIconSize = 18,
    trashDebug = false,
    widgetRefreshInterval = 15,
    accessibilityBadges = true,
    accessibilityBadgeInterval = 2,
    accessibilityScanMaxNodes = 700,
    accessibilityScanMaxDepth = 12,
    accessibilityDebug = false,
    accessibilityDebugMaxLines = 80,
    notificationCenterObserver = true,
    notificationCenterDebug = false,
    notificationCenterEvents = { "layoutChanged", "created" },
    attentionDotSize = 12,
    attentionCounter = true,
    attentionCounterMax = 99,
    runningIndicatorWidth = 14,
    runningIndicatorHeight = 3,
    runningIndicatorRadius = 1.5,
    runningIndicatorDotSize = 4,
    runningIndicatorBottom = 3,
    debugNotificationBadge = false,
    debugNotificationBadgeCount = 3,
    debugNotificationBadgeName = "Badge Test",
    accessibilityBadgeKeywords = {
        "notification",
        "notifications",
        "unread",
        "message",
        "messages",
        "alert",
        "alerts",
    },

    colors = {
        background = { red = 0.1176, green = 0.1176, blue = 0.1804, alpha = 0.90 }, -- Base
        separator = { red = 0.3451, green = 0.3569, blue = 0.4392, alpha = 0.70 }, -- Surface 2
        clockText = { red = 0.8039, green = 0.8392, blue = 0.9569, alpha = 1.0 }, -- Text
        trash = { red = 0.7294, green = 0.7608, blue = 0.8706, alpha = 1.0 }, -- Subtext 1
        trashFull = { red = 0.8039, green = 0.8392, blue = 0.9569, alpha = 1.0 }, -- Text
        trashFill = { red = 0.5373, green = 0.7059, blue = 0.9804, alpha = 0.80 }, -- Blue
        attention = { red = 0.9529, green = 0.5451, blue = 0.6588, alpha = 1.0 }, -- Red
        attentionText = { red = 0.1176, green = 0.1176, blue = 0.1804, alpha = 1.0 }, -- Base
        runningIndicator = { red = 0.7961, green = 0.6510, blue = 0.9686, alpha = 0.95 }, -- Mauve
    },

    excludedApps = {
        ["com.apple.dock"] = true,
        ["com.apple.WindowManager"] = true,
        ["com.apple.controlcenter"] = true,
        ["com.apple.notificationcenterui"] = true,
        ["com.apple.SystemUIServer"] = true,
        ["org.hammerspoon.Hammerspoon"] = true,
    },
}

return config
