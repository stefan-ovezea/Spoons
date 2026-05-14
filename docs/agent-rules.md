# Agent Rules

These rules apply to the whole Spoons repository. Each Spoon or standalone helper folder can add more specific guidance in its own `AGENTS.md`.

## Repository Structure

- Every Spoon must live in its own root-level folder.
- Each Spoon folder must contain the actual Hammerspoon package as a `.spoon` directory inside that folder.
- Keep supporting files beside the `.spoon` directory, not inside it, unless they are part of the Spoon runtime.
- Each Spoon folder should include:
  - `README.md` for user-facing usage and configuration.
  - `AGENTS.md` for Spoon-specific AI guidance.
  - `docs/` for architecture notes, roadmaps, implementation logs, and design decisions.
  - `init/` for default Hammerspoon app bootstrap scripts.

Use the current `taskbar/` folder as the reference structure:

```text
taskbar/
  AGENTS.md
  README.md
  docs/
  init/
    taskbar.lua
  Taskbar.spoon/
    init.lua
    ...
```

Standalone helper folders may omit a `.spoon` directory when they contain plain Hammerspoon bootstrap configuration rather than reusable Spoon behavior. They should still include `README.md`, `AGENTS.md`, and `init/<folder>.lua`.

## Init Scripts

- At the base of every Spoon or standalone helper folder, include an `init/` directory when that folder has a default Hammerspoon bootstrap module.
- The bootstrap script must be named after the folder, using the exact folder name plus `.lua`.
- For example, `taskbar/init/taskbar.lua` is copied by `install.sh` into `~/.hammerspoon/apps/taskbar.lua`.
- The bootstrap script is intended to be copied exactly into `~/.hammerspoon/apps/`.
- Do not put these bootstrap scripts inside the `.spoon` directory.

## README Updates

- Always update the root `README.md` when adding, renaming, or removing a Spoon.
- Always update the Spoon folder's own `README.md` when changing setup, configuration, public behavior, or expected user workflow.

## Install Script Expectations

- `install.sh` must link every `.spoon` directory into `~/.hammerspoon/Spoons/`.
- `install.sh` must copy each valid `init/<folder>.lua` file into `~/.hammerspoon/apps/`, including standalone helper folders, overwriting older copies so default configs stay current.
- `install.sh` must create `~/.hammerspoon/apps/` when it does not exist.
- `install.sh` must create `~/.hammerspoon/init.lua` only when it does not exist, using the repository-standard loader for files in `~/.hammerspoon/apps/`.

## Change Discipline

- Prefer small, focused changes that match the current folder patterns.
- Keep Spoon runtime code self-contained inside the `.spoon` directory.
- Keep user bootstrap/config code in the Spoon folder's `init/` directory.
- Update documentation in the same change when behavior or structure changes.
- Make sure to keep the config code inside the `init/` directory up to date when introducing new configs for a specific Spoon

## Verification

- Run Lua syntax checks for changed Spoon and init files when possible.
- Prefer `luac -p` for syntax-only checks.
- If `lua` or `luac` are not available on `PATH`, check common Homebrew locations before reporting that Lua is unavailable:
  - `/opt/homebrew/bin/lua`
  - `/opt/homebrew/bin/luac`
  - `/usr/local/bin/lua`
  - `/usr/local/bin/luac`
