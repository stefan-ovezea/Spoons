# Taskbar

Taskbar is an early Hammerspoon Spoon that experiments with a lightweight macOS taskbar replacement. The first milestone is intentionally small: one `hs.canvas` bar per monitor, running apps displayed as icons, and click-to-focus behavior.

The current Spoon folder is `Taskbar.spoon` so it loads as `spoon.Taskbar`, matching the startup API in the initial milestone.

## Status

This is a working early implementation optimized for readability and iteration speed. It renders app icons, keeps normal windows out of the bar area, supports pinning/reordering, shows best-effort notification attention badges, and includes a small right-side clock plus Trash control. It does not integrate with Spaces or animate.

## Bundle install

1. Clone or copy this repository somewhere on disk.
2. Run the repository installer from the repo root:

   ```sh
   ./install.sh
   ```

   This links `Taskbar.spoon` into `~/.hammerspoon/Spoons/` and copies `taskbar/init/taskbar.lua` into `~/.hammerspoon/apps/taskbar.lua`.

3. Reload Hammerspoon.

## Manual install

1. Link or copy `Taskbar.spoon` into your Hammerspoon Spoons directory:

   ```sh
   mkdir -p ~/.hammerspoon/Spoons
   ln -s /<repo-folder>/taskbar/Taskbar.spoon ~/.hammerspoon/Spoons/Taskbar.spoon
   ```

2. Add the example configuration below to `~/.hammerspoon/init.lua`.
3. Reload Hammerspoon.

## Example `init.lua`

```lua
hs.loadSpoon("Taskbar")

spoon.Taskbar:configure({
    barHeight = 34,
    iconSize = 20,
    padding = 8,
    placement = "bottom", -- "top" or "bottom"
    pinnedApps = {
        -- "com.apple.Safari",
    },
    persistPinnedApps = true,
    contextMenu = true,
    dragReorder = true,
    dragThreshold = 5,
    reserveScreenSpace = true,
    showClock = true,
    showTrash = true,
    trashDebug = false,
    clockFormat = "%a %d %b  %H:%M",
    accessibilityBadges = true, -- best-effort Dock accessibility scan
    accessibilityDebug = false, -- true logs Dock accessibility text samples
    notificationCenterObserver = true, -- watches new Notification Center banners
    attentionCounter = true, -- in-memory count for notifications seen this session
    attentionDotSize = 12,
    debugNotificationBadge = false,
    logLevel = "info",
    excludedApps = {
        ["org.hammerspoon.Hammerspoon"] = true,
        ["com.apple.dock"] = true,
    },
}):start()
```

## Public API

```lua
spoon.Taskbar:start()
spoon.Taskbar:stop()
spoon.Taskbar:reload()
spoon.Taskbar:configure({ ... })
spoon.Taskbar:pinApp(appKey, index)
spoon.Taskbar:unpinApp(appKey)
spoon.Taskbar:refreshAttention()
spoon.Taskbar:debugAttentionTexts()
spoon.Taskbar:debugNotificationCenterTexts()
spoon.Taskbar:debugTrashState()
```

## Module Responsibilities

- `Taskbar.spoon/init.lua`: Spoon entry point, public API, central state object, configuration merge.
- `Taskbar.spoon/config.lua`: Default user-facing configuration.
- `Taskbar.spoon/apps.lua`: Running app discovery, filtering, sorting, icon lookup, activation.
- `Taskbar.spoon/screens.lua`: Monitor discovery and bar geometry.
- `Taskbar.spoon/drawing.lua`: `hs.canvas` creation, icon rendering, hover rendering, hit-testing, cleanup.
- `Taskbar.spoon/events.lua`: Application and display watchers with small deferred refreshes.
- `Taskbar.spoon/reservation.lua`: Window avoidance for Taskbar's reserved screen space.
- `Taskbar.spoon/attention.lua`: Best-effort Dock accessibility scan for red attention dots.
- `Taskbar.spoon/pins.lua`: Pinned app order, persistence, pin/unpin operations.
- `Taskbar.spoon/menu.lua`: Right-click app context menu.
- `Taskbar.spoon/drag.lua`: Left-click hold-drag app reordering.
- `Taskbar.spoon/trash.lua`: Trash state, open Trash, empty Trash.

## Hammerspoon APIs Used

- `hs.application`
- `hs.application.watcher`
- `hs.screen`
- `hs.canvas`
- `hs.image`
- `hs.logger`
- `hs.timer`
- `hs.window`
- `hs.window.filter`
- `hs.axuielement`
- `hs.settings`
- `hs.eventtap`
- `hs.menubar`
- `hs.fs`
- `hs.urlevent`
- `hs.osascript`

## Notes

The bars are normal floating Hammerspoon canvases. Hammerspoon cannot change the native macOS work area like the Dock does, so `reserveScreenSpace` is implemented by keeping standard visible windows inside a per-screen work area reduced by `barHeight`.

Attention dots are discovered from Notification Center accessibility events and, as a fallback, by scanning the Dock accessibility tree when `accessibilityBadges` is enabled. This is best-effort because macOS and apps do not guarantee a stable accessibility representation for notification badges. Use `spoon.Taskbar:debugAttentionTexts()` from the Hammerspoon console to inspect what the Dock exposes.

Pinned apps render on the left, unpinned running apps render on the right, and a separator appears between the groups. Left-click and hold an icon, then drag horizontally inside the bar to reorder; icons snap into their new slots as you cross midpoint thresholds. Drag a running app to the left side to pin it; drag a pinned app to the right side to unpin it. Right-click an app for Pin/Unpin, Quit, and Force Quit. Pin and app order are persisted with `hs.settings` under `Taskbar.pinnedApps` and `Taskbar.appOrder` when `persistPinnedApps` is enabled, so Taskbar does not rewrite your `init.lua`.

The clock and Trash live on the right side of the bar. Left-click Trash to open `~/.Trash`; right-click it for an Open/Empty menu. The Trash icon is checked periodically using `hs.fs` across standard Trash folders plus the Dock accessibility label when available, and changes appearance when visible trash items exist.

Set `accessibilityDebug = true`, `notificationCenterDebug = true`, and `logLevel = "debug"` to log Dock accessibility samples, Notification Center events, and matches to the Hammerspoon console.

If live events do not appear, open Notification Center manually and inspect:

```lua
hs.inspect(spoon.Taskbar:debugNotificationCenterTexts())
```

## License

MIT. See `LICENSE`.
