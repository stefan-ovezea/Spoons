# Hotkeys

Small Hammerspoon bootstrap module for personal global hotkey bindings that do not need a full Spoon.

## Install

Run the repository installer from the repo root:

```sh
./install.sh
```

The installer copies `hotkeys/init/hotkeys.lua` into `~/.hammerspoon/apps/hotkeys.lua`. The repository-standard `~/.hammerspoon/init.lua` loader then requires it on Hammerspoon startup.

## Available hotkeys

| Hotkey              | Action                       | Overrides native shortcut |
| ------------------- | ---------------------------- | ------------------------- |
| `cmd+shift+ctrl+R`  | Reload Hammerspoon config    | No                        |

## Overridden hotkeys

None currently.

## Notes

This folder is intentionally not a Spoon. Keep one-off personal bindings here when they are simple bootstrap configuration rather than reusable Spoon behavior.
