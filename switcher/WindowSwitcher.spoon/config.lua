local M = {
    logLevel = "info",

    hotkeys = {
        next = { { "cmd" }, "tab" },
        previous = { { "cmd", "shift" }, "tab" },
    },
    overrideCommandTab = true,
    keyTapWatchdogInterval = 1.0,

    includeMinimized = true,
    includeHidden = true,
    includeUntitledWindows = false,
    refreshInterval = 1.0,
    refreshDebounce = 0.12,
    excludedApps = {
        ["com.apple.dock"] = true,
        ["org.hammerspoon.Hammerspoon"] = true,
    },

    maxPanelWidth = 760,
    maxVisibleRows = 3,
    tileWidth = 150,
    tileHeight = 116,
    iconSize = 46,
    panelPadding = 14,
    tileGap = 8,
    cornerRadius = 10,
    selectedRadius = 7,
    scrollbarWidth = 4,
    scrollbarMinHeight = 22,
    reverseMouseWheelScroll = true,

    titleFontSize = 12,
    appFontSize = 10,
    emptyFontSize = 13,

    colors = {
        panel = { red = 0.10, green = 0.11, blue = 0.13, alpha = 0.94 },
        border = { red = 0.32, green = 0.35, blue = 0.40, alpha = 0.85 },
        selected = { red = 0.20, green = 0.42, blue = 0.90, alpha = 0.92 },
        selectedFill = { red = 0.20, green = 0.42, blue = 0.90, alpha = 0.18 },
        scrollbarTrack = { red = 0.45, green = 0.48, blue = 0.54, alpha = 0.22 },
        scrollbarThumb = { red = 0.74, green = 0.77, blue = 0.82, alpha = 0.72 },
        titleText = { red = 0.95, green = 0.96, blue = 0.98, alpha = 1.0 },
        appText = { red = 0.68, green = 0.72, blue = 0.78, alpha = 1.0 },
        emptyText = { red = 0.82, green = 0.84, blue = 0.88, alpha = 1.0 },
    },
}

return M
