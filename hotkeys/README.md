# Hotkeys

Small Hammerspoon bootstrap module for personal global hotkey bindings that do not need a full Spoon.

## Install

Run the repository installer from the repo root:

```sh
./install.sh
```

The installer copies `hotkeys/init/hotkeys.lua` into `~/.hammerspoon/apps/hotkeys.lua`. The repository-standard `~/.hammerspoon/init.lua` loader then requires it on Hammerspoon startup.

## Available hotkeys

| Hotkey                 | Action                                  | Overrides native shortcut |
| ---------------------- | --------------------------------------- | ------------------------- |
| `cmd+shift+ctrl+R`     | Reload Hammerspoon config               | No                        |
| `ctrl+shift+x`         | Launch or focus Ghostty                 | No                        |
| `ctrl+c`               | Copy                                    | Yes                       |
| `ctrl+x`               | Cut                                     | Yes                       |
| `ctrl+v`               | Paste                                   | Yes                       |
| `ctrl+shift+c`         | Copy in terminal apps                  | Yes                       |
| `ctrl+shift+v`         | Paste in terminal apps                 | Yes                       |
| `ctrl+a`               | Select all                              | Yes                       |
| `ctrl+z`               | Undo                                    | Yes                       |
| `ctrl+s`               | Save                                    | Yes                       |
| `ctrl+f`               | Find                                    | Yes                       |
| `ctrl+shift+f`         | Find in all files                       | Yes                       |
| `ctrl+p`               | Print or app-specific `cmd+p` action    | Yes                       |
| `ctrl+shift+p`         | App-specific `cmd+shift+p` action       | Yes                       |
| `ctrl+,`               | App-specific `cmd+,` action             | Yes                       |
| `ctrl+.`               | App-specific `cmd+.` action             | Yes                       |
| `ctrl+-`               | Zoom out                                | Yes                       |
| `ctrl+=`               | Zoom in                                 | Yes                       |
| `ctrl+d`               | Send app-specific `cmd+d` action        | Yes                       |
| `ctrl+shift+z`         | Redo                                    | Yes                       |
| `ctrl+y`               | Send app-specific `cmd+y` action        | Yes                       |
| `ctrl+t`               | New tab                                 | Yes                       |
| `ctrl+shift+t`         | Reopen recently closed tab              | Yes                       |
| `ctrl+w`               | Close current tab/window                | Yes                       |
| `ctrl+left`            | Move back one word                      | Yes                       |
| `ctrl+right`           | Move forward one word                   | Yes                       |
| `ctrl+shift+left`      | Select back one word                    | Yes                       |
| `ctrl+shift+right`     | Select forward one word                 | Yes                       |
| `home`                 | Move to start of line                   | Yes                       |
| `end`                  | Move to end of line                     | Yes                       |
| `shift+home`           | Select to start of line                 | Yes                       |
| `shift+end`            | Select to end of line                   | Yes                       |
| `ctrl+home`            | Move to start of document/file          | Yes                       |
| `ctrl+end`             | Move to end of document/file            | Yes                       |
| `ctrl+shift+home`      | Select to start of document/file        | Yes                       |
| `ctrl+shift+end`       | Select to end of document/file          | Yes                       |

## Overridden hotkeys

- `ctrl+a` / `ctrl+c` / `ctrl+v` / `ctrl+x`: replaces app-specific Control-key behavior with Select All, Copy, Paste, and Cut. In terminal apps, `ctrl+a`, `ctrl+c`, and `ctrl+v` pass through unchanged.
- `ctrl+shift+c` / `ctrl+shift+v`: replaces terminal-specific behavior with Copy and Paste in terminal apps.
- `ctrl+z` / `ctrl+shift+z`: replaces app-specific Control-key behavior with Undo and Redo. In terminal apps, `ctrl+z` passes through unchanged.
- `ctrl+s`: replaces app and terminal-specific Control-key behavior with Save.
- `ctrl+f` / `ctrl+shift+f`: replaces app and terminal-specific Control-key behavior with Find and Find in All Files.
- `ctrl+p` / `ctrl+shift+p` / `ctrl+,` / `ctrl+.`: replaces app and terminal-specific Control-key behavior with matching Command-key actions.
- `ctrl+-` / `ctrl+=`: replaces app and terminal-specific Control-key behavior with Zoom Out and Zoom In.
- `ctrl+d` / `ctrl+y`: replaces app-specific Control-key behavior with app-specific Command-key actions. In terminal apps, `ctrl+d` passes through unchanged.
- `ctrl+t` / `ctrl+shift+t` / `ctrl+w`: replaces app and terminal-specific Control-key behavior with New Tab, Reopen Recently Closed Tab, and Close Tab/Window.
- `ctrl+left` / `ctrl+right`: replaces the macOS Mission Control default for switching Spaces when that shortcut is enabled in System Settings.
- `home` / `end`: replaces the macOS default behavior used by many apps, which often scrolls to the top or bottom instead of moving within the current line.
- `shift+home` / `shift+end`: replaces app-specific selection or scrolling behavior with line selection.
- `ctrl+home` / `ctrl+end`: replaces app-specific behavior with document/file start and end navigation.

## Notes

This folder is intentionally not a Spoon. Keep one-off personal bindings here when they are simple bootstrap configuration rather than reusable Spoon behavior.

The text navigation bindings use a Hammerspoon event tap so shortcuts such as `ctrl+left/right` can be intercepted before the focused app handles them. They send native macOS equivalents:

| Windows/Linux-style input | macOS event sent          |
| ------------------------- | ------------------------- |
| `ctrl+a/c/x/v`            | `cmd+a/c/x/v`             |
| `ctrl+shift+c/v`          | `cmd+c/v` in terminals    |
| `ctrl+z`                  | `cmd+z`                   |
| `ctrl+s`                  | `cmd+s`                   |
| `ctrl+f`                  | `cmd+f`                   |
| `ctrl+shift+f`            | `cmd+shift+f`             |
| `ctrl+p`                  | `cmd+p`                   |
| `ctrl+shift+p`            | `cmd+shift+p`             |
| `ctrl+,`                  | `cmd+,`                   |
| `ctrl+.`                  | `cmd+.`                   |
| `ctrl+-/=`                | `cmd+-/=`                 |
| `ctrl+d/y`                | `cmd+d/y`                 |
| `ctrl+shift+z`            | `cmd+shift+z`             |
| `ctrl+t/w`                | `cmd+t/w`                 |
| `ctrl+shift+t`            | `cmd+shift+t`             |
| `ctrl+left/right`         | `option+left/right`       |
| `ctrl+shift+left/right`   | `option+shift+left/right` |
| `home` / `end`            | `cmd+left/right`          |
| `ctrl+home/end`           | `cmd+up/down`             |

For common terminal emulators, command-line navigation uses shell-friendly events where possible:

| Input                 | Terminal event sent |
| --------------------- | ------------------- |
| `ctrl+a` / `ctrl+c` / `ctrl+v` | passed through      |
| `ctrl+d`              | passed through      |
| `ctrl+z`              | passed through      |
| `ctrl+shift+c/v`      | `cmd+c/v`           |
| `ctrl+left/right`     | `alt+b/f`           |
| `home` / `end`        | `ctrl+a/e`          |

Terminal selection behavior depends on the active terminal emulator and the shell/editor running inside it. `ctrl+shift+left/right` and the document/file start/end bindings still send the macOS navigation equivalents.

If `ctrl+left/right` still switches Spaces or does nothing, disable the matching Mission Control shortcuts in macOS System Settings under Keyboard Shortcuts.
