# Architecture

Hammerbar is split into small Lua modules loaded by `Taskbar.spoon/init.lua` with `dofile`. This avoids package-path assumptions for nested Spoon files and keeps module boundaries explicit.

## State Shape

The Spoon builds a central state object on `:start()`:

```lua
{
    config = { ... },
    logger = hs.logger,
    apps = { ... },
    bars = { ... },
    screenList = { ... },
    pinnedAppKeys = { ... },
    hoveredAppKey = nil,
    accessibilityBadges = { ... },
    appsModule = apps,
    screens = screens,
    drawing = drawing,
    events = events,
    reservation = reservation,
    attention = attention,
    pins = pins,
    menu = menu,
    drag = drag,
    trash = trash,
}
```

Modules receive this state object instead of using global variables.

## Rendering Flow

1. `apps.refresh(state)` collects displayable applications.
2. `screens.current()` collects attached monitors.
3. `drawing.rebuildBars(state, screens, onMouseEvent)` creates one canvas per monitor.
4. `drawing.render(state, screens)` replaces canvas elements when app, attention, hover, or active-app state changes.

## Pin Flow

`pins.lua` owns the ordered pinned-app list and the ordered running-app list, then persists both with `hs.settings` when configured. `drawing.lua` asks `pins.orderedApps(state)` for pinned and unpinned groups, lays pinned items on the left, inserts a separator when both groups are visible, then lays unpinned apps on the right. Dragging updates ordering live while the mouse is held; dragging within a group reorders it, and dragging across the separator pins or unpins the app. Icons snap into slots without animation.

## Menu Flow

`menu.lua` uses `hs.eventtap` to catch right-clicks that land inside Hammerbar regions and shows a hidden `hs.menubar` popup menu. App menu actions pin or unpin through `pins.lua`, and quit apps through `hs.application`. Trash menu actions open or empty Trash through `trash.lua`.

## Widget Flow

`drawing.lua` reserves space on the right side of every bar for lightweight widgets before laying out app icons. The clock is rendered from `os.date(config.clockFormat)`. `trash.lua` checks standard Trash folders with `hs.fs`, reads the Dock accessibility label as a fallback state signal, opens Trash through `hs.urlevent`, and empties Trash through `hs.osascript`. A small timer refreshes widget state and redraws the bars.

## Event Flow

`events.lua` owns the Hammerspoon watchers:

- App launched or terminated: refresh app list and re-render.
- App activated: update frontmost flags and re-render.
- Screen layout changed: rebuild all bars and recompute reserved areas.

Updates are deferred by a short `hs.timer.doAfter` to coalesce noisy event bursts.

## Click Flow

The canvas receives mouse callbacks at the canvas level for hover state. `drawing.hitTest()` checks the local pointer position against stored app regions, and `mouseMove`, `mouseEnter`, and `mouseExit` update `state.hoveredAppKey`. Left-click press, drag, and release are handled by `drag.lua` through `hs.eventtap` so app clicks, Trash clicks, and icon reordering share the same hit-test regions.

## Attention Flow

`attention.lua` observes Notification Center accessibility layout changes and reads notification `AXStackingIdentifier` values to map new banners back to running apps. It increments an in-memory per-app count for notifications seen during the current Hammerbar session, clearing that count when the app is activated. It can also scan the Dock accessibility tree when `accessibilityBadges` is enabled. Both paths expose attention state through `state.accessibilityBadges`.

## Reservation Flow

`reservation.lua` computes a work area per screen from `hs.screen:frame()` and subtracts `config.barHeight` on the configured edge. It uses `hs.window.filter` subscriptions to keep standard visible windows inside those work areas. This is window avoidance, not a native macOS work-area mutation.
