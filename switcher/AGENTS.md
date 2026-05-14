# WindowSwitcher Agent Context

Read the root `AGENTS.md` and `docs/agent-rules.md` before changing this Spoon. This file adds WindowSwitcher-specific context.

## Project Goal

Build WindowSwitcher, a Hammerspoon Spoon that replaces the default macOS app switcher with a Windows-style switcher for individual windows.

## Hard Constraints

- Use Hammerspoon APIs only.
- Use `hs.canvas` for rendering.
- Keep runtime code self-contained inside `WindowSwitcher.spoon`.
- Keep the default startup configuration in `init/switcher.lua`.
- Avoid native extensions, external dependencies, and global state.

## Current Spoon API

The package folder is `WindowSwitcher.spoon`, loaded as:

```lua
hs.loadSpoon("WindowSwitcher")
spoon.WindowSwitcher:bindHotkeys()
spoon.WindowSwitcher:start()
spoon.WindowSwitcher:stop()
spoon.WindowSwitcher:reload()
```

## Current Architecture

- `WindowSwitcher.spoon/init.lua`: entry point, public API, lifecycle, central state.
- `WindowSwitcher.spoon/config.lua`: default configuration.
- `WindowSwitcher.spoon/windows.lua`: window discovery, filtering, ordering, activation.
- `WindowSwitcher.spoon/drawing.lua`: `hs.canvas` rendering and hit testing.
- `WindowSwitcher.spoon/keys.lua`: hotkeys and event taps for Windows-style command-hold switching.

## Development Guidance

- Keep the first milestone focused on fast, predictable window switching.
- Preserve current-screen placement: the switcher should open on the focused window's screen, falling back to the mouse screen.
- Keep hit-test regions synchronized with rendered tiles.
- Prefer readable Lua over visual flourish.
