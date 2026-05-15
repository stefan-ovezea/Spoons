local M = {}

function M.start()
    hs.loadSpoon("MochaTheme")

    spoon.MochaTheme:configure({
        logLevel = "info",
        menuBar = {
            enabled = true,
            screens = "all",
            background = "base",
            backgroundAlpha = 0.38,
            accent = "lavender",
            accentAlpha = 0.80,
            accentHeight = 0,
            topHighlight = false,
            clickThrough = true,
        },
    }):start()
end

M.start()

return M
