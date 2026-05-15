# Mocha Theme Architecture

Mocha Theme is a small Spoon with a central state object and focused helper modules.

## Modules

- `MochaTheme.spoon/init.lua`: public Spoon API, config copying/merging, lifecycle.
- `MochaTheme.spoon/config.lua`: Catppuccin Mocha palette and user-facing defaults.
- `MochaTheme.spoon/screens.lua`: screen selection and menu bar geometry.
- `MochaTheme.spoon/drawing.lua`: `hs.canvas` creation, coloring, and cleanup.
- `MochaTheme.spoon/events.lua`: screen and wake watchers that rebuild overlays.

## Menu Bar Tint

macOS does not expose a supported Hammerspoon API for recoloring the native menu bar. The Spoon therefore draws one transparent `hs.canvas` per selected display, positioned at the top of the screen's full frame.

The overlay is configured as stationary and available on all Spaces. It uses best-effort click-through behavior so the native menu bar can remain interactive.
