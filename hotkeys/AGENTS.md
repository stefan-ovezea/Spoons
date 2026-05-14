# Hotkeys Agent Context

Read the root `AGENTS.md` and `docs/agent-rules.md` before changing this folder. This file adds guidance for standalone hotkey bootstrap configuration.

## Purpose

`hotkeys/` contains personal Hammerspoon hotkey bindings that are too small to justify a Spoon. The runtime file is `init/hotkeys.lua`, copied by the repository installer to `~/.hammerspoon/apps/hotkeys.lua`.

## Documentation Rules

- Update `README.md` whenever adding, removing, or rebinding a hotkey.
- Keep the `Available hotkeys` table complete and user-facing.
- Keep the `Overridden hotkeys` section current when a binding intentionally replaces a native macOS, app, or existing Hammerspoon shortcut.
- If a hotkey does not override existing behavior, mark it as `No` in the table.

## Development Guidance

- Keep this folder focused on simple global bindings.
- Use a full Spoon when behavior needs stateful modules, UI, reusable public APIs, or substantial configuration.
- Prefer readable Lua constants for modifier sets and key names.
- Use `hs.logger` for operational diagnostics.
