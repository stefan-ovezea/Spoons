# Mocha Theme Agent Context

Read the root `AGENTS.md`, `docs/agent-rules.md`, and `DESIGN.md` before changing this Spoon. This file adds Mocha Theme-specific context.

## Project Goal

Build Mocha Theme as a small Hammerspoon Spoon for applying Catppuccin Mocha-inspired system-adjacent visuals where Hammerspoon can safely draw them.

## Hard Constraints

- Use Hammerspoon APIs only.
- Use `hs.canvas` for menu bar tint rendering.
- Keep the real macOS menu bar limitation explicit: Hammerspoon cannot replace or recolor native SystemUIServer menu bar materials directly.
- Prefer low-risk overlays and reversible configuration over private APIs, native extensions, or `defaults` mutations.
- Keep runtime code self-contained inside `MochaTheme.spoon`.

## Current Spoon API

```lua
hs.loadSpoon("MochaTheme")
spoon.MochaTheme:configure({ ... })
spoon.MochaTheme:start()
spoon.MochaTheme:stop()
spoon.MochaTheme:reload()
```

## Development Guidance

- Use Catppuccin Mocha tokens from `DESIGN.md` for all default colors.
- Keep canvas geometry in screen helpers and rendering in drawing helpers.
- Update this folder's README when changing setup, public behavior, or configuration.
- Run `luac -p` against changed Lua files when possible.
