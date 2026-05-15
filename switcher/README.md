# WindowSwitcher

WindowSwitcher is a Hammerspoon Spoon that replaces the default macOS app switcher with a Windows-style switcher for individual windows. Press `cmd+tab` to open it, keep holding Command to continue cycling, and release Command to focus the selected window. The default configuration intercepts `cmd+tab` with `hs.eventtap` so macOS does not receive the shortcut.

The switcher opens in the middle of the screen containing the mouse pointer.

## Status

This is an initial implementation focused on fast window picking. It lists standard windows in most-recently-focused order, includes minimized and hidden app windows where Hammerspoon exposes them, and focuses the selected window on release. The canvas UI uses the repository-wide Catppuccin Mocha palette from `DESIGN.md`.

## Bundle install

1. Clone or copy this repository somewhere on disk.
2. Run the repository installer from the repo root:

   ```sh
   ./install.sh
   ```

   This links `WindowSwitcher.spoon` into `~/.hammerspoon/Spoons/` and copies `switcher/init/switcher.lua` into `~/.hammerspoon/apps/switcher.lua`.

3. Reload Hammerspoon.

## Manual install

1. Link or copy `WindowSwitcher.spoon` into your Hammerspoon Spoons directory:

   ```sh
   mkdir -p ~/.hammerspoon/Spoons
   ln -s /<repo-folder>/switcher/WindowSwitcher.spoon ~/.hammerspoon/Spoons/WindowSwitcher.spoon
   ```

2. Add the example configuration below to `~/.hammerspoon/init.lua`.
3. Reload Hammerspoon.

## Example `init.lua`

```lua
hs.loadSpoon("WindowSwitcher")

spoon.WindowSwitcher:configure({
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
    mouseActivationThreshold = 3,
    accessibilityBadges = true,
    accessibilityBadgeInterval = 2,
    notificationCenterObserver = true,
    attentionCounter = true,
    attentionDotSize = 14,
    reverseMouseWheelScroll = true,
    excludedApps = {
        ["org.hammerspoon.Hammerspoon"] = true,
        ["com.apple.dock"] = true,
    },
    logLevel = "info",
}):bindHotkeys()
```

## Controls

- `cmd+tab`: show the switcher and move forward. The native macOS switcher is suppressed when `overrideCommandTab` is enabled.
- `cmd+shift+tab`: show the switcher and move backward.
- Release Command: focus the selected window.
- `escape`: cancel without changing focus.
- `return` or `space`: focus the selected window immediately.
- Arrow keys: move the selection while the switcher is visible. Up/down move by row.
- Mouse move: highlight the window under the pointer.
- Mouse click: focus the highlighted window.
- Mouse wheel: scroll overflowing rows when the pointer is over the switcher.

Mouse hover selection is ignored until the pointer actually moves after the switcher opens, so an existing pointer position over the switcher will not change the keyboard-selected target.

## Public API

```lua
spoon.WindowSwitcher:configure({ ... })
spoon.WindowSwitcher:bindHotkeys()
spoon.WindowSwitcher:start()
spoon.WindowSwitcher:stop()
spoon.WindowSwitcher:reload()
spoon.WindowSwitcher:show()
spoon.WindowSwitcher:refreshAttention()
spoon.WindowSwitcher:debugAttentionTexts()
spoon.WindowSwitcher:debugNotificationCenterTexts()
```

## Module Responsibilities

- `WindowSwitcher.spoon/init.lua`: Spoon entry point, public API, central state object, lifecycle.
- `WindowSwitcher.spoon/config.lua`: Default user-facing configuration.
- `WindowSwitcher.spoon/windows.lua`: Window discovery, filtering, ordering, and activation.
- `WindowSwitcher.spoon/drawing.lua`: `hs.canvas` creation, rendering, and hit testing.
- `WindowSwitcher.spoon/keys.lua`: Hotkeys and event taps for command-hold switching.
- `WindowSwitcher.spoon/attention.lua`: Best-effort Notification Center and Dock accessibility scan for app notification badges.

## Hammerspoon APIs Used

- `hs.hotkey`
- `hs.eventtap`
- `hs.keycodes`
- `hs.window`
- `hs.application`
- `hs.screen`
- `hs.mouse`
- `hs.canvas`
- `hs.image`
- `hs.logger`
- `hs.timer`
- `hs.axuielement`

## Notes

Hammerspoon must have Accessibility permission for global hotkeys, event taps, and reliable window focusing. If macOS still shows the native app switcher, reload Hammerspoon after granting Accessibility permission.

macOS does not provide a supported setting for disabling or rebinding the native `cmd+tab` app switcher. WindowSwitcher intercepts it with `hs.eventtap` and includes a watchdog that restarts the event tap if macOS disables it. If the native switcher still leaks through under load, the hard isolation approach is to remap `cmd+tab` before macOS sees it, for example with Karabiner-Elements, and bind WindowSwitcher to the remapped key such as `f18`.

Example Hammerspoon config for that setup:

```lua
spoon.WindowSwitcher:configure({
    hotkeys = {
        next = { {}, "f18" },
        previous = { {}, "f19" },
    },
    overrideCommandTab = false,
}):bindHotkeys()
```

WindowSwitcher keeps a cached window list warm with application/window watchers plus a periodic refresh. This keeps `cmd+tab` responsive while still allowing minimized and hidden windows to appear when Hammerspoon exposes them.

Notification badges are discovered from Notification Center accessibility events and, as a fallback, by scanning the Dock accessibility tree when `accessibilityBadges` is enabled. This mirrors Taskbar's best-effort attention flow: macOS and apps do not guarantee a stable accessibility representation, so use `spoon.WindowSwitcher:debugAttentionTexts()` and `spoon.WindowSwitcher:debugNotificationCenterTexts()` from the Hammerspoon console when troubleshooting.

WindowSwitcher only lists windows that Hammerspoon can see. Some system panels, helper apps, private windows, and nonstandard app surfaces may not appear.

## License

MIT. See `LICENSE`.
