# WindowSwitcher Implementation Log

## 0.1.0

- Added the initial `WindowSwitcher.spoon` package.
- Added default `cmd+tab` and `cmd+shift+tab` bindings.
- Added individual-window discovery, filtering, and focus activation.
- Added centered `hs.canvas` chooser on the active screen.
- Added mouse click, Escape cancel, Enter/Space accept, and arrow-key selection.
- Added default bootstrap file at `init/switcher.lua`.
- Changed `cmd+tab` handling to an `hs.eventtap` override that consumes native macOS switcher events.
- Added cached window records, cached app icons, debounced watcher refreshes, and a periodic refresh to reduce switcher launch latency.
- Added an event-tap watchdog for recovering from macOS disabling the key tap.
- Added row-aware up/down navigation, mouse-hover selection, and a scrollbar indicator for overflow.
- Added mouse-wheel scrolling for overflowing switcher rows.
- Reversed physical mouse-wheel scrolling while preserving natural trackpad scrolling.
- Updated the switcher canvas colors to use Catppuccin Mocha role tokens from `DESIGN.md`.
