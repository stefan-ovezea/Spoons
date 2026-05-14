local M = {}

local log = hs.logger.new("reload", "info")

function M.reloadConfig()
    log.i("Reloading Hammerspoon config...")
    hs.reload()
end

function M.start()
    hs.hotkey.bind(
        { "cmd", "shift", "ctrl" },
        "R",
        M.reloadConfig
    )

    log.i("Reload hotkey registered: cmd+shift+ctrl+R")
end

M.start()

return M
