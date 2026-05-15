local M = {}

local log = hs.logger.new("hotkeys", "info")

local reloadModifiers = { "cmd", "shift", "ctrl" }
local reloadKey = "R"
local ghosttyBundleId = "com.mitchellh.ghostty"
local ghosttyAppName = "Ghostty"
local ghosttyHotkeyModifiers = { "ctrl", "shift" }
local ghosttyHotkey = "x"

local terminalBundleIds = {
    ["com.apple.Terminal"] = true,
    ["com.googlecode.iterm2"] = true,
    ["com.mitchellh.ghostty"] = true,
    ["com.github.wez.wezterm"] = true,
    ["net.kovidgoyal.kitty"] = true,
    ["org.alacritty"] = true,
    ["dev.warp.Warp-Stable"] = true,
    ["co.zeit.hyper"] = true,
}

local textNavigationBindings = {
    {
        from = { { "ctrl" }, "c" },
        to = { { "cmd" }, "c" },
        passthroughInTerminal = true,
        description = "ctrl+c -> cmd+c",
    },
    {
        from = { { "ctrl" }, "x" },
        to = { { "cmd" }, "x" },
        passthroughInTerminal = true,
        description = "ctrl+x -> cmd+x",
    },
    {
        from = { { "ctrl" }, "v" },
        to = { { "cmd" }, "v" },
        passthroughInTerminal = true,
        description = "ctrl+v -> cmd+v",
    },
    {
        from = { { "ctrl", "shift" }, "c" },
        to = { { "cmd" }, "c" },
        terminalOnly = true,
        description = "ctrl+shift+c -> cmd+c in terminals",
    },
    {
        from = { { "ctrl", "shift" }, "v" },
        to = { { "cmd" }, "v" },
        terminalOnly = true,
        description = "ctrl+shift+v -> cmd+v in terminals",
    },
    {
        from = { { "ctrl" }, "a" },
        to = { { "cmd" }, "a" },
        passthroughInTerminal = true,
        description = "ctrl+a -> cmd+a",
    },
    {
        from = { { "ctrl" }, "z" },
        to = { { "cmd" }, "z" },
        passthroughInTerminal = true,
        description = "ctrl+z -> cmd+z",
    },
    {
        from = { { "ctrl" }, "s" },
        to = { { "cmd" }, "s" },
        description = "ctrl+s -> cmd+s",
    },
    {
        from = { { "ctrl" }, "f" },
        to = { { "cmd" }, "f" },
        description = "ctrl+f -> cmd+f",
    },
    {
        from = { { "ctrl", "shift" }, "f" },
        to = { { "cmd", "shift" }, "f" },
        description = "ctrl+shift+f -> cmd+shift+f",
    },
    {
        from = { { "ctrl" }, "p" },
        to = { { "cmd" }, "p" },
        description = "ctrl+p -> cmd+p",
    },
    {
        from = { { "ctrl", "shift" }, "p" },
        to = { { "cmd", "shift" }, "p" },
        description = "ctrl+shift+p -> cmd+shift+p",
    },
    {
        from = { { "ctrl" }, "," },
        to = { { "cmd" }, "," },
        description = "ctrl+, -> cmd+,",
    },
    {
        from = { { "ctrl" }, "." },
        to = { { "cmd" }, "." },
        description = "ctrl+. -> cmd+.",
    },
    {
        from = { { "ctrl" }, "-" },
        to = { { "cmd" }, "-" },
        description = "ctrl+- -> cmd+-",
    },
    {
        from = { { "ctrl" }, "=" },
        to = { { "cmd" }, "=" },
        description = "ctrl+= -> cmd+=",
    },
    {
        from = { { "ctrl" }, "d" },
        to = { { "cmd" }, "d" },
        passthroughInTerminal = true,
        description = "ctrl+d -> cmd+d",
    },
    {
        from = { { "ctrl", "shift" }, "z" },
        to = { { "cmd", "shift" }, "z" },
        description = "ctrl+shift+z -> cmd+shift+z",
    },
    {
        from = { { "ctrl" }, "y" },
        to = { { "cmd" }, "y" },
        description = "ctrl+y -> cmd+y",
    },
    {
        from = { { "ctrl" }, "t" },
        to = { { "cmd" }, "t" },
        description = "ctrl+t -> cmd+t",
    },
    {
        from = { { "ctrl", "shift" }, "t" },
        to = { { "cmd", "shift" }, "t" },
        description = "ctrl+shift+t -> cmd+shift+t",
    },
    {
        from = { { "ctrl" }, "w" },
        to = { { "cmd" }, "w" },
        description = "ctrl+w -> cmd+w",
    },
    {
        from = { { "ctrl" }, "left" },
        to = { { "alt" }, "left" },
        terminalTo = { { "alt" }, "b" },
        description = "ctrl+left -> option+left",
    },
    {
        from = { { "ctrl" }, "right" },
        to = { { "alt" }, "right" },
        terminalTo = { { "alt" }, "f" },
        description = "ctrl+right -> option+right",
    },
    {
        from = { { "ctrl", "shift" }, "left" },
        to = { { "alt", "shift" }, "left" },
        description = "ctrl+shift+left -> option+shift+left",
    },
    {
        from = { { "ctrl", "shift" }, "right" },
        to = { { "alt", "shift" }, "right" },
        description = "ctrl+shift+right -> option+shift+right",
    },
    {
        from = { {}, "home" },
        to = { { "cmd" }, "left" },
        passthroughInTerminal = true,
        description = "home -> cmd+left",
    },
    {
        from = { {}, "end" },
        to = { { "cmd" }, "right" },
        passthroughInTerminal = true,
        description = "end -> cmd+right",
    },
    {
        from = { { "shift" }, "home" },
        to = { { "cmd", "shift" }, "left" },
        description = "shift+home -> cmd+shift+left",
    },
    {
        from = { { "shift" }, "end" },
        to = { { "cmd", "shift" }, "right" },
        description = "shift+end -> cmd+shift+right",
    },
    {
        from = { { "ctrl" }, "home" },
        to = { { "cmd" }, "up" },
        description = "ctrl+home -> cmd+up",
    },
    {
        from = { { "ctrl" }, "end" },
        to = { { "cmd" }, "down" },
        description = "ctrl+end -> cmd+down",
    },
    {
        from = { { "ctrl", "shift" }, "home" },
        to = { { "cmd", "shift" }, "up" },
        description = "ctrl+shift+home -> cmd+shift+up",
    },
    {
        from = { { "ctrl", "shift" }, "end" },
        to = { { "cmd", "shift" }, "down" },
        description = "ctrl+shift+end -> cmd+shift+down",
    },
}

local modifierNames = { "cmd", "alt", "ctrl", "shift" }

function M.reloadConfig()
    log.i("Reloading Hammerspoon config...")
    hs.reload()
end

function M.callApplication(method, ...)
    local fn = hs.application[method]
    if type(fn) ~= "function" then return nil end

    local ok, value = pcall(fn, ...)
    if ok then return value end
    return nil
end

function M.focusOrLaunchGhostty()
    local app = hs.application.get(ghosttyBundleId) or hs.application.get(ghosttyAppName)
    local name = M.callApplication("nameForBundleID", ghosttyBundleId) or ghosttyAppName
    local path = M.callApplication("pathForBundleID", ghosttyBundleId)

    if app then
        app:unhide()
        app:activate(true)
    end

    if M.callApplication("launchOrFocusByBundleID", ghosttyBundleId) then
        return true
    end

    return M.callApplication("launchOrFocus", name) or M.callApplication("launchOrFocus", path)
end

function M.isTerminalApp()
    local app = hs.application.frontmostApplication()
    return app ~= nil and terminalBundleIds[app:bundleID()] == true
end

function M.hasModifier(modifiers, name)
    for _, modifier in ipairs(modifiers) do
        if modifier == name then
            return true
        end
    end

    return false
end

function M.modifiersMatch(expectedModifiers, actualFlags)
    for _, modifier in ipairs(modifierNames) do
        if M.hasModifier(expectedModifiers, modifier) ~= (actualFlags[modifier] == true) then
            return false
        end
    end

    return true
end

function M.sendTextNavigation(binding)
    local target = binding.to

    if binding.passthroughInTerminal and M.isTerminalApp() then
        return false
    end

    if binding.terminalOnly and not M.isTerminalApp() then
        return false
    end

    if binding.terminalTo and M.isTerminalApp() then
        target = binding.terminalTo
    end

    hs.eventtap.keyStroke(target[1], target[2], 0)
    return true
end

function M.bindTextNavigation()
    M.textNavigationTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
        local keyCode = event:getKeyCode()
        local flags = event:getFlags()

        for _, binding in ipairs(textNavigationBindings) do
            local fromModifiers = binding.from[1]
            local fromKeyCode = hs.keycodes.map[binding.from[2]]

            if keyCode == fromKeyCode and M.modifiersMatch(fromModifiers, flags) then
                return M.sendTextNavigation(binding)
            end
        end

        return false
    end)

    M.textNavigationTap:start()

    log.i("Windows/Linux-style text navigation event tap started")
end

function M.start()
    hs.hotkey.bind(reloadModifiers, reloadKey, M.reloadConfig)
    hs.hotkey.bind(ghosttyHotkeyModifiers, ghosttyHotkey, M.focusOrLaunchGhostty)
    M.bindTextNavigation()

    log.i("Reload hotkey registered: cmd+shift+ctrl+R")
    log.i("Ghostty hotkey registered: ctrl+shift+x")
end

M.start()

return M
