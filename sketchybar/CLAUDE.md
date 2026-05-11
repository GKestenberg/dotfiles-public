# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Restart sketchybar (picks up all changes)
brew services restart sketchybar

# Reload config without full restart
sketchybar --reload

# Tail live logs
tail -f /opt/homebrew/var/log/sketchybar/sketchybar.out.log

# Check for Lua errors
grep '\[!\] Lua' /opt/homebrew/var/log/sketchybar/sketchybar.out.log

# Query a specific item
sketchybar --query <item_name>

# Rebuild helper binaries only (also runs automatically on every config load via helpers/init.lua)
cd helpers && make

# Install/reinstall SbarLua bindings to ~/.local/share/sketchybar_lua/
helpers/install.sh
```

## Logs

- **Output log**: `/opt/homebrew/var/log/sketchybar/sketchybar.out.log` (Lua errors, build output)
- **Error log**: `/opt/homebrew/var/log/sketchybar/sketchybar.err.log` (process-level errors)

## Architecture

### Config Load Order

1. `sketchybar.sh` — Lua entry point (symlinked as `~/.config/sketchybar/sketchybarrc`)
2. `helpers/init.lua` — adds SbarLua `.so` to `package.cpath`, runs `make` to compile C helpers
3. `init.lua` — wraps everything in `sbar.begin_config()` / `sbar.end_config()` (batches all item creation into one message to sketchybar), then starts `sbar.event_loop()`
4. Modules loaded in order: `bar` → `default` → `items`

### Symlink Setup

This directory IS `~/.config/sketchybar` (symlinked via stow/links.prop). The `sketchybarrc` symlink points back to `sketchybar.sh`. `$CONFIG_DIR` env var (set by sketchybar service) = `~/.config/sketchybar`.

### Items System

`items/init.lua` loads items in order: apple, menus, spaces, front_app, calendar, battery, volume, wifi, cpu, weather, media. All items live flat in `items/` (no `widgets/` subdir).

### Helper Binaries (C)

Built via recursive Makefile during config load (`helpers/init.lua` calls `(cd helpers && make)` on every start, so C edits ship by restarting sketchybar — no manual build needed).

- `helpers/event_providers/cpu_load` — emits `cpu_update` events with user_load, sys_load, total_load (0-100)
- `helpers/event_providers/network_load` — emits `network_update` with upload/download speeds for interface en0
- `helpers/menus/` — separate Carbon/SkyLight binary that reads macOS app menus (`-l` list, `-s N` select); built independently from `event_providers/`

Each provider runs as a persistent background process spawned via `sbar.exec()`.

### Config Modules

- `colors.lua` — hex color palette with `with_alpha()` function
- `settings.lua` — central settings (paddings, icon set choice, font selection). Two main toggles:
  - `icons = "sf-symbols"` vs `"NerdFont"` — `icons.lua` returns one table or the other at require time
  - `font = require("helpers.default_font")` (SF Pro/Mono, manually installed) — commented JetBrainsMono Nerd Font block in `settings.lua` is the drop-in alternative
- `default.lua` — calls `sbar.default({...})`, equivalent to the `--default` domain; sets fonts, sizes, popup styling for every item created afterward
- `icons.lua` — SF Symbols (primary) and NerdFont (alt) icon mappings; selected by `settings.icons`
- `helpers/app_icons.lua` — app name → sketchybar-app-font icon mapping (used by `front_app`, `spaces`)

## Key Patterns

- **Brackets** group items: `sbar.add("bracket", name, { item1.name, item2.name }, props)` — membership is the third arg (an array of names), and brackets require padding items (empty items with only `width`) before and after due to spacing artifacts
- **Popups** are positioned via `position = "popup.<parent_item_name>"`; toggle drawing via `parent:set({ popup = { drawing = true/false/"toggle" } })`, query state with `parent:query().popup.drawing`
- **Graph items** use `item:push({value})` to append to value history
- **Custom events** are broadcast with `sbar.trigger("event_name")` and consumed via `item:subscribe("event_name", fn)` (e.g. `swap_menus_and_spaces` in `items/spaces.lua`)
- **Bulk removal by regex**: `sbar.remove("/pattern/")` (e.g. popup teardown — see `volume.lua`)
- `sbar.exec(cmd, callback)` runs shell commands async — callback receives stdout as string
- `sbar.animate(type, duration, callback)` for smooth transitions
- `sbar.delay(seconds, callback)` for timed actions
- **os.date() caches timezone** at process start — use `sbar.exec("date ...")` for DST-aware time

## Known Errors

- `spaces.lua:138` — nil space data on focus events when space has no window data
- `volume.lua:95` — popup reference nil during volume change events
