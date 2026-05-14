# Spoons

A collection of [Hammerspoon](https://www.hammerspoon.org/) Spoons.

## Spoons in this repo

| Folder     | Spoon           | Description                                                                             |
| ---------- | --------------- | --------------------------------------------------------------------------------------- |
| `taskbar/` | `Taskbar.spoon` | Lightweight macOS taskbar replacement: app icons, click-to-focus, pinning, clock, Trash |
| `switcher/` | `WindowSwitcher.spoon` | Windows-style `cmd+tab` switcher for picking individual app windows |

## Install

Run the install script from the root of this repository:

```sh
chmod +x install.sh
./install.sh
```

This recursively finds every `.spoon` directory and creates a symlink in `~/.hammerspoon/Spoons/`. Existing symlinks are replaced; existing real directories are left untouched with a warning.

The script also copies each Spoon folder's default init script from `init/<folder>.lua` into `~/.hammerspoon/apps/`, overwriting older copies. If `~/.hammerspoon/init.lua` does not exist, the script creates a loader that requires every `.lua` file in `~/.hammerspoon/apps/`.

## Usage

After installing, the generated `~/.hammerspoon/init.lua` loads app bootstrap files from `~/.hammerspoon/apps/`. The Taskbar bootstrap file loads and starts `Taskbar.spoon`; the WindowSwitcher bootstrap file loads `WindowSwitcher.spoon` and binds `cmd+tab` / `cmd+shift+tab`.

You can also load a spoon manually in `~/.hammerspoon/init.lua`:

```lua
hs.loadSpoon("Taskbar")
spoon.Taskbar:configure({ ... })
spoon.Taskbar:start()
```

See each spoon's own `README.md` for full configuration options.
