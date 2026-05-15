local function rgba(red, green, blue, alpha)
    return {
        red = red / 255,
        green = green / 255,
        blue = blue / 255,
        alpha = alpha or 1.0,
    }
end

local mocha = {
    mauve = rgba(203, 166, 247),
    lavender = rgba(180, 190, 254),
    blue = rgba(137, 180, 250),
    text = rgba(205, 214, 244),
    subtext0 = rgba(166, 173, 200),
    subtext1 = rgba(186, 194, 222),
    overlay0 = rgba(108, 112, 134),
    overlay2 = rgba(147, 153, 178),
    surface0 = rgba(49, 50, 68),
    surface1 = rgba(69, 71, 90),
    surface2 = rgba(88, 91, 112),
    base = rgba(30, 30, 46),
    mantle = rgba(24, 24, 37),
}

local function withAlpha(color, alpha)
    return {
        red = color.red,
        green = color.green,
        blue = color.blue,
        alpha = alpha,
    }
end

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
        panel = withAlpha(mocha.base, 0.96),
        border = withAlpha(mocha.surface2, 0.86),
        selected = withAlpha(mocha.lavender, 0.82),
        selectedFill = withAlpha(mocha.surface1, 0.70),
        scrollbarTrack = withAlpha(mocha.overlay0, 0.24),
        scrollbarThumb = withAlpha(mocha.subtext1, 0.78),
        titleText = mocha.text,
        appText = mocha.subtext0,
        emptyText = mocha.subtext1,
    },
    palette = mocha,
}

return M
