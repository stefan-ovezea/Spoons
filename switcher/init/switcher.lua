local M = {}

function M.start()
    hs.loadSpoon("WindowSwitcher")

    spoon.WindowSwitcher:configure({
        hotkeys = {
            next = { { "cmd" }, "tab" },
            previous = { { "cmd", "shift" }, "tab" },
        },
        overrideCommandTab = true,
        keyTapWatchdogInterval = 1.0,
        refreshInterval = 1.0,
        refreshDebounce = 0.12,
        logLevel = "info",
        excludedApps = {
            ["org.hammerspoon.Hammerspoon"] = true,
            ["com.apple.dock"] = true,
        },
    }):bindHotkeys()
end

M.start()

return M
