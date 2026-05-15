# Mocha Theme

Mocha Theme is a Hammerspoon Spoon for applying Catppuccin Mocha visuals around macOS where Hammerspoon can draw safely.

The first feature is a top menu bar tint. Hammerspoon cannot directly replace or recolor the native macOS menu bar material owned by SystemUIServer, so this Spoon draws a click-through `hs.canvas` overlay across the menu bar area. The default opacity is intentionally modest so native menu text and status items remain usable.

## Bundle install

1. Run the repository installer from the repo root:

   ```sh
   ./install.sh
   ```

2. Reload Hammerspoon.

This links `MochaTheme.spoon` into `~/.hammerspoon/Spoons/` and links `mocha/init/mocha.lua` into `~/.hammerspoon/apps/mocha.lua`.

## Manual install

1. Link or copy `MochaTheme.spoon` into your Hammerspoon Spoons directory:

   ```sh
   mkdir -p ~/.hammerspoon/Spoons
   ln -s /<repo-folder>/mocha/MochaTheme.spoon ~/.hammerspoon/Spoons/MochaTheme.spoon
   ```

2. Add the example configuration below to `~/.hammerspoon/init.lua`.
3. Reload Hammerspoon.

## Example `init.lua`

```lua
hs.loadSpoon("MochaTheme")

spoon.MochaTheme:configure({
    menuBar = {
        enabled = true,
        screens = "all", -- "all", "main", or a table keyed by screen ID/name
        background = "base",
        backgroundAlpha = 0.38,
        accent = "lavender",
        accentAlpha = 0.80,
        accentHeight = 0,
        topHighlight = false,
        clickThrough = true,
    },
}):start()
```

## Public API

```lua
spoon.MochaTheme:configure({ ... })
spoon.MochaTheme:start()
spoon.MochaTheme:stop()
spoon.MochaTheme:reload()
```

## Configuration

| Option | Default | Description |
| ------ | ------- | ----------- |
| `logLevel` | `"info"` | Hammerspoon logger level. |
| `menuBar.enabled` | `true` | Draw the menu bar tint overlay. |
| `menuBar.screens` | `"all"` | Use `"all"`, `"main"`, or a table keyed by screen ID/name. |
| `menuBar.height` | `nil` | Explicit overlay height. `nil` uses detected menu bar height. |
| `menuBar.fallbackHeight` | `24` | Height used when macOS reports no top inset. |
| `menuBar.background` | `"base"` | Catppuccin token for the tint fill. |
| `menuBar.backgroundAlpha` | `0.38` | Tint opacity. Increase for stronger Mocha color. |
| `menuBar.accent` | `"lavender"` | Catppuccin token for the bottom rule. |
| `menuBar.accentAlpha` | `0.80` | Bottom rule opacity. |
| `menuBar.accentHeight` | `0` | Bottom rule height in points. Keep `0` for a flat single-color bar. |
| `menuBar.topHighlight` | `false` | Draw a top highlight line. Keep `false` for a flat single-color bar. |
| `menuBar.level` | `"status"` | Canvas window level. |
| `menuBar.clickThrough` | `true` | Best-effort pass-through behavior for menu bar interaction. |

Available color tokens match `DESIGN.md`: `rosewater`, `flamingo`, `pink`, `mauve`, `red`, `maroon`, `peach`, `yellow`, `green`, `teal`, `sky`, `sapphire`, `blue`, `lavender`, `text`, `subtext1`, `subtext0`, `overlay2`, `overlay1`, `overlay0`, `surface2`, `surface1`, `surface0`, `base`, `mantle`, and `crust`.

## Notes

This Spoon is intentionally reversible. It does not mutate macOS defaults, install helper tools, patch SystemUIServer, or use private APIs.

If the overlay appears above menu text too strongly, lower `menuBar.backgroundAlpha`. If it appears below the native menu bar on your macOS version, set `menuBar.level = "screenSaver"` as an experiment.

## License

MIT. See `LICENSE`.
