local M = {}

local log = hs.logger.new("hotkeys", "info")

local reloadModifiers = { "cmd", "shift", "ctrl" }
local reloadKey = "R"

function M.reloadConfig()
    log.i("Reloading Hammerspoon config...")
    hs.reload()
end

function M.start()
    hs.hotkey.bind(reloadModifiers, reloadKey, M.reloadConfig)

    log.i("Reload hotkey registered: cmd+shift+ctrl+R")
end

M.start()

return M
