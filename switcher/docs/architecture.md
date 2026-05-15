# WindowSwitcher Architecture

WindowSwitcher is a pure Hammerspoon Spoon for switching individual windows with a Windows-style command-hold interaction.

## Flow

1. `keys.lua` intercepts `cmd+tab` and `cmd+shift+tab` with `hs.eventtap`, consuming the native macOS shortcut before it reaches the system switcher.
2. The first key press uses the cached switchable window list and asks `drawing.lua` to render a centered chooser on the screen containing the mouse pointer.
3. Additional tab presses cycle the selected window.
4. Releasing Command accepts the selection and focuses the target window.

## Screen Placement

The switcher screen is resolved in this order:

1. The screen under the mouse.
2. The main screen.

The canvas is centered inside that screen's frame.

## Window Discovery

`hs.window.orderedWindows()` provides most-recently-focused ordering. When minimized or hidden windows are enabled, `hs.window.allWindows()` is used to append additional windows not present in the ordered list.

Window records and app icons are cached by the Spoon lifecycle. Application and window-filter events schedule debounced refreshes, and a periodic refresh covers events Hammerspoon may miss. The key event path reads the cache so `cmd+tab` can return quickly and stay ahead of the native switcher.

`keys.lua` also runs a watchdog timer that restarts the event tap if macOS disables it. This is still an interception strategy; macOS does not expose a supported native switcher disable/rebind API to Hammerspoon.

## Attention Badges

`attention.lua` mirrors Taskbar's best-effort notification flow. A Notification Center accessibility observer increments in-memory app counters for newly observed banners, and a periodic Dock accessibility scan marks apps whose Dock text appears to mention notifications, unread messages, alerts, or numeric badges.

Window records carry an app key and bundle ID so any window belonging to an app with an attention marker can render the same badge. Focusing an app clears its marker through the application watcher.

## Rendering

`drawing.lua` owns all `hs.canvas` details and hit-test regions. Runtime state stores plain window records, the selected index, and a small list of rendered regions for mouse clicks.

When there are more windows than visible slots, `drawing.lua` keeps `visibleStartIndex` aligned to grid rows and renders a scrollbar thumb to show overflow position.

`config.lua` defines the Catppuccin Mocha palette used by the switcher and maps rendering roles to restrained Mocha tokens: Base for the panel, Surface tokens for fills and borders, Lavender for selection, Red for attention badges, Overlay/Subtext for scrollbars and secondary text, and Text for primary labels.
