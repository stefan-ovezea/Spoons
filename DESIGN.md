# Design

This project uses the official Catppuccin Mocha palette as its visual baseline for any UI, canvas rendering, icons, indicators, documentation examples, terminal styling, editor-themed surfaces, and future design work.

Prefer these named tokens over ad hoc colors. When adding new UI states, derive them from this palette first.

This guidance is adapted for this repository from the upstream Catppuccin style guide:
<https://github.com/catppuccin/catppuccin/blob/main/docs/style-guide.md>

## Catppuccin Mocha

| Token     | Hex       | RGB                  | HSL                     | OKLCH                    |
| --------- | --------- | -------------------- | ----------------------- | ------------------------ |
| Rosewater | `#f5e0dc` | `rgb(245, 224, 220)` | `hsl(10deg, 56%, 91%)`  | `oklch(92%, 2% 30deg)`   |
| Flamingo  | `#f2cdcd` | `rgb(242, 205, 205)` | `hsl(0deg, 59%, 88%)`   | `oklch(88%, 4% 18deg)`   |
| Pink      | `#f5c2e7` | `rgb(245, 194, 231)` | `hsl(316deg, 72%, 86%)` | `oklch(87%, 8% 336deg)`  |
| Mauve     | `#cba6f7` | `rgb(203, 166, 247)` | `hsl(267deg, 84%, 81%)` | `oklch(79%, 12% 305deg)` |
| Red       | `#f38ba8` | `rgb(243, 139, 168)` | `hsl(343deg, 81%, 75%)` | `oklch(76%, 13% 3deg)`   |
| Maroon    | `#eba0ac` | `rgb(235, 160, 172)` | `hsl(350deg, 65%, 77%)` | `oklch(78%, 9% 9deg)`    |
| Peach     | `#fab387` | `rgb(250, 179, 135)` | `hsl(23deg, 92%, 75%)`  | `oklch(82%, 10% 53deg)`  |
| Yellow    | `#f9e2af` | `rgb(249, 226, 175)` | `hsl(41deg, 86%, 83%)`  | `oklch(92%, 7% 87deg)`   |
| Green     | `#a6e3a1` | `rgb(166, 227, 161)` | `hsl(115deg, 54%, 76%)` | `oklch(86%, 11% 143deg)` |
| Teal      | `#94e2d5` | `rgb(148, 226, 213)` | `hsl(170deg, 57%, 73%)` | `oklch(86%, 8% 183deg)`  |
| Sky       | `#89dceb` | `rgb(137, 220, 235)` | `hsl(189deg, 71%, 73%)` | `oklch(85%, 8% 210deg)`  |
| Sapphire  | `#74c7ec` | `rgb(116, 199, 236)` | `hsl(199deg, 76%, 69%)` | `oklch(79%, 10% 229deg)` |
| Blue      | `#89b4fa` | `rgb(137, 180, 250)` | `hsl(217deg, 92%, 76%)` | `oklch(77%, 11% 260deg)` |
| Lavender  | `#b4befe` | `rgb(180, 190, 254)` | `hsl(232deg, 97%, 85%)` | `oklch(82%, 9% 277deg)`  |
| Text      | `#cdd6f4` | `rgb(205, 214, 244)` | `hsl(226deg, 64%, 88%)` | `oklch(88%, 4% 272deg)`  |
| Subtext 1 | `#bac2de` | `rgb(186, 194, 222)` | `hsl(227deg, 35%, 80%)` | `oklch(82%, 4% 273deg)`  |
| Subtext 0 | `#a6adc8` | `rgb(166, 173, 200)` | `hsl(228deg, 24%, 72%)` | `oklch(75%, 4% 274deg)`  |
| Overlay 2 | `#9399b2` | `rgb(147, 153, 178)` | `hsl(228deg, 17%, 64%)` | `oklch(69%, 4% 275deg)`  |
| Overlay 1 | `#7f849c` | `rgb(127, 132, 156)` | `hsl(230deg, 13%, 55%)` | `oklch(62%, 4% 276deg)`  |
| Overlay 0 | `#6c7086` | `rgb(108, 112, 134)` | `hsl(231deg, 11%, 47%)` | `oklch(55%, 3% 277deg)`  |
| Surface 2 | `#585b70` | `rgb(88, 91, 112)`   | `hsl(233deg, 12%, 39%)` | `oklch(48%, 3% 279deg)`  |
| Surface 1 | `#45475a` | `rgb(69, 71, 90)`    | `hsl(234deg, 13%, 31%)` | `oklch(40%, 3% 280deg)`  |
| Surface 0 | `#313244` | `rgb(49, 50, 68)`    | `hsl(237deg, 16%, 23%)` | `oklch(32%, 3% 282deg)`  |
| Base      | `#1e1e2e` | `rgb(30, 30, 46)`    | `hsl(240deg, 21%, 15%)` | `oklch(24%, 3% 284deg)`  |
| Mantle    | `#181825` | `rgb(24, 24, 37)`    | `hsl(240deg, 21%, 12%)` | `oklch(22%, 3% 284deg)`  |
| Crust     | `#11111b` | `rgb(17, 17, 27)`    | `hsl(240deg, 23%, 9%)`  | `oklch(18%, 2% 284deg)`  |

## General Usage

Legibility always comes first. These token roles are defaults, not excuses to use low-contrast combinations. If text sits on an accent background, choose the foreground that is easiest to read, usually `Base` or `Crust`.

### Backgrounds

| Function         | Preferred Tokens                      |
| ---------------- | ------------------------------------- |
| Background pane  | `Base`                                |
| Secondary panes  | `Crust`, `Mantle`                     |
| Surface elements | `Surface 0`, `Surface 1`, `Surface 2` |
| Overlays         | `Overlay 0`, `Overlay 1`, `Overlay 2` |

### Typography

| Function                   | Preferred Tokens                  |
| -------------------------- | --------------------------------- |
| Body copy                  | `Text`                            |
| Main headlines             | `Text`                            |
| Sub-headlines and labels   | `Subtext 0`, `Subtext 1`          |
| Subtle or secondary text   | `Overlay 1`                       |
| Text on accent backgrounds | `Base`                            |
| Links and URLs             | `Blue`                            |
| Success text               | `Green`                           |
| Warning text               | `Yellow`                          |
| Error text                 | `Red`                             |
| Tags and pills             | `Blue`                            |
| Selection background       | `Overlay 2` at 20% to 30% opacity |
| Cursor                     | `Rosewater`                       |

## UI Guidance

- Use `Base` for primary backgrounds and `Mantle` or `Crust` for adjacent lower-emphasis regions.
- Use `Surface 0`, `Surface 1`, and `Surface 2` for controls, hover states, outlines, separators, and raised elements.
- Use `Overlay 0`, `Overlay 1`, and `Overlay 2` for disabled, muted, and secondary visual details.
- Use `Blue` or `Sapphire` for primary focus and links, `Green` for success or running states, `Yellow` or `Peach` for warnings and attention, and `Red` or `Maroon` for destructive or error states.
- Prefer restrained accent use. A Spoon UI should read as a dark Mocha interface with clear accents, not as a collage of all palette colors.

## Terminal Guidance

Use these mappings when this repository defines terminal colors or terminal-like UI.

### Window Colors

| Function        | Token       |
| --------------- | ----------- |
| Cursor          | `Rosewater` |
| Cursor text     | `Crust`     |
| Active border   | `Lavender`  |
| Inactive border | `Overlay 0` |
| Bell border     | `Yellow`    |

### ANSI Colors

| ANSI      | Token       |
| --------- | ----------- |
| `color0`  | `Surface 1` |
| `color1`  | `Red`       |
| `color2`  | `Green`     |
| `color3`  | `Yellow`    |
| `color4`  | `Blue`      |
| `color5`  | `Pink`      |
| `color6`  | `Teal`      |
| `color7`  | `Subtext 0` |
| `color8`  | `Surface 2` |
| `color15` | `Subtext 1` |
| `color16` | `Peach`     |
| `color17` | `Rosewater` |

Bright ANSI accent colors should be bolder and more saturated than the regular accents, not necessarily lighter.

## Code And Editor Guidance

Use these mappings for code editor surfaces, syntax-colored examples, search UI, debugging UI, and any code-like canvas rendering.

### Syntax Defaults

| Syntax Function                                              | Token       |
| ------------------------------------------------------------ | ----------- |
| Keywords                                                     | `Mauve`     |
| Strings                                                      | `Green`     |
| Symbols and atoms                                            | `Red`       |
| Escape sequences and regex                                   | `Pink`      |
| Comments                                                     | `Overlay 2` |
| Constants and numbers                                        | `Peach`     |
| Operators                                                    | `Sky`       |
| Braces and delimiters                                        | `Overlay 2` |
| Methods and functions                                        | `Blue`      |
| Parameters                                                   | `Maroon`    |
| Builtins                                                     | `Red`       |
| Classes, interfaces, annotations, metadata, enums, and types | `Yellow`    |
| Enum variants                                                | `Teal`      |
| Properties, such as JSON keys                                | `Blue`      |
| Attributes, such as XML-style attributes                     | `Yellow`    |
| Macros                                                       | `Rosewater` |

### Editor UI

| Function                 | Token                 |
| ------------------------ | --------------------- |
| Cursor                   | `Rosewater`           |
| Cursor line text         | `Text` at 10% opacity |
| Line numbers             | `Overlay 1`           |
| Active line number       | `Lavender`            |
| Normal links             | `Blue`                |
| Followed links           | `Lavender`            |
| Hovered links            | `Sky`                 |
| Search foreground        | `Text`                |
| Search background        | `Teal`                |
| Active search foreground | `Text`                |
| Active search background | `Red`                 |
| Errors                   | `Red`                 |
| Warnings                 | `Yellow`, `Peach`     |
| Information              | `Teal`                |

### Rainbow Highlights

For bracket, heading, parameter, or local-variable rainbow highlights, use:

1. `Red`
2. `Peach`
3. `Yellow`
4. `Green`
5. `Sapphire`
6. `Lavender`

When rainbow highlights need to stay subdued in text-heavy views, mix each accent toward `Text` rather than increasing opacity aggressively.

## Diff And Debugging Guidance

| Function                 | Token                         |
| ------------------------ | ----------------------------- |
| Diff header              | `Blue`                        |
| Diff index metadata      | `Overlay 2`                   |
| Diff file path markers   | `Pink`                        |
| Diff hunk header         | `Peach`                       |
| Changed text background  | `Blue` at 10% to 20% opacity  |
| Changed line background  | `Blue` at 15% to 25% opacity  |
| Inserted text background | `Green` at 10% to 20% opacity |
| Inserted line background | `Green` at 15% to 25% opacity |
| Removed text background  | `Red` at 10% to 20% opacity   |
| Removed line background  | `Red` at 15% to 25% opacity   |
| Breakpoint icon          | `Red`                         |
| Breakpoint line          | Transparent                   |
| Active breakpoint line   | `Yellow` at 15% opacity       |
