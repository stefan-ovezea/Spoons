# Implementation Log

## 2026-05-14

Created the first Hammerbar Spoon scaffold.

- Added `Taskbar.spoon` with separate modules for config, apps, screens, drawing, events, and lifecycle.
- Implemented one `hs.canvas` bar per monitor.
- Added app discovery through `hs.application.runningApplications()`.
- Filtered out non-Dock apps using `hs.application:kind()`.
- Added icon lookup through `hs.image.imageFromAppBundle()` with file icon fallback.
- Added app activation through `hs.application:activate(true)`.
- Added application watcher handling for launched, terminated, and activated events.
- Added screen watcher handling to rebuild bars on monitor changes.
- Added canvas-level mouse hit-testing using stored app regions.
- Added README, roadmap, and agent context docs.

Known limitations:

- Bars overlay windows; no screen space is reserved.
- Hover behavior is intentionally simple and re-renders the full bar.

## 2026-05-14 Hover update

- Removed visible app titles from the bar.
- Changed item geometry to fixed-width icon buttons.
- Added hover state in the central Spoon state object.
- Enabled canvas move and enter/exit mouse events.
- Added a simple hover background and small icon lift/scale effect.

## 2026-05-14 Badges and reservation

- Added red attention-dot rendering on app icons.
- Added configurable `accessibilityBadges` scanner for Dock accessibility text.
- Added Notification Center AX observer for new banners using `AXLayoutChanged` and `AXStackingIdentifier`.
- Added in-memory notification counters for observed Notification Center events.
- Added `Taskbar.spoon/reservation.lua` for screen-space avoidance.
- Added `reserveScreenSpace` and `reservationDebounce` configuration.
- Reservation uses `hs.window.filter` and `hs.window:setFrame()` to keep standard visible windows inside a work area reduced by `barHeight`.

## 2026-05-14 Pinning

- Added `Taskbar.spoon/pins.lua` for pinned app order and persistence.
- Added `pinnedApps`, `persistPinnedApps`, `dragThreshold`, `separatorWidth`, and `separatorSpacing` configuration.
- Added `spoon.Taskbar:pinApp(appKey, index)` and `:unpinApp(appKey)`.
- Added pinned-left, unpinned-right layout with a separator between groups.
- Added drag-to-pin, drag-to-unpin, and drag-to-reorder for running apps.
- Added right-click context menu with Pin/Unpin, Quit, and Force Quit.
- Added optional `debugNotificationBadge` fake app for visual badge testing.
- Added drag reorder for unpinned apps and persisted app order under `Hammerbar.appOrder`.
- Changed drag behavior to live horizontal reordering with slot snapping and no animation.
- Deferred `hs.settings` writes during drag so app order is persisted once on mouse release instead of on every mouse move.

Known limitations:

- Accessibility badge discovery is best-effort and depends on Dock/app accessibility text.
- Notification Center observer depends on notification elements exposing useful `AXStackingIdentifier` values.
- Reservation is not native macOS Dock-style work-area reservation; it is enforced window positioning.

## 2026-05-14 Clock and Trash

- Added right-side clock rendering with configurable `clockFormat`, `clockWidth`, and visibility.
- Added `Taskbar.spoon/trash.lua` for Trash fullness checks, opening Trash, and emptying Trash.
- Added a clickable Trash widget to every screen bar.
- Added right-click Trash menu with Open Trash and Empty Trash actions.
- Added periodic widget refresh for clock text and Trash state.
- Made Trash fullness detection check standard filesystem Trash locations and the Dock accessibility label.
- Added `spoon.Taskbar:debugTrashState()` for troubleshooting Trash detection.

Known limitations:

- Empty Trash is delegated to Finder through Hammerspoon's AppleScript bridge.
