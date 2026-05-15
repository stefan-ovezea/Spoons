local M = {}

function M.start()
    hs.loadSpoon("Taskbar")

    spoon.Taskbar:configure({
        barHeight = 50,
        fontSize = 12,
        iconSize = 24,
        padding = 8,
        placement = "bottom", -- "top" or "bottom"
        logLevel = "debug",
        pinnedApps = {
            -- "com.apple.Safari",
        },
        persistPinnedApps = true,
        reserveScreenSpace = true,
        accessibilityBadges = true, -- best-effort Dock accessibility scan
        accessibilityDebug = false, -- true logs Dock accessibility text samples
        notificationCenterObserver = true, -- watches new Notification Center banners
        notificationCenterDebug = false, -- true logs full Notification Center AX payloads
        attentionCounter = true, -- in-memory count for notifications seen this session
        attentionDotSize = 16,
        excludedApps = {
            ["org.hammerspoon.Hammerspoon"] = true,
            ["com.apple.dock"] = true,
        },
    }):start()
end

M.start()

return M
