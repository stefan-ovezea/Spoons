--- Default configuration for MochaTheme.
---
--- Values in this module are copied into the Spoon instance and may be
--- overridden from the user's Hammerspoon init.lua before calling :start().

local palette = {
    rosewater = { red = 0.9608, green = 0.8784, blue = 0.8627, alpha = 1.0 },
    flamingo = { red = 0.9490, green = 0.8039, blue = 0.8039, alpha = 1.0 },
    pink = { red = 0.9608, green = 0.7608, blue = 0.9059, alpha = 1.0 },
    mauve = { red = 0.7961, green = 0.6510, blue = 0.9686, alpha = 1.0 },
    red = { red = 0.9529, green = 0.5451, blue = 0.6588, alpha = 1.0 },
    maroon = { red = 0.9216, green = 0.6275, blue = 0.6745, alpha = 1.0 },
    peach = { red = 0.9804, green = 0.7020, blue = 0.5294, alpha = 1.0 },
    yellow = { red = 0.9765, green = 0.8863, blue = 0.6863, alpha = 1.0 },
    green = { red = 0.6510, green = 0.8902, blue = 0.6314, alpha = 1.0 },
    teal = { red = 0.5804, green = 0.8863, blue = 0.8353, alpha = 1.0 },
    sky = { red = 0.5373, green = 0.8627, blue = 0.9216, alpha = 1.0 },
    sapphire = { red = 0.4549, green = 0.7804, blue = 0.9255, alpha = 1.0 },
    blue = { red = 0.5373, green = 0.7059, blue = 0.9804, alpha = 1.0 },
    lavender = { red = 0.7059, green = 0.7451, blue = 0.9961, alpha = 1.0 },
    text = { red = 0.8039, green = 0.8392, blue = 0.9569, alpha = 1.0 },
    subtext1 = { red = 0.7294, green = 0.7608, blue = 0.8706, alpha = 1.0 },
    subtext0 = { red = 0.6510, green = 0.6784, blue = 0.7843, alpha = 1.0 },
    overlay2 = { red = 0.5765, green = 0.6000, blue = 0.6980, alpha = 1.0 },
    overlay1 = { red = 0.4980, green = 0.5176, blue = 0.6118, alpha = 1.0 },
    overlay0 = { red = 0.4235, green = 0.4392, blue = 0.5255, alpha = 1.0 },
    surface2 = { red = 0.3451, green = 0.3569, blue = 0.4392, alpha = 1.0 },
    surface1 = { red = 0.2706, green = 0.2784, blue = 0.3529, alpha = 1.0 },
    surface0 = { red = 0.1922, green = 0.1961, blue = 0.2667, alpha = 1.0 },
    base = { red = 0.1176, green = 0.1176, blue = 0.1804, alpha = 1.0 },
    mantle = { red = 0.0941, green = 0.0941, blue = 0.1451, alpha = 1.0 },
    crust = { red = 0.0667, green = 0.0667, blue = 0.1059, alpha = 1.0 },
}

return {
    logLevel = "info",
    palette = palette,

    menuBar = {
        enabled = true,
        screens = "all", -- "all", "main", or a table keyed by screen ID/name.
        height = nil, -- nil uses detected menu bar height with fallbackHeight.
        fallbackHeight = 24,
        background = "base",
        backgroundAlpha = 0.38,
        accent = "lavender",
        accentAlpha = 0.80,
        accentHeight = 0,
        topHighlight = false,
        topHighlightColor = "surface1",
        topHighlightAlpha = 0.55,
        topHighlightHeight = 1,
        level = "status",
        clickThrough = true,
    },
}
