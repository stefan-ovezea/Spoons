# Spoons Agent Context

This repository contains Hammerspoon Spoons and supporting setup files for making macOS more Linux-like and more usable.

## Start Here

- Read `docs/agent-rules.md` before making structural, installer, or Spoon changes.
- Read `DESIGN.md` before making visual, UI, canvas, icon, color, or styling changes.
- Read the target Spoon folder's own `AGENTS.md` before changing that Spoon.
- If the folder-specific guidance conflicts with root guidance, follow the more specific folder guidance unless it would break a root repository rule.

## Repository Rules

- Use the Catppuccin Mocha palette in `DESIGN.md` as the default color scheme for new or changed UI.
- Keep each Spoon in its own root-level folder.
- Keep the actual Hammerspoon package as a `.spoon` directory inside that folder.
- Keep default Hammerspoon bootstrap scripts in the folder-level `init/` directory.
- Update the root `README.md` whenever adding, renaming, or removing a Spoon.
- Update relevant docs when changing behavior, setup, architecture, or roadmap status.

## Current Spoons

- `taskbar/` contains `Taskbar.spoon`, a lightweight macOS taskbar replacement.
- `switcher/` contains `WindowSwitcher.spoon`, a Windows-style individual window switcher.

## Extra Hammerspoon Config

- `hotkeys/` contains standalone personal global hotkey bindings.
