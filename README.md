# Spoons

A collection of [Hammerspoon](https://www.hammerspoon.org/) Spoons.

## Spoons in this repo

| Folder      | Spoon                  | Description                                                                             |
| ----------- | ---------------------- | --------------------------------------------------------------------------------------- |
| `mocha/`    | `MochaTheme.spoon`     | Catppuccin Mocha system-adjacent tinting, starting with a top menu bar overlay          |
| `taskbar/`  | `Taskbar.spoon`        | Lightweight macOS taskbar replacement: app icons, click-to-focus, pinning, clock, Trash |
| `switcher/` | `WindowSwitcher.spoon` | Windows-style `cmd+tab` switcher for picking individual app windows |

## Extra Hammerspoon config

| Folder     | Description                                  |
| ---------- | -------------------------------------------- |
| `hotkeys/` | Small personal global hotkey bindings module |

## Install

Run the install script from the root of this repository:

```sh
chmod +x install.sh
./install.sh
```

This recursively finds every `.spoon` directory and creates a symlink in `~/.hammerspoon/Spoons/`. Existing symlinks are replaced; existing real directories are left untouched with a warning.

The script also links each folder's default init script from `init/<folder>.lua` into `~/.hammerspoon/apps/`. Existing symlinks are replaced; existing real files are left untouched with a warning. This includes Spoon bootstrap files and standalone helper config such as `hotkeys/`. If `~/.hammerspoon/init.lua` does not exist, the script creates a loader that requires every `.lua` file in `~/.hammerspoon/apps/`.

## Usage

After installing, the generated `~/.hammerspoon/init.lua` loads app bootstrap files from `~/.hammerspoon/apps/`. The Mocha bootstrap file loads and starts `MochaTheme.spoon`; the Taskbar bootstrap file loads and starts `Taskbar.spoon`; the WindowSwitcher bootstrap file loads `WindowSwitcher.spoon` and binds `cmd+tab` / `cmd+shift+tab`; the Hotkeys bootstrap file binds personal standalone shortcuts.

You can also load a spoon manually in `~/.hammerspoon/init.lua`:

```lua
hs.loadSpoon("Taskbar")
spoon.Taskbar:configure({ ... })
spoon.Taskbar:start()
```

See each spoon's own `README.md` for full configuration options.
