# Taskbar Agent Context

Read the root `AGENTS.md` and `docs/agent-rules.md` before changing this Spoon. This file adds Taskbar-specific context.

## Project Goal

Build Taskbar, a lightweight open-source macOS taskbar replacement implemented as a Hammerspoon Spoon. Keep the implementation pure Lua and Hammerspoon APIs.

## Hard Constraints

- Use Hammerspoon APIs only.
- Use `hs.canvas` for rendering.
- Do not use Swift, AppKit, Electron, Tauri, native extensions, or external dependencies.
- Avoid accessibility hacks unless a future milestone explicitly requires them.
- Keep state centralized and avoid globals.
- Preserve readability over visual polish.

## Current Spoon API

The current package folder is `Taskbar.spoon`, loaded as:

```lua
hs.loadSpoon("Taskbar")
spoon.Taskbar:start()
spoon.Taskbar:stop()
spoon.Taskbar:reload()
```

## Current Architecture

- `Taskbar.spoon/init.lua`: entry point, central state, lifecycle.
- `Taskbar.spoon/config.lua`: default config.
- `Taskbar.spoon/apps.lua`: app discovery and activation.
- `Taskbar.spoon/screens.lua`: monitor discovery and bar frames.
- `Taskbar.spoon/drawing.lua`: canvas rendering and hit testing.
- `Taskbar.spoon/events.lua`: Hammerspoon watchers and refresh scheduling.
- `Taskbar.spoon/reservation.lua`: window avoidance for reserved bar space.
- `Taskbar.spoon/attention.lua`: Notification Center and Dock accessibility-based red-dot discovery.
- `Taskbar.spoon/pins.lua`: pinned app order and persistence.
- `Taskbar.spoon/menu.lua`: right-click context menu.
- `Taskbar.spoon/drag.lua`: left-click hold-drag reordering.
- `Taskbar.spoon/trash.lua`: Trash fullness checks, open Trash, empty Trash.

## Non-Goals For Now

- Reliable Notification Center badge counts
- Native macOS work-area mutation
- Animations
- App grouping
- Spaces integration
- Blur or glass effects

## Development Guidance

- Prefer small, reviewable changes.
- Keep modules focused and avoid cross-module calls that bypass the central state shape.
- Use `hs.logger` for operational diagnostics.
- When changing rendering, keep hit-test regions in sync with visible item geometry.
- When adding features, update `docs/roadmap.md` and `docs/implementation-log.md`.
